function [predict,prob] = oSVM_test( model, testIDX )
    global datafeatures
    
    global flag

    if flag 
        X = linspace(0,1,100);
        [X,Y] = meshgrid(X, X);
        test_data =  [X(:) Y(:)];
    else
        test_data = datafeatures(testIDX,:);
    end
    
    
    if iscell (model)
        options = model{2};
        model   = model{1};
    else
        options = model.options;
    end
    nclasses  = options.nclasses;
    
    [test_data_rep] = xreplicateData(test_data,[],options);
    
    if options.method_parameter == 1
        if length(fieldnames(model))==1
            predict_aux = -ones(length(test_data_rep),1);
        else
            predict_aux = svmclassify( model, test_data_rep );
        end
    else
        [predict_aux, prob] = my_svm_dual_test ( model, test_data_rep );
    end
    
    predictionIDX1 = logical(predict_aux == -1);
    predict_aux(predictionIDX1) = 0;

    nreplicas = length(predict_aux)/size(test_data,1);
    predict_aux_1 = reshape(predict_aux,size(test_data,1),nreplicas);
    predict = (1+sum(predict_aux_1,2))';

    return;