#!/bin/bash
for d in $(cat /home/ainacio/datas.txt)
do
echo "Executando data "$d""
curl -b /tmp/cookies http://certificado.trimania.com.br/principal.php?DtSorteio="$d"#resultado_geral_data > trimania.txt
cat trimania.txt | grep "numero" | awk '{print $3}' | cut -d ">" -f 2| cut -d "<" -f1 > resultado-"$d".txt
echo "Aguardando 10s"
sleep 10
done
