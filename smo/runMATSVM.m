
%%
%
function [SVs,SVlab,SValpha,bias,model,merror] = runMATSVM(dataTrain,dataTest,options)
    rmpath('/home/rsousa/libsvm')

    yTrain = dataTrain(:,end);
    dataTrain(:,end) = [];
    xTrain = dataTrain; 
    
    yTest = dataTest(:,end);
    dataTest(:,end) = [];
    xTest = dataTest; 
    
    handle_kernel_fun = @(U,V) my_svm_kernelfunction(U, V, options);
    model = svmtrain(xTrain, yTrain, 'Autoscale', 0,...
                     'BoxConstraint', options.C , 'Kernel_Function', handle_kernel_fun,...
                     'METHOD','SMO');
    
    SVs    = model.SupportVectors;
    [v SVsInd]   = ismember( SVs, dataTrain, 'rows' );

    SVlab   = yTrain(SVsInd,:);
    bias    = model.Bias;
    SValpha = model.Alpha;
    predict = svmclassify(model,xTest);
    
    merror = mer(predict,yTest);

    return