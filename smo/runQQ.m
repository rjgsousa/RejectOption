function [SVs,SVlab,bias,model,merror] = runQQ(dataTrain,dataTest,options)

    yTrain = dataTrain(:,end);
    dataTrain(:,end) = [];
    xTrain = dataTrain; 

    yTest = dataTest(:,end);
    dataTest(:,end) = [];
    xTest = dataTest; 
    
    model   = QQ(xTrain,yTrain,options);
    predict = QQ_test(model,xTest) ;

    SVs    = model.supportVector;
    SVlab  = sign(model.supportVectorAlphaClasses);
    bias   = model.bias;
    
    merror = mer(predict,yTest);

    
    return