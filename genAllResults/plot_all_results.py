#!/usr/bin/python
# -*- coding: iso-8859-15 -*-

import sys, os, re, csv, string
from methods import *
from numpy import *
from pylab import *

# author: Ricardo Sousa
# rjgsousa@gmail.com

# http://colorbrewer2.org/

project_colors    = ['#9696ff','#ff9600', '#969600','#969696','#005500','#550000','#009555','#259535','#ff0000','#00ff00','#0000ff','#000000']
project_markers   = ['d','o','v','<','>','^','d','o','v']
project_linestyle = ['-','-.',':']
project_edgecolor = ['#000000']

# usage
def usage(name):
    print name + " method dataset "
    print """
method:
\t - svm
\t - nn

dataset:
\t - syntheticI
\t - syntheticII
\t - bcct
\t - ..."""
    sys.exit()

def myreverse(mlist):
    newlist = []
    idx = range(len(mlist)-1,-1,-1);
    for i in idx:
        newlist.append(mlist[i])

    return newlist

def parse(name,data):
    str_t = '{0:40}'.format(name)
    
    RR   = data[:,0]
    ER   = 1-data[:,1]

    zipped = zip(RR,ER)
    zipped =  myreverse(zipped)

    for elem in zipped:
        str_t = str_t + ' & {0:.2f} & {1:.2f}'.format(elem[0],elem[1])
    print str_t

    
# loads datasets
def loadDataset(name,method,dataset):
    try:
        resdir = {
            # synthetic datasets
            # binary
            'syntheticI': ('syntheticI/',0),
            'syntheticII': ('syntheticII/',0),

            # multiclass
            'syntheticIII01': ('synthetic4_multiclass/datasetsize=400/',1),
            'syntheticIII02': ('synthetic4_multiclass_R4/datasetsize=400/',1),

            'syntheticIII01_1000': ('synthetic4_multiclass/datasetsize=1000/',1,'dataset1','dataset1'),
            'syntheticIII02_1000': ('synthetic4_multiclass_R4/datasetsize=1000/',1,'dataset2','dataset2'),

            'syntheticIIIa': ('synthetic41_multiclass/datasetsize=400/',1),
            'syntheticIIIb': ('synthetic43_multiclass/datasetsize=400/',1,'syntheticIII','syntheticIII'),

            'syntheticIV'  : ('synthetic51_multiclass/',1),
            
            # real dataset 
            # binary
            'bcct'         : ('bcct/',0),
            'bcct_featsel' : ('bcct_featsel/',0,'bcct binary','bcct_binary'),
            'letter_ah'    : ('letter/letter_ah/',0,'letter A vs. H','letter_ah'),
            'coluna'       : ('coluna/',0,'Vertebral Column','spine'),

            # multiclass
            'bcct_multiclass'         : ('bcct_multiclass/',1),
            'bcct_multiclass_featsel' : ('bcct_multiclass_featsel/',1,'bcct_multiclass','bcct_multiclass'),
            'lev'                     : ('lev/',1),
            }[dataset]
    except KeyError:
        usage(name)
        return -1
    
    MULTICLASS = resdir[1]
    if resdir.__len__() == 2:
        mtitle = None
        databasenameaux = dataset
    elif resdir.__len__() == 4:
        mtitle = resdir[2]
        databasenameaux = resdir[3]
    else :
        sys.exit()
    
    resdir = resdir[0]
    
    
    resdir2 = resdir + 'polynomial_degree=2/';
    resdir1 = resdir + 'linear/';
    resdir0 = resdir + 'rbf/';

    resdir1 = resdir1;

    print resdir1

    # resdir0 = resdir

    # # lixo = '../'
    # # rejosvm1  = scan_dir( path );

    if method == 'SVM':
        toPlot = svmmethods(resdir,resdir0,resdir1,resdir2,MULTICLASS)

    elif method == 'NN':
        toPlot = nnmethods(resdir,resdir0,resdir1,resdir2,MULTICLASS)
    else:
        print "Method " + method + " unknown."
        sys.exit()
    
    return (toPlot,mtitle,databasenameaux)

# --------------------------------------------------------------------------
# plot data
def plotData( toPlot, mtitle, dataset,databasenameaux ):
    wr = map(lambda x: str(x/100.), range(4,50,4))
    keynames = toPlot.keys()
    keynames.sort()

    #subtitle = [' (5%)', ' (10%)', ' (15%)', ' (20%)', ' (25%)', ' (30%)', ' (35%)', ' (40%)', ' (45%)', ' (50%)', ' (55%)', ' (60%)', ' (65%)', ' (70%)', ' (75%)', ' (80%)' ]
    #subtitle = {0:' (5%)', 4: ' (25%)', 7: ' (40%)', 11: ' (60%)', 15: ' (80%)' }
    #subtitle = { 4: ' (25%)', 7: ' (40%)', 11: ' (60%)', 15: ' (80%)' }
    
    #subtitle = {0:' (5%)', 4: ' (25%)', 7: ' (40%)'}
    #subtitle = {0:' (5%)', 4: ' (25%)', 7: ' (40%)', 15: ' (80%)'}
    subtitle = {  11: ' (60%)', 15: ' (80%)'}

    params = {'font.family'    : 'serif'}
    rcdefaults()
    rcParams.update(params)

    for k in sort( subtitle.keys() ): #range(0,3):
        print "-------------------------------------------"

        xmin = inf
        xmax = -inf
        ymin = inf
        ymax = -inf

        color_count     = 0
        marker_count    = 0
        linestyle_count = 0

        h = figure(figsize=(12,10),dpi=100)

