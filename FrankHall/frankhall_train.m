
%% Frank & Hall implementation
%
function net = frankhall_train(trainIDX,wr,options)
    
    global datafeatures
    global dataclasses

    xTrain = datafeatures(trainIDX,:);
    yTrain = dataclasses(trainIDX);

    quadprog_options  = optimset('MaxIter',options.maxiter,'TolFun',options.epsilon,'TolX', options.epsilon,'Display','off');
    handle_kernel_fun = @(U,V) my_svm_kernelfunction(U, V, options);

    for i = 1:2:options.nclassesOrig-1
        ind = yTrain > i;
        y = double(ind);

        switch( options.method )
          case 'MLP_frankhall'
            global mycost
            
            y = 2*ind-1;
            
            ind = yTrain == i;

            mycost = wr*ones( 1, length(y) );
            mycost(~ind) = 1-wr;
            
            net{i} = NN_train( trainIDX, options, y );

            % #######################################
            ind = yTrain == (i+2);

            mycost = wr*ones( 1, length(y) );
            mycost(~ind) = 1-wr;
            
            net{i+1} = NN_train( trainIDX, options, y );

            
          case 'frankhall'
            ind = yTrain == i;

            weights = wr*ones(length(y),1);
            weights(~ind) = 1-wr;

            net{i} = svmtrain( xTrain , y, 'Autoscale', 0,...
                               'BoxConstraint', options.C .* weights, 'Kernel_Function', handle_kernel_fun,...
                               'QUADPROG_OPTS', quadprog_options ...
                               );

            ind = yTrain == (i+2);

            weights = wr*ones(length(y),1);
            weights(~ind) = 1-wr;
            
            net{i+1} = svmtrain( xTrain , y, 'Autoscale', 0,...
                                 'BoxConstraint', options.C .* weights, 'Kernel_Function', handle_kernel_fun,...
                                 'QUADPROG_OPTS', quadprog_options ...
                                 );
            
        
        end
        
    end
    return