function run_frank()
    
    rand('twister',2131)
    randn('state',0)
    addpath('../../libraries/libsvm/');
    
    x = createSynthetic41_multiclass(400);
    y = x(:,end);
    x(:,end) = [];
    K = max(y);
    
    xTrain = x(1:100,:);
    yTrain = y(1:100,:);

    xTest = x(101:end,:);
    yTest = y(101:end,:);
    
    yTrain1 = parse(yTrain);
    yTest1  = parse(yTest);

    my_save(xTrain,yTrain1,'dataTrain.csv');
    my_save(xTest,yTest1,'dataTest.csv');
    
    options = struct();
    options.kernel      = 2; % 2 - rbf
    options.degree      = 1;
    options.gamma       = 1;
    options.C           = 100;
    options.epsilon     = 1e-9;
    options.probability = 0;
    options.nclasses    = K;
    
    net = frankhall_train(xTrain,yTrain,.5,options);
    predict = frankhall_test(xTest,net,options);
    MER = length( find ( (predict - yTest) ~= 0 ) )/length(yTest);
    fprintf(1,'Correct Classification: %f\n',1-MER)
    return

function my_save(x,y,name)
    fd = fopen(name,'w');
    for i=1:length(y)
        fprintf(fd,'%s,%s,%s\n',num2str(x(i,1),'%s'),num2str(x(i,2),'%s'),y(i));
    end
    fclose(fd);
    
    return
    
function y1 = parse(y)
    names = ['a','b','c','d','e'];
    y1 = num2str(zeros(length(y),1));
    for i = 1:max(y)
        idx = find ( y == i );
        y1(idx) = names(i);
    end
