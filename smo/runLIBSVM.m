function [SVs,SVlab,bias,model,merror] = runLIBSVM(dataTrain,dataTest,options)
    rmpath('/home/rsousa/libsvm')
    addpath('/home/rsousa/libsvm')

    yTrain = dataTrain(:,end);
    dataTrain(:,end) = [];
    xTrain = dataTrain; 

    yTest = dataTest(:,end);
    dataTest(:,end) = [];
    xTest = dataTest; 
    
    switch( options.kernel )
      case 'linear'
        kernel = 0;
      case 'polynomial'
        kernel = 1;
      case 'rbf'
        kernel = 2;
      otherwise
        error('....');
    end
    
    configStr = sprintf('-s 0 -t %d -d %d -g %d -r 1 -c %d -e %d',...
                        kernel,options.degree,options.gamma,options.C,options.epsilon);
    model     = svmtrain(yTrain,xTrain,configStr);

    predict   = svmpredict(zeros(length(yTest),1),xTest,model,'-b 0');

    [v SVsInd]   = ismember( full( model.SVs ), dataTrain, 'rows' );

    SVs    = xTrain(SVsInd,:);
    SVlab  = 2*(yTrain(SVsInd,:)-1)-1;
    bias   = model.rho;
    
    merror = mer(predict,yTest);
    return