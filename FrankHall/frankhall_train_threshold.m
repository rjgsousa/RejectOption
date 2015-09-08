
%%                    
%
function net = frankhall_train_threshold( trainIDX, options )
        
    global datafeatures
    global dataclasses

    xTrain = datafeatures(trainIDX,:);
    yTrain = dataclasses(trainIDX);


    k = 1;
    classTrainAux = zeros(length(yTrain),1);

    net = cell(1,round(length(options.nclasses)/2));
    for i = 1:2:options.nclassesOrig-1
        
        ind = yTrain > i;
        y   = double(ind);

        switch( options.method )
          case 'frankhall_threshold'
            configStr = sprintf('-s 0 -t %d -d %d -r 1 -g %d -c %d -e %d -b %d -m %d -q',...
                                options.kernel,options.degree,options.gamma,options.C,...
                                options.epsilon,options.probability,options.workmem);
          
            net{k}     = svmtrain( classTrainAux, xTrain, configStr );

          case 'MLP_frankhall_threshold'
            options.nclasses = 1;
            net{k} = NN_train( trainIDX, options, y );
        end
        
        k = k + 1;
    end
    return
        
