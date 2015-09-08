#!/usr/bin/python
# -*- coding: iso-8859-15 -*-

import sys, os, re, csv, string
from numpy import *
from pylab import *

# reads *.txt result file
def scan_dir(path,method,isEnsemble=False):
    if not os.path.exists(path):
        return 

    files = os.listdir( path )
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

        path0 = path + filename
        print 'Loading file (' + method + '):\t ' + path0
    
        dataObj = csv.reader(open(path0),delimiter=',')
        data = []
        
        for line in dataObj:
            data.append( map(lambda x: string.atof(x), line) )

        data = array(data)

        nbagg = re.search('_nensemble=(\d+)',filename)
        if nbagg == None :
            nbagg = 1
        else: 
            nbagg = int( nbagg.group(1) )

        if dataAllTrainingSizes.keys().__contains__(trainsize):
            dataAllTrainingSizes[trainsize].append( [nbagg, data ] )
        else:
            dataAllTrainingSizes[trainsize] = [ [nbagg, data ] ] 

    # print dataAllTrainingSizes
    return dataAllTrainingSizes

# ------------------------------------------------------------------------------------------------------

def svmmethods(resdir,resdir0,resdir1,resdir2,MULTICLASS):

    threshold0       = scan_dir('../../results/threshold/' + resdir0, 'threshold0' );
    threshold1       = scan_dir('../../results/threshold/' + resdir1, 'threshold1'  );
    threshold2       = scan_dir('../../results/threshold/' + resdir2, 'threshold2'  );

    weights0         = scan_dir('../../results/weights/' + resdir0, 'weights0' );
    weights1         = scan_dir('../../results/weights/' + resdir1, 'weights1'  );
    weights2         = scan_dir('../../results/weights/' + resdir2, 'weights2'  );

    rejosvm_bioinfo0 = scan_dir('../../results/rejoSVM/' + resdir0, 'rejosvm_bioinfo0' );
    rejosvm_bioinfo1 = scan_dir('../../results/rejoSVM/' + resdir1, 'rejosvm_bioinfo1' );
    rejosvm_bioinfo2 = scan_dir('../../results/rejoSVM/' + resdir2, 'rejosvm_bioinfo2' );
    
    fuzzy3            = scan_dir('../../results/fuzzy/' + resdir1 + '/fuzzy3/', 'fuzzy3' );
    fuzzy6            = scan_dir('../../results/fuzzy/' + resdir1 + '/fuzzy6/', 'fuzzy6' );
    fuzzy9            = scan_dir('../../results/fuzzy/' + resdir1 + '/fuzzy9/', 'fuzzy9' );

    fumera           = scan_dir('../../results/fumera/' + resdir, 'fumera');

    frankhall0       = scan_dir('../../results/frankhall/' + resdir0, 'frankhall0');
    frankhall1       = scan_dir('../../results/frankhall/' + resdir1, 'frankhall1');
    frankhall2       = scan_dir('../../results/frankhall/' + resdir2, 'frankhall2');

    frankhall_threshold0  = scan_dir('../../results/frankhall_threshold/' + resdir0, 'frankhall_threshold');
    frankhall_threshold1  = scan_dir('../../results/frankhall_threshold/' + resdir1, 'frankhall_threshold');
    frankhall_threshold2  = scan_dir('../../results/frankhall_threshold/' + resdir2, 'frankhall_threshold');

    if MULTICLASS:
        # multiclass
        toPlot = {
            
            '3.1SVM-1C'           : frankhall_threshold1,
            '2.1SVM-2C'           : frankhall1,
            #'0.1fuzzy3'                          : fuzzy3,
            #'0.2fuzzy6'                          : fuzzy6,
            #'0.3fuzzy9'                          : fuzzy9,
            '1.1rejoSVM'          : rejosvm_bioinfo1,
            }
    else:
        # binary
        toPlot = {
            
            '4.1Fumera'           : fumera,
            '3.1SVM-1C'           : threshold1,
            '2.1SVM-2C'           : weights1,
            '1.1rejoSVM'          : rejosvm_bioinfo1,
            }

    # '3.0(SVM) one classifier'           : frankhall_threshold0,
    # '3.1(SVM) one classifier'           : frankhall_threshold1,
    # '3.2(SVM) one classifier'           : frankhall_threshold2,
    # '2.2(SVM) two classifiers'          : frankhall2, #weights2, # ATENCAO A ISTO
    # '1.1(SVM) rejoSVM'                  : rejosvm_bioinfo1,
    # 'Frank & Hall'                   : frankhall,

    #     print toPlot
    #     kk
    return toPlot


