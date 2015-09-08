
function tests()
    global TIME
    warning off all
    TIME = 12341;
    
    % 81324
    merrors = [];
    cputimes = [];
    for i = 1:50 %50
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
    data = genDataset2( 100 );

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
    
    % fprintf(1,'Quadprog --------------------------------------\n');
    % t = cputime;
    % [qqSV,qqSVlab,qqBIAS,qqmodel,qqmerror] = runQQ(dataTrain,dataTest,options);
    % qqtime = cputime-t;
    % fprintf(1,'CPUTIME: %.4f\n',qqtime);
    % qqweights = repmat(-qqmodel.supportVectorAlphaClasses,1,size(dataTrain,2)-1) .*qqSV;
    % qqweights = sum(qqweights,1)';
    
    fprintf(1,'LIBSVM ------------------------------------------------\n');
    t = cputime;
    [libsvmSV,libsvmSVlab,libsvmBIAS,libsvmmodel,libsvmerror] = runLIBSVM(dataTrain,dataTest,options);
    libsvmtime = cputime-t;
    fprintf(1,'CPUTIME: %.4f\n',libsvmtime);
    % libsvmweights = repmat(-libsvmmodel.sv_coef,1,size(dataTrain,2)-1) .*libsvmSV;
    % libsvmweights = sum(libsvmweights,1)';
    
    fprintf(1,'MAT ------------------------------------------------\n');
    %pause
    t = cputime;
    [matSV,matSVlab,matAlpha,matBIAS,matmodel,materror] = runMATSVM(dataTrain,dataTest,options);
    matsvmtime = cputime-t;
    fprintf(1,'CPUTIME: %.4f\n',matsvmtime);
    % matsvmweights = repmat(matAlpha,1,size(dataTrain,2)-1) .*matSV;
    % matsvmweights = sum(matsvmweights,1)';

    fprintf(1,'SMO ------------------------------------------------\n');
    %pause
    t = cputime;
    [smoSV,smoSVlab,smoBIAS,smomodel,smoerror] = runSMO(dataTrain,dataTest,options,H);
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
    plot(libsvmSV(:,1),libsvmSV(:,2),'ro','MarkerSize',12,'LineWidth',3);
    plot(matSV(:,1),matSV(:,2)      ,'bo','MarkerSize',15,'LineWidth',3);
    plot(smoSV(:,1),smoSV(:,2)      ,'go','MarkerSize',18,'LineWidth',3);
    plot(qqSV(:,1),qqSV(:,2)        ,'mo','MarkerSize',21,'LineWidth',3);
    
    %decision boundary
    x=0:.01:1;
    
    % w'x + b
    yLIBSVM = (-libsvmBIAS - libsvmweights(1) * x)/libsvmweights(2);
    % ?
    yMATSVM = (-matBIAS - matsvmweights(1) * x)/matsvmweights(2);
    % w'x - b
    ySMO    = (smoBIAS - smomodel.weights(1) * x )/smomodel.weights(2);
    % w'x + b
    yQQ     = (qqBIAS - qqweights(1) * x )/qqweights(2);
    plot(x,yLIBSVM,'r--');
    plot(x,yMATSVM,'b-');
    plot(x,ySMO   ,'g-.');
    plot(x,yQQ   ,'m-.');
    legend({'-1','1','libsvm SV','mat SV','smo SV','QQ SV','libsvm','matsvm','smo','QQ'})
    
    % hold this stuff on
    pause
    close all
    
    
    return