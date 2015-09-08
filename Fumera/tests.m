
function tests()
    global TIME
    warning off all
    TIME = 12341;
    
    % 81324
    merrors = [];
    cputimes = [];
    for i = 1:1 %50
        [merrors(:,i) cputimes(:,i) ] = mtests();
        TIME = TIME + 10;
    end
    merrors
    [mean(merrors,2)  std(merrors,0,2)]
    [mean(cputimes,2) std(cputimes,0,2)]

    return
    
    
function [errors, cputimes] = mtests()
    global TIME
    rand('twister',TIME); %12
    data = genDataset( 100 );

    dataTrain = data(1:20,:);
    dataTest  = data(21:end,:);

    % dataTrain = dataTest;
    H = plot_features( dataTrain );
    %return

    options = struct();
    options.tol     = 1e-3;
    options.epsilon = 1e-9;
    options.C       = 100;
    options.gamma   = 1;
    options.coef    = 1;
    options.kernel  = 'polynomial';
    options.degree  = 2;

    fprintf(1,'SMO ------------------------------------------------\n');
    t = cputime;
    [smoSV,smoSVlab,smoBIAS,smomodel,smoerror] = runSMOfumera(dataTrain,dataTest,options,H);
    smotime = cputime-t;
    fprintf(1,'CPUTIME: %.4f\n',smotime)
    smomodel.weights;
    
    qqmerror = 0; qqtime = 0;
    errors   = [qqmerror; libsvmerror; materror; smoerror];
    cputimes = [qqtime; libsvmtime; matsvmtime; smotime];

    close all
    return
    
    %--------------------------------------------------------------------
    % plot info
    plot(smoSV(:,1),smoSV(:,2)      ,'go','MarkerSize',18,'LineWidth',3);
    
    %decision boundary
    x=0:.01:1;
    
    % w'x - b
    ySMO    = (smoBIAS - smomodel.weights(1) * x )/smomodel.weights(2);
    plot(x,ySMO   ,'g-.');
    
    % hold this stuff on
    pause
    close all
    
    return