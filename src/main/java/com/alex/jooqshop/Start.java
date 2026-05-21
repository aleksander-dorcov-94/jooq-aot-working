package com.alex.jooqshop;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Start {

    static void main() {
        var grafanaLogs = """
                2026-03-17 12:01:23.042 info 2026-03-17T10:01:23.042151807Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260316000000_20260316235959_D_01.CSV, lastModified=2026-03-17T10:01:20Z]]\s
                
                2026-03-16 12:50:51.285 info 2026-03-16T10:50:51.283548968Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260315000000_20260315235959_D_01.CSV, lastModified=2026-03-16T10:50:46Z]]\s
                
                2026-03-15 11:40:49.348 info 2026-03-15T09:40:49.348203673Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260314000000_20260314235959_D_01.CSV, lastModified=2026-03-15T09:40:45Z]]\s
                
                2026-03-14 11:40:59.800 info 2026-03-14T09:40:59.799917905Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260313000000_20260313235959_D_01.CSV, lastModified=2026-03-14T09:40:56Z]]\s
                
                2026-03-13 22:03:36.846 info 2026-03-13T20:03:36.845873568Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260225000000_20260225235959_D_01.CSV, lastModified=2026-03-13T20:03:36Z], FileInfo[name=paypal/chargeback/DisputeReport_20260226000000_20260226235959_D_01.CSV, lastModified=2026-03-13T20:03:36Z], FileInfo[name=paypal/chargeback/DisputeReport_20260227000000_20260227235959_D_01.CSV, lastModified=2026-03-13T20:03:35Z], FileInfo[name=paypal/chargeback/DisputeReport_20260228000000_20260228235959_D_01.CSV, lastModified=2026-03-13T20:03:35Z]]\s
                
                2026-03-13 22:03:36.799 info 2026-03-13T20:03:36.797917397Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260225000000_20260225235959_D_01.CSV, lastModified=2026-03-13T20:03:36Z], FileInfo[name=paypal/chargeback/DisputeReport_20260226000000_20260226235959_D_01.CSV, lastModified=2026-03-13T20:03:36Z], FileInfo[name=paypal/chargeback/DisputeReport_20260227000000_20260227235959_D_01.CSV, lastModified=2026-03-13T20:03:35Z], FileInfo[name=paypal/chargeback/DisputeReport_20260228000000_20260228235959_D_01.CSV, lastModified=2026-03-13T20:03:35Z]]\s
                
                2026-03-13 22:03:36.785 info 2026-03-13T20:03:36.78510209Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260225000000_20260225235959_D_01.CSV, lastModified=2026-03-13T20:03:36Z], FileInfo[name=paypal/chargeback/DisputeReport_20260226000000_20260226235959_D_01.CSV, lastModified=2026-03-13T20:03:36Z], FileInfo[name=paypal/chargeback/DisputeReport_20260227000000_20260227235959_D_01.CSV, lastModified=2026-03-13T20:03:35Z], FileInfo[name=paypal/chargeback/DisputeReport_20260228000000_20260228235959_D_01.CSV, lastModified=2026-03-13T20:03:35Z]]\s
                
                2026-03-13 22:03:36.784 info 2026-03-13T20:03:36.782314867Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260225000000_20260225235959_D_01.CSV, lastModified=2026-03-13T20:03:36Z], FileInfo[name=paypal/chargeback/DisputeReport_20260226000000_20260226235959_D_01.CSV, lastModified=2026-03-13T20:03:36Z], FileInfo[name=paypal/chargeback/DisputeReport_20260227000000_20260227235959_D_01.CSV, lastModified=2026-03-13T20:03:35Z], FileInfo[name=paypal/chargeback/DisputeReport_20260228000000_20260228235959_D_01.CSV, lastModified=2026-03-13T20:03:35Z]]\s
                
                2026-03-13 21:55:32.254 info 2026-03-13T19:55:32.25405514Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260301000000_20260301235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260302000000_20260302235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260303000000_20260303235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260304000000_20260304235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260305000000_20260305235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260306000000_20260306235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260307000000_20260307235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260308000000_20260308235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260309000000_20260309235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260310000000_20260310235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z]]\s
                
                2026-03-13 21:55:32.251 info 2026-03-13T19:55:32.251201424Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260301000000_20260301235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260302000000_20260302235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260303000000_20260303235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260304000000_20260304235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260305000000_20260305235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260306000000_20260306235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260307000000_20260307235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260308000000_20260308235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260309000000_20260309235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260310000000_20260310235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z]]\s
                
                2026-03-13 21:55:32.238 info 2026-03-13T19:55:32.238153698Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260301000000_20260301235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260302000000_20260302235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260303000000_20260303235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260304000000_20260304235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260305000000_20260305235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260306000000_20260306235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260307000000_20260307235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260308000000_20260308235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260309000000_20260309235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z], FileInfo[name=paypal/chargeback/DisputeReport_20260310000000_20260310235959_D_01.CSV, lastModified=2026-03-13T19:55:28Z]]\s
                
                2026-03-13 12:01:00.943 info 2026-03-13T10:01:00.943119Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/DisputeReport_20260312000000_20260312235959_D_01.CSV, lastModified=2026-03-13T10:00:57Z]]\s
                
                2026-03-12 13:10:41.057 info 2026-03-12T11:10:41.055497409Z Unprocessed dispute files found: [FileInfo[name=paypal/chargeback/, lastModified=2026-03-05T08:07:42Z], FileInfo[name=paypal/chargeback/DisputeReport_20260311000000_20260311235959_D_01.CSV, lastModified=2026-03-12T11:10:36Z]]\s
                """;

        Pattern pattern = Pattern.compile("name=([^,]+)");
        Matcher matcher = pattern.matcher(grafanaLogs);

        List<String> files = new ArrayList<>();
        int totalOccurrences = 0;

        while (matcher.find()) {
            files.add(matcher.group(1));
            totalOccurrences++;
        }

        System.out.println("--- Unique Files Found ---");
        for (String fileName : files) {
            System.out.println(fileName);
        }

        System.out.println("\n--- Summary ---");
        System.out.println("Total files extracted (including retries/duplicates): " + totalOccurrences);
        System.out.println("Total unique files: " + files.size());
    }
}
