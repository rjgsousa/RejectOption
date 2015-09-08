#!/usr/bin/python

def parse_carcinoma(fdout,lines):
    values = ""
    j = 0
    for line in lines:
        j = j + 1;
        line = line.split('\t');
    
        # header info.. not interesting
        if j < 9:
            continue
    
        # print line

        k = 1;
        for item in line:
            if item != '' and item != '\n':
                if k > 3:
                    values = values + item + "," ;
                    # values.append( item );
                if k > 37:
                    break
                k = k + 1

        values = values + "\n";
        fdout.write(values)
        values = "";

def parse_housekeeping(fdout,lines):
    j = 0
    values = ""
    for line in lines:
        line = line.split('\t')
        if j == 0:
            j = j + 1
            continue

        k = 1;
        # print line
        for item in line:
            if item != '' and item != '\n':
                if k > 2:
                    values = values + item + ",";
                if k > 37:
                    break
                k = k + 1
        values = values + "\n";
        fdout.write(values)
        values = "";

        print line

# ----------------------------------------------------

#fd = open('CarcinomaNormalDatasetCancerResearch.txt');
#fdout = open('tumour.csv','w');

fd = open('HousekeepingCarcinomaNormal.txt');
fdout = open('normal.csv','w');

lines = fd.readlines();

#parse_carcinoma(fdout,lines);
parse_housekeeping(fdout,lines);

# closes descriptor
fd.close();
fdout.close();