#         keynamesFinal = [''];
#         plot( 0.2*ones((100),int), linspace(0,1,100),
#               color           = '#BD0026',
#               linestyle       = project_linestyle[0],
#               linewidth       = 4,
#               markersize      = 16 )

        keynamesFinal = [];

        for i in keynames:
            print i + ": " + str(k)

            try:
                dataO = toPlot[i][k+1] #toPlot[i]
            except:
                dataO = None
                
            if dataO == None: 
                continue

            for ncomponent in range(0,dataO.__len__()):

                ncomp  = dataO[ncomponent][0]
                data   = dataO[ncomponent][1]
                
                print data, ncomp
            
                keyname = i[3:len(i)]

                parse(keyname, data)
                
                if ncomp > 1:
                    keyname = keyname + ", ncomp=" + str(ncomp)
                keynamesFinal.append(keyname) 

                RR   = data[:,0]
                ER   = data[:,1]

                if min(RR) < xmin:
                    xmin = min(RR)
                if max(RR) > xmax:
                    xmax = max(RR)

                if min(1-ER) < ymin:
                    ymin = min(1-ER)
                if max(1-ER) > ymax:
                    ymax = max(1-ER)

                color = project_colors[color_count] #string.lower('#'+project_colors[color_count])

                plot( RR, 1-ER, 
                      color           = color,
                      marker          = project_markers[marker_count],
                      markerfacecolor = color,
                      markeredgecolor = project_edgecolor[0],
                      markeredgewidth = 1.5,
                      linestyle       = project_linestyle[0],
                      linewidth       = 4,
                      markersize      = 16 )
                if i == '(SVM) rejoSVM':
                    for j in range(0,len(wr)):
                        x = 0; y = 0;
                        if dataset == 'syntheticI':
                            x = -0.05;
                            y = +0.005;
                        elif dataset == 'syntheticII':
                            x = +0.01;
                            y = 0;

                    #text(RR[j]+x,1-ER[j]+y,wr[j],fontsize=10,color='#000000')
                color_count     = color_count + 1
                marker_count    = marker_count + 1
                linestyle_count = linestyle_count + 1

                if color_count == len(project_colors):
                    color_count = 0
                if marker_count == len(project_markers):
                    marker_count = 0
                if linestyle_count == len(project_linestyle):
                    linestyle_count = 0

        
    
        print keynamesFinal

        grid(alpha=0.7,linewidth=2)
        # for eye-candy. you may need to adjust this
        xlim((xmin-.02,xmax+.02))
        ylim((ymin-.02,ymax+.02))
        leg = legend( keynamesFinal, 4 ) 
        # best  	0
        # upper right 	1
        # upper left 	2
        # lower left 	3
        # lower right 	4
        # right 	5
        # center left 	6
        # center right 	7
        # lower center 	8
        # upper center 	9
        # center 	10
        # -------------------------

        fontsize = 30
        ax = gca()
        for tick in ax.xaxis.get_major_ticks():
            tick.label1.set_fontsize(fontsize)
        for tick in ax.yaxis.get_major_ticks():
            tick.label1.set_fontsize(fontsize)
        for t in leg.get_texts():
            t.set_fontsize(fontsize) 

        if mtitle == None:
            mtitlef = dataset + subtitle[k]
            datasetname = dataset
        else:
            datasetname = databasenameaux
            mtitlef = mtitle + subtitle[k]
        print mtitlef, mtitle

        title(mtitlef,fontsize=fontsize+15,verticalalignment='bottom')        
        xlabel('Reject Rate',fontsize=fontsize+5)
        ylabel('Accuracy',fontsize=fontsize+5)
        #xlim(xmax=1)
        # saves data in a file
        savefigname = 'imgs/' + datasetname + '_' + str(k) +'.svg';
        print 'Saving figure in: ' + savefigname
        savefig(savefigname,format='svg',dpi=200)


    return

# main function
def main(argv):
    if len(argv) < 3:
        usage(argv[0])
        return -1
    
    dataset = argv[2]
    
    print 'Plot Init..'
    (toPlot,mtitle,databasenameaux) = loadDataset(argv[0],string.upper( argv[1] ),dataset)
    print 'Doing the plot..'
    plotData( toPlot, mtitle, dataset,databasenameaux )
    
    return


if __name__ == "__main__":
    sys.exit( main(sys.argv) )
