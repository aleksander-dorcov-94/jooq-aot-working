# Define the path to scan (Your User Profile)
$targetPath = "$env:USERPROFILE"

Write-Host "Scanning $targetPath... This may take a minute." -ForegroundColor Cyan

Get-ChildItem -Path $targetPath -Directory -Force -ErrorAction SilentlyContinue |
        Select-Object Name, @{
            Name = "Size(GB)"; Expression = {
                $subFolder = $_.FullName
                $size = (Get-ChildItem -Path $subFolder -Recurse -Force -ErrorAction SilentlyContinue |
                        Measure-Object -Property Length -Sum).Sum
                [math]::Round($size / 1GB, 2)
            }
        } |
        Sort-Object "Size(GB)" -Descending |
        Format-Table -AutoSize

#second script
$appDataPath = "$env:USERPROFILE\AppData"
Write-Host "Drilling into AppData..." -ForegroundColor Yellow

Get-ChildItem -Path $appDataPath -Directory -Force -ErrorAction SilentlyContinue |
        Select-Object Name, @{
            Name = "Size(GB)"; Expression = {
                $sub = $_.FullName
                $size = (Get-ChildItem -Path $sub -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                [math]::Round($size / 1GB, 2)
            }
        } | Sort-Object "Size(GB)" -Descending | Format-Table -AutoSize


# thidr script
Write-Host "AppData details" -ForegroundColor Cyan

Get-ChildItem -Path "$env:USERPROFILE\AppData" -Recurse -Directory -Force -ErrorAction SilentlyContinue |
        Select-Object FullName, @{
            Name = "Size(GB)"; Expression = {
                $size = (Get-ChildItem -Path $_.FullName -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                [math]::Round($size / 1GB, 2)
            }
        } | Sort-Object "Size(GB)" -Descending | Select-Object -First 10 | Format-Table -AutoSize


# 1. Check ProgramData (Hidden folder at C:\ProgramData)
$progData = (Get-ChildItem -Path "C:\ProgramData" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
Write-Host "ProgramData Size: $([math]::Round($progData / 1GB, 2)) GB" -ForegroundColor Yellow

# 2. Check System Restore / Shadow Copies
Write-Host "Checking System Restore Space..." -ForegroundColor Cyan
vssadmin list shadowstorage | Select-String "Used Shadow Copy Storage space"
