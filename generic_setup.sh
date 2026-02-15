#!/bin/bash

apt update
apt --assume-yes install apt-transport-https curl

echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
#sed -i 's/^# deb http\:\/\/archive\.canonical\.com\/ubuntu jammy partner/deb http\:\/\/archive\.canonical\.com\/ubuntu jammy partner/' /etc/apt/sources.list
echo "deb [signed-by=/usr/share/keyrings/mws3-archive-keyring.gpg] https://packagecloud.io/slacktechnologies/slack/debian jessie main" > /etc/apt/sources.list.d/slack.list
#add-apt-repository --yes ppa:eivnaes/network-manager-sstp
add-apt-repository --yes ppa:mozillateam/ppa

mkdir -p /root/.gnupg
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 78BD65473CB3BD13
gpg --no-default-keyring --keyring /usr/share/keyrings/mws1-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 78BD65473CB3BD13
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 61FF9694161CE595
gpg --no-default-keyring --keyring /usr/share/keyrings/mws2-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 61FF9694161CE595
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C6ABDCF64DB9A0B2
#gpg --export C6ABDCF64DB9A0B2 | tee /etc/apt/keyrings/slacktechnologies_slack-archive-keyring.gpg
curl -fsSL https://packagecloud.io/slacktechnologies/slack/gpgkey | gpg --dearmor > /etc/apt/trusted.gpg.d/slacktechnologies_slack.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/mws3-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C6ABDCF64DB9A0B2
mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/

snap remove firefox
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

curl --tlsv1.2 --silent --show-error --header 'x-connect-key: f1410e974759648b24df737ee230a0fd3a6a9bcd' https://kickstart.jumpcloud.com/Kickstart | bash
apt --allow-downgrades --assume-yes install firefox google-chrome-stable slack-desktop network-manager-sstp-gnome lshw apt-transport-https software-properties-gtk smartmontools intel-media-va-driver-non-free intel-opencl-icd mesa-opencl-icd ubuntu-restricted-extras knockd network-manager-l2tp-gnome gnome-software gnome-software-plugin-flatpak gnome-software-plugin-snap xdg-desktop-portal-wlr

systemctl disable xl2tpd; systemctl stop xl2tpd power-profiles-daemon 
apt -y install network-manager-fortisslvpn-gnome network-manager-l2tp-gnome network-manager-openconnect-gnome network-manager-strongswan 
# laptop-mode-tools

cat > /etc/cron.weekly/apt-autoremove <<EOF
#!/bin/bash

apt -y autoremove
EOF
chmod +x /etc/cron.weekly/apt-autoremove
# openssh-server
for user in `ls -1 /home/`; do
    mkdir -p /home/$user/.local/share/applications
    cat /usr/share/applications/google-chrome.desktop | sed 's/\/usr\/bin\/google-chrome-stable/\/usr\/bin\/google-chrome-stable --disable-software-rasterizer --disable-font-subpixel-positioning --disable-gpu-driver-bug-workarounds --disable-gpu-driver-workarounds --disable-gpu-vsync --enable-accelerated-video-decode --enable-accelerated-video-encode --enable-features=VaapiVideoDecoder --disable-gpu-driver-bug-workarounds --enable-features=VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization --enable-gpu-compositing --enable-gpu-rasterization --enable-oop-rasterization --use-vulkan --enable-zero-copy --ignore-gpu-blocklist /' > /home/$user/.local/share/applications/google-chrome.desktop
    cat /usr/share/applications/slack.desktop | sed 's/Exec=\/usr\/bin\/slack/Exec=\/usr\/bin\/slack --enable-features=WebRTCPipeWireCapturer/g' > /home/$user/.local/share/applications/slack.desktop
    cat > /home/$user/.local/share/applications/MWS\ Port\ Knock.desktop <<EOF
[Desktop Entry]
Version=1.0
Name=MWS Port Knock
Comment=Connect to VPN
Exec=/usr/local/bin/mws-port-knock
Icon=/usr/share/pixmaps/mws-port-knock.svg
Terminal=false
Type=Application
Categories=GNOME;GTK;Network;
Keywords=vpn;
X-GNOME-Bugzilla-Bugzilla=GNOME
X-GNOME-Bugzilla-Version=3.22.9
StartupNotify=true
EOF
    chown -R $user:$user /home/$user/.local
done

cat > /etc/NetworkManager/system-connections/MWS\ L2TP.nmconnection <<EOF
[connection]
id=MWS L2TP
uuid=5a28379d-d12e-4028-81d2-2fd43a661008
type=vpn
autoconnect=false
permissions=
timestamp=1628506953

[vpn]
gateway=vin.mobilewaves.com
ipsec-enabled=yes
ipsec-esp=aes256-sha1
ipsec-forceencaps=yes
ipsec-ike=aes256-sha1-modp4096
ipsec-ipcomp=yes
ipsec-psk=0sTW9iaWxlRXhwZXJpZW5jZQ==
mppe-stateful=yes
mru=1400
mtu=1400
password-flags=1
refuse-chap=yes
refuse-eap=yes
refuse-mschap=yes
refuse-pap=yes
require-mppe-128=yes
user=
service-type=org.freedesktop.NetworkManager.l2tp