def nnmethods(resdir,resdir0,resdir1,resdir2, MULTICLASS):

    trials = '' # 'trials/'
    method1 = 'trainreject'
    method2 = 'weightscosts'

    # -----------------------------------------------------------------------------------
    # SOM 
    SOM_base_path = ['../../results/', resdir, method1, 'hextop' , 'gini'];
    path = SOM_base_path[0] + 'SOM_threshold/' + SOM_base_path[1] + '/topology=' + SOM_base_path[3] + '/entropy=' + SOM_base_path[4] + '/nneurons=5:5:25/ratio=1_5_10/'
    SOM_threshold_entropy    = scan_dir(path, 'SOM_threshold (entropy)');

    SOM_base_path = ['../../results/', resdir, method1, 'hextop' , 'parzen'];
    path = SOM_base_path[0] + 'SOM_threshold/' + SOM_base_path[1] + '/topology=' + SOM_base_path[3] + '/' + SOM_base_path[4] + '/nneurons=5:5:25/ratio=1_5_10/'
    SOM_threshold_parzen    = scan_dir(path, 'SOM_threshold (parzen)');

    SOM_base_path = ['../../results/', resdir, method1, 'hextop' , 'somtoolboxprob'];
    path = SOM_base_path[0] + 'SOM_threshold/' + SOM_base_path[1] + '/topology=' + SOM_base_path[3] + '/' + SOM_base_path[4] + '/nneurons=5:5:25/ratio=1_5_10/'
    SOM_threshold_somtoolboxprob    = scan_dir(path, 'SOM_threshold (GMM)');

    # ----------------------
    SOM_base_path = ['../../results/', resdir, method2, 'hextop','gini'];
    path = SOM_base_path[0] + 'SOM_weights_supervised/' + SOM_base_path[1] + '/topology=' + SOM_base_path[3] + '/entropy=' + SOM_base_path[4] + '/nneurons=5:5:25/'
    SOM_weights_super_gini    = scan_dir(path, 'SOM_weights_super_gini');

    path = SOM_base_path[0] + 'SOM_weights_supervised/' + SOM_base_path[1] + '/topology=' + SOM_base_path[3] + '/parzen/'  + '/nneurons=5:5:25/'
    SOM_weights_super_parzen    = scan_dir(path, 'SOM_weights_super_parzen');

    SOM_base_path = ['../../results/', resdir, method1, 'hextop' , 'somtoolboxprob'];
    path = SOM_base_path[0] + 'SOM_weights_supervised/' + SOM_base_path[1] + '/topology=' + SOM_base_path[3] + '/' + SOM_base_path[4] + '/nneurons=5:5:25/'
    SOM_weights_super_somtoolboxprob    = scan_dir(path, 'SOM_weights_super_gmm');

    # ----------------------------------------------------------------------------------------------------
    LVQ_base_path = ['../../results/', resdir, method1, 'hextop' , 'parzen'];
    path = SOM_base_path[0] + 'LVQ_threshold/' + LVQ_base_path[1] + '/topology=' + LVQ_base_path[3] + '/' + LVQ_base_path[4] + '/nneurons=5:5:25/ratio=1_5_10/'
    LVQ_threshold_parzen    = scan_dir(path, 'LVQ_threshold (parzen)');

    LVQ_base_path = ['../../results/', resdir, method2, 'hextop','gini'];
    path = LVQ_base_path[0] + 'LVQ_weights/' + LVQ_base_path[1] + '/topology=' + LVQ_base_path[3] + '/parzen/'  + '/nneurons=5:5:25/'
    LVQ_weights_parzen    = scan_dir(path, 'LVQ_weights_parzen');

    # ----------------------------------------------------------------------------------------------------
    NN_base_path = ['../../results/', resdir, 'logsig/' , 'trainrp'];

    path = NN_base_path[0] + '/MLP_weights/' + NN_base_path[1] + trials + 'mse/' + NN_base_path[2] + NN_base_path[3] +'_epochs=15_LearningRate=/'
    NN_weights             = scan_dir(path, 'MLP_weights');

    path = NN_base_path[0] + '/MLP_threshold/' + NN_base_path[1] + trials + 'mse/' + NN_base_path[2] + NN_base_path[3] +'_epochs=15_LearningRate=/'
    NN_threshold           = scan_dir(path, 'MLP_threshold');

    path = NN_base_path[0] + '/MLP_ensemble_of_weights/' + NN_base_path[1] + trials + 'mse/' + NN_base_path[2] + NN_base_path[3] +'_epochs=15_LearningRate=/'
    NN_ensemble_of_weights   = scan_dir(path, 'MLP_ensemble_of_weights', 1);
    
    path = NN_base_path[0] + '/MLP_ensemble_of_thresholds/' + NN_base_path[1] + trials + 'mse/' + NN_base_path[2] + NN_base_path[3] +'_epochs=15_LearningRate=/'
    NN_ensemble_of_threshold = scan_dir(path, 'MLP_ensemble_of_thresholds');

    # syntheticIIIb, requires epochs=30
    
    path = NN_base_path[0] + '/MLP_frankhall_threshold/' + NN_base_path[1] + trials + 'mse/logsig/' + NN_base_path[3] +'_epochs=15_LearningRate=/'
    NN_frankhall_threshold = scan_dir(path, 'NN_frankhall_threshold');

    path = NN_base_path[0] + '/MLP_frankhall/' + NN_base_path[1] + trials + 'mse/tansig/' + NN_base_path[3] +'_epochs=15_LearningRate=/'
    NN_frankhall           = scan_dir(path, 'NN_frankhall');

    # syntheticIIIb, requires epochs=100
    # syntheticIV, requires epochs=100
    # bcct_multiclass_featsel, requires 100

    path = NN_base_path[0] + '/rejoNN/' + NN_base_path[1] + '' + 'mse/tansig/' + NN_base_path[3] +'_epochs=15_LearningRate=/'
    rejoNN   = scan_dir(path, 'rejoNN') 

    rejosvm_bioinfo0 = scan_dir('../../results/rejoSVM/' + resdir0, 'rejosvm_bioinfo0' );
    rejosvm_bioinfo1 = scan_dir('../../results/rejoSVM/' + resdir1, 'rejosvm_bioinfo1' );
    rejosvm_bioinfo2 = scan_dir('../../results/rejoSVM/' + resdir2, 'rejosvm_bioinfo2' );
    
    fumera           = scan_dir('../../results/fumera/' + resdir, 'fumera');

    if MULTICLASS:
        toPlot = {
            # multiclass
            
            '1.1rejoNN'           : rejoNN,
            '3.2MLP-1C'           : NN_frankhall_threshold,
            '2.2MLP-2C'           : NN_frankhall, #weights2, # ATENCAO A ISTO
            }
    else:
        toPlot = {
            #'1.1rejoSVM'                                  : rejosvm_bioinfo0,
            ## binary
            # '3.1(ROSOM-1C) Parzen'             : SOM_threshold_parzen,
            # '3.2(ROSOM-1C) Gini'               : SOM_threshold_entropy,
            # '3.3(ROSOM-1C) GMM'                : SOM_threshold_somtoolboxprob,
            # '3.4(ROLVQ-1C) Parzen'             : LVQ_threshold_parzen,
            
            '3.1(ROSOM-2C) Parzen' : SOM_weights_super_parzen,
            '3.2(ROSOM-2C) Gini'   : SOM_weights_super_gini,
            '3.3(ROSOM-2C) GMM'    : SOM_weights_super_somtoolboxprob,
            '3.4(ROLVQ-2C) Parzen' : LVQ_weights_parzen,
            
            # ***************************************************************
            #'1.1rejoNN'            : rejoNN,
            #'4.1MLP-1C'            : NN_threshold,
            '4.0MLP-2C'            : NN_weights,

            #'2.2(MLP) ens. two classifiers'           : NN_ensemble_of_weights,
            #'2.2(MLP) ens. one classifiers'           : NN_ensemble_of_threshold,

            '5.0(SVM) Fumera'                : fumera
            }
        
    return toPlot
