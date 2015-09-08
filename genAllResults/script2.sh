#!/bin/bash


ls *.png | sed 's/.png/ '$1'/' | awk  '{ 
split($1,b,"b")
#print "echo "b[1]
print "convert -compress zip "$1".png eps2:"$1".eps"
}' | sh