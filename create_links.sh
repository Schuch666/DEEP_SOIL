#!/bin/bash

files=$(ls -1 little_r/METAR_LITTLE_R_*)

for file in $files
do
   date=`echo ${file} | awk '{print substr($1,25,13)}'`
   echo linking ${file} to obs:${date}
   ln -sf ${file} obs:${date}
done
