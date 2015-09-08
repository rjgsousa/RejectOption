#!/bin/bash

for i in *.png
do
    echo "$i -> $i"
    convert -resize 40% -quality 90 $i $i
done