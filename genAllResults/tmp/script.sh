#!/bin/bash


ls syntheticII_*.svg | sed 's/.svg//' | awk  '{
MYSUFFIX="two"
print "echo inkscape -z --file="$1".svg --export-pdf="$1"_"MYSUFFIX".pdf --export-width=640"
print "inkscape -z --file="$1".svg --export-pdf="$1"_"MYSUFFIX".pdf --export-width=640"
#print "inkscape -z --file="$1".svg --export-pdf="$1".pdf --export-width=640"
}' | sh