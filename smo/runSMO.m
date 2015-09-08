
%%
%
function [ SVs, SVlab, bias, model, merror ] = runSMO(dataTrain,dataTest,options,H)
    
    yTrain = dataTrain(:,end);
    dataTrain(:,end) = [];
    xTrain = dataTrain; 

    yTest = dataTest(:,end);
    dataTest(:,end) = [];
    xTest = dataTest; 
    
    maxc   = max( yTrain );
    minc   = min( yTrain );

    %yTrain = 1 - 2 * (yTrain - 1);
    yTrain = 2*(yTrain - minc) / (maxc - minc)-1;

    [yTrain idx ] = sort(yTrain);
    xTrain        = xTrain(idx,:);
    
    %% training phase
    global smomodel
    smo(xTrain,yTrain,options);
    fprintf(1,'Iterations: %d\n',smomodel.iter);
    smomodel.options = options;
    
    bias = smomodel.bias;
    ind  = smomodel.alpha > options.epsilon;
    
    SVs   = xTrain(ind, :);
    SVlab = yTrain(ind, :);
    smomodel.alpha  = smomodel.alpha ( ind );
    smomodel.smoSVs = SVs;
    smomodel.supportVectorClass = yTrain( ind ) .* smomodel.alpha;
    
    %% testing phase
    predict = smo_test( xTest, smomodel )';
    %predict = (1 - predict)/2 + 1;
    predict = (predict + 1)/2 + 1;

    merror = mer(predict,yTest);

    model = smomodel;
    
    %plot_features( [xTest, predict],H );
    return
    