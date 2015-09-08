#!/usr/bin/python


fd = open('data.csv');
lines = fd.readlines();

for line in lines:
    line = line.split(',')
    line = line[:-1]
    print line
    print len(line)

fd.close()

