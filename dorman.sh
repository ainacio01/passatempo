#!/bin/bash
#curl -b /tmp/cookiesdorman https://www.dormanaccounts.com/eApp/client/Statements > dorman.txt

cat dorman.txt | grep "<td>K0337" | awk '{print $2}' | cut -d ">" -f 2 | cut -d "<" -f1 > dormanExtratos.txt
for d in $(cat /home/ainacio/dormanExtratos.txt)
do
curl -b /tmp/cookiesdorman https://www.dormanaccounts.com/eApp/blob/Statement.ashx?id="$d" --output "$d".pdf
done
