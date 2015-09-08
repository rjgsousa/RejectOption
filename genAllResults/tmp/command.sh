#!/bin/bash
if [[ $# != 1 ]]; then
    echo $0 "[nn|svm]"
    exit
fi

ls syntheticII_*.pdf | sed 's/.pdf/ '$1'/' | awk  '{ 
# split($1,b,"b")
# print b[1]
print "mv -v "$1".pdf "$1"_"$2".pdf"
}' | sh
