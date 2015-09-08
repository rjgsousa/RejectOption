#!/usr/bin/python

import os,sys,re,string,csv
from numpy import *
from pylab import *

def read_files(pathtomerge):
    files = os.listdir( pathtomerge )
    files.sort()

    res = []
    for i in range(0,len(files)):
        res0 = re.search('(\w+(\w|\W)*\.txt)',files[i])
    
        if res0 is not None:
            res.append( res0 )
    if res == None or not res:
        return

    dataAllTrainingSizes = {};
    for i in range(0,len(res)):
        filename = res[i].group(0)
        trainsize = re.search('(\d+)\_.*',filename)

        # print trainsize
        # print trainsize.group(0)
        trainsize = int( string.atof( trainsize.group(1) ) );
        # print trainsize
    
        path0 = pathtomerge + filename
        print 'Loading file:\t ' + path0
        
        dataObj = csv.reader(open(path0),delimiter=',')
        data = []
        
        for line in dataObj:
            data.append( map(lambda x: string.atof(x), line) )
            
        data = array(data)
        if dataAllTrainingSizes.keys().__contains__(trainsize):
            dataAllTrainingSizes[trainsize].append( [path0, data ] )
        else:
            dataAllTrainingSizes[trainsize] = [ path0, data ]

    return dataAllTrainingSizes



if __name__=="__main__":
    pathtomerge = sys.argv[1]
    if not os.path.exists(pathtomerge):
        sys.exit()

    wrtosave = arange(0.04,0.48,0.2)
    datatosave = read_files( pathtomerge )
    # print datatosave
    #print wrtosave

    newdata = read_files( './' )
    #print newdata


    allwr = arange(0.04,0.5,0.04)
    #print allwr

    
    figs = { 4: ' (25%)', 7: ' (40%)', 11: ' (60%)', 15: ' (80%)' }
    for k in sort( figs.keys() ):
        mergeddata = zeros((len(allwr),4))

        name = datatosave[k+1][0]
        data = datatosave[k+1][1]
        print data

        namenew = newdata[k+1][0]
        datanew = newdata[k+1][1]
        print datanew
        i = 0
        j = 0
        for pos in range(0,12):
            if pos == 0 or pos == 5 or pos == 10:
                mergeddata[pos,:] = data[i,:]
                i = i + 1
            else:
                mergeddata[pos,:] = datanew[j,:]
                j = j + 1
                
        print mergeddata
        raw_input("This will merge data from\n-> "  + namenew +  "\ninto\n-> "+ name+"\n Do you wish to continue?\n")
        savetxt(name,mergeddata,fmt='%.6f',delimiter=',')
