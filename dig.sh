#!/bin/bash
for d in `cat /home/ainacio/dig.txt`;
do
echo *****$d*****
dig +short $d
done
