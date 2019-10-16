#!/bin/bash

echo
echo
echo "INFORME SOMENTE A PORÇÃO DO ENDEREÇO DE REDE EX: 192.168.0"
echo
echo
echo -n "DIGITE O IP: ==> " 
read IP
for ((i=1; i<255; i++)); do
echo $IP.$i >> lista_de_ips.txt 
done
echo
echo "O RESULTADO ESTÁ EM /tmp/$DATA-lista_de_ips.txt"
echo
