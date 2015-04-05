#!/bin/bash
 files=(*.jpg )
 frame=0
 for ((i=0; i<${#files[*]}; i+=9600)); do
   ls -l "${files[@]:i:100}" 
   let "frame++"
   gm montage -verbose -tile 1920x5 +frame +shadow +label \
-geometry 1x1+0+0 "${files[@]:i:9600}" `printf "frame-%5.5u.png" "$frame"`
 done