[ipv4]
dns-search=
method=auto

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto

[proxy]

EOF

cat > /etc/NetworkManager/system-connections/MWS\ SSTP.nmconnectio <<EOF
[connection]
id=MWS SSTP
uuid=bd4b7f00-3394-4ce3-a343-1140ee0a0e31
type=vpn
autoconnect=false
permissions=

[vpn]
gateway=vin.mobilewaves.com
password-flags=1
refuse-chap=yes
refuse-eap=yes
refuse-pap=yes
user=
service-type=org.freedesktop.NetworkManager.sstp

[ipv4]
dns-search=
method=auto

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto

[proxy]

EOF
chmod 600 /etc/NetworkManager/system-connections/*

cat > /usr/local/bin/mws-port-knock <<EOF
#!/bin/bash

knock -d 333 88.203.233.4 5001:udp 17011:udp 45011:tcp

EOF
chmod a+x /usr/local/bin/mws-port-knock

cat > /usr/share/pixmaps/mws-port-knock.svg  <<EOF
<?xml version="1.0" encoding="utf-8"?><svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 111.83 122.88" style="enable-background:new 0 0 111.83 122.88" xml:space="preserve"><style type="text/css"><![CDATA[
    .st0{fill-rule:evenodd;clip-rule:evenodd;fill:#DE4C3C;}
    .st1{fill-rule:evenodd;clip-rule:evenodd;fill:#FFFFFF;}
    .st2{fill-rule:evenodd;clip-rule:evenodd;fill:#393939;}
]]></style><g><path class="st0" d="M55.72,0c20.87,13.2,39.67,19.47,55.85,17.99c2.84,57.11-18.25,90.84-55.63,104.89 C19.84,109.72-1.5,77.42,0.08,17.11C19.07,18.1,37.69,14.01,55.72,0L55.72,0L55.72,0z"/><path class="st2" d="M55.75,7.04c18.47,11.69,35.13,17.22,49.44,15.93c2.51,50.55-16.18,80.41-49.26,92.87 C24,104.19,5.09,75.62,6.49,22.23c16.81,0.88,33.29-2.76,49.26-15.15V7.04L55.75,7.04L55.75,7.04z"/><path class="st1" d="M69.65,44.01h6.81l8.88,13.05V44.01h6.88V67.6h-6.88L76.5,54.64V67.6h-6.85V44.01L69.65,44.01L69.65,44.01z M19.56,44.01h7.63l5.31,16.98l5.22-16.98h7.4L36.36,67.6h-7.89L19.56,44.01L19.56,44.01L19.56,44.01z M46.94,44.01h12.11 c2.64,0,4.61,0.62,5.92,1.89c1.31,1.25,1.97,3.05,1.97,5.35c0,2.38-0.72,4.25-2.14,5.59c-1.44,1.34-3.61,2.01-6.55,2.01h-3.99v8.75 h-7.31V44.01L46.94,44.01L46.94,44.01z M54.25,54.06h1.78c1.4,0,2.39-0.25,2.96-0.73c0.57-0.49,0.85-1.1,0.85-1.88 c0-0.74-0.25-1.37-0.74-1.89c-0.49-0.52-1.42-0.77-2.78-0.77h-2.08v5.27H54.25L54.25,54.06z"/></g></svg>
EOF

cat > /etc/udev/rules.d/90-mws-custom.rules <<EOF
#logitech Keyboard mouse
KERNEL=="hidraw*", ATTRS{idVendor}=="046d", MODE="0666"

EOF

sed -i 's/#HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=suspend/' /etc/systemd/logind.conf
sed -i 's/#HandleSuspendKey=suspend/HandleSuspendKey=suspend/' /etc/systemd/logind.conf

#sed 's/SystemAccount=false/SystemAccount=true/' /var/lib/AccountsService/users/administrator > /var/lib/AccountsService/users/administrator
cat > /var/lib/AccountsService/users/administrator << EOF
[User]
Session=
XSession=
Icon=/home/administrator/.face
SystemAccount=false

[InputSource0]
xkb=us
EOF

cat > /etc/environment.d/90-mws.conf << EOF
MOZ_DISABLE_RDD_SANDBOX=1
MOZ_X11_EGL=1
MOZ_ENABLE_WAYLAND=1
EOF


if [ "`lshw -C system|grep version:|grep -i 'ThinkPad'|wc -l`" == "1" ]; then
#    add-apt-repository -y ppa:slimbook/slimbook
    apt -y install tlp tp-smapi-dkms

fi

#######  NEW #################
exit
apt install powertop power-profiles-daemon

cat > /etc/systemd/system/powertop.service
[Unit]
Description=Powertop tunings

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/powertop --auto-tune
ExecStartPost=/bin/sh -c 'for f in $(egrep -l "Mouse|Receiver" /sys/bus/usb/devices/*/product | sed "s/product/power\\/control/"); do echo on >| "$f"; done'

[Install]
WantedBy=multi-user.target