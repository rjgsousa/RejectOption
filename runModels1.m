function [best_options, roc_data] = runModels1(folds, combinations, wr, options,data)
    global datafeatures
    global dataclasses
    global flag 
    flag   = false;
    
    nfolds = options.nfolds;
    
    % n-fold cross validation
    foldsIDX = 1:nfolds;

    idxTrainOrig = data.idxTrain;
    idxTest      = data.idxTest;
    
    options.nclassesOrig = options.nclasses;
    switch( options.method )
      case {'MLP_threshold','MLP_threshold_ensemble','MLP_weights','MLP_frankhall_threshold'}
        options.nclassesOrig = options.nclasses;
        options.nclasses = round(options.nclassesOrig/2);
      case 'MLP_frankhall'
        options.nclasses = 1;
    end
    
    
    switch( options.method )
      case {'rejoSVM','rejoNN','weights','MLP_weights','frankhall','fumera','MLP_frankhall',...
            'SOM_weights','SOM_weights_supervised','rejoSOM'}
        wrprime = wr;
      case {'threshold','MLP_threshold','MLP_threshold_ensemble','frankhall_threshold', ...
            'MLP_frankhall_threshold','SOM_threshold','SOM_threshold_supervised','rejoSOM','knn'}
        wrprime = 1;
    end
    
    roc_data = [];
    fprintf(1,'(START) Date: %s\n',datestr(now,'yyyy/mm/dd'));
    fprintf(1,'(START) Time: %s\n',datestr(now,'HH:MM:SS'));
    STARTTIME = tic;
    for z=1:length(wrprime)
        % some initializations
        best_error = inf*ones(options.nensemble,1);
        
        fprintf(1,'wr = %.2f\n',wrprime(z));

        if options.nensemble > 1
            [bootstat,featuresEns] = bootstrp(options.nensemble,[],datafeatures(idxTrainOrig,:));
        else
            featuresEns = idxTrainOrig';
        end
        
        for nensemble=1:options.nensemble
            idxTrain = featuresEns(:,nensemble);

            ens_idxTrain{nensemble}  = idxTrain;
            
            idxVal =  divide_data_val(idxTrain,options);
            
            for i=1:size(combinations,2)
                % set parameters values
                options = setParameters(i,combinations,options);

                % options.SOMconfig
                % error 
                error   = zeros(1,nfolds);
            
                for k=1:nfolds
                    % k-cross validation
                    idx = setxor(1:options.nfolds,k);

                    % get folds indexes
                    trainIDX = idxVal(idx,:);
                    trainIDX = trainIDX(:)';
                    valIDX   = idxVal(k,:);
                    
                    % get dataset real indexes
                    trainIDX = idxTrain(trainIDX);
                    valIDX   = idxTrain(valIDX);

                    switch( options.method )
                      case {'rejoSVM','rejoNN', ...
                            'weights','MLP_weights',...
                            'frankhall','MLP_frankhall','fumera','SOM_weights','SOM_weights_supervised','rejoSOM'}
                        
                        [predict, RR, ER, fail] = runSpecificModelsI(trainIDX,valIDX,wrprime(z),options);
                        
                        % performance evaluation
                        if fail
                            fprintf(1,'!Fail\n');
                            error(k) = inf;
                        else
                            if strcmp( options.method, 'fumera' ) == 0
                                error(k) = calcErrorReject(predict,valIDX,wrprime(z),options);
                            else
                                error(k) = wrprime(z)*RR+ER;
                            end
                        end
                      
                      case {'threshold','MLP_threshold','MLP_threshold_ensemble','frankhall_threshold',...
                            'MLP_frankhall_threshold','SOM_threshold','SOM_threshold_supervised','knn'}
                        
                        [predict prob net] = runSpecificModelsII(trainIDX,valIDX,wrprime(z),options);

                        if isempty( predict )
                            error(k) = 1;
                        else
                            error(k) = length(find(predict ~= dataclasses(valIDX)))/length(valIDX);
                        end
                    end
                end
                error( isinf(error) ) = [];
                %error
                perror = mean(error);
                
                % lets save the options for future use
                if perror < best_error( nensemble )
                    best_options{nensemble}  = options;
                    best_error(nensemble)    = perror;
                end
            end
        end

        for nensemble=1:options.nensemble
            if isempty( combinations )
                best_options{nensemble} = options;
            else
                % fprintf(1,'(%d) best config: SOM config: %d %d\n',...
                %         nensemble, ...
                %         best_options{nensemble}.SOMconfig(1), ...
                %         best_options{nensemble}.SOMconfig(2) );
            end
        end
        
        
        %% Results for Test data.
        switch( options.method )
          case {'rejoSVM','rejoNN','weights','MLP_weights','frankhall','MLP_frankhall','fumera',...
                'SOM_weights','SOM_weights_supervised','rejoSOM'}
            % best_options{1}.test = true;
            
            predict = zeros( length(idxTest), options.nensemble );
            for nensemble=1:options.nensemble
                [ predict(:,nensemble), RR, ER, fail ]  = ...
                    runSpecificModelsI(ens_idxTrain{nensemble},idxTest,wr(z),best_options{nensemble});
            end
            predict = mode(predict,2);
            
            if strcmp( options.method, 'fumera' ) == 0
                [error, RR, ER ] = calcErrorReject(predict,idxTest,wr(z),best_options{1});
            end

            if ~fail
                roc_data = [roc_data; RR ER 0 0 wr(z)];
            else
                fprintf(1,'!!Fail\n');
            end
          
          case {'threshold','MLP_threshold','MLP_threshold_ensemble','frankhall_threshold','MLP_frankhall_threshold',...
                'SOM_threshold','SOM_threshold_supervised','knn'}
            roc_data = runSpecificModelsIII( ens_idxTrain, idxTest, wr, best_options, roc_data);
        end
    end

    toc(STARTTIME);
    
    roc_data
    
    return;

%%                                                                                                              
%
function options = setParameters(i,combinations,options)
% fprintf(1,'C: %.4d | gamma: %.4d\n',combinations(1,i),combinations(2,i));
% special options
    switch ( options.method ) 
      case 'rejoSVM'
        switch( options.kernel )
          case 'linear'
            options.C     = combinations(1,i);
            options.h     = combinations(2,i);
            options.s     = combinations(3,i);
          otherwise
            options.C     = combinations(1,i);
            options.gamma = combinations(2,i);
            options.h     = combinations(3,i);
            options.s     = combinations(4,i);
        end
        % fprintf(1,'Testing: C: %.4f | gamma: %.4f | h: %.4f | s: %.4f\n',...
        %         options.C,options.gamma,options.h,options.s);
        
      case {'threshold','weights','frankhall','frankhall_threshold'}
        switch( options.kernel )
          case {'linear',0}
            options.C     = combinations(1,i);
            options.gamma = 1;
          otherwise
            options.C     = combinations(1,i);
            options.gamma = combinations(2,i);
        end
        
      case {'SOM_threshold','SOM_threshold_supervised'}
        options.SOMconfig  = combinations(1:2,i);
        options.ratio      = combinations(3,i);
        switch( options.rejectSOMmethod )
          case 'parzen'
            options.gamma      = combinations(4,i);
        end
        
      case {'SOM_weights','SOM_weights_supervised'}
        options.SOMconfig = combinations(1:2,i);
        switch( options.rejectSOMmethod )
          case 'parzen'
            options.gamma     = combinations(3,i);
        end
        
      case 'rejoSOM'
        options.SOMconfig  = combinations(1:2,i);
        options.h     = combinations(3,i);
        options.s     = combinations(4,i);
        
      case 'fumera'
        options.C     = combinations(1,i);
        
      case {'MLP_threshold','MLP_threshold_ensemble','MLP_weights','MLP_frankhall_threshold','MLP_frankhall'}
        options.nneurons = combinations(1,i);
        options.nlayers  = combinations(2,i);
        
      case 'rejoNN'
        options.nneurons = combinations(1,i);
        options.nlayers  = combinations(2,i);
        options.h        = combinations(3,i);
        options.s        = combinations(4,i);
        
      case 'knn'
        options.k        = combinations(1,i);
    end
    return
    
%%                                                                                                     
%
function [predict RR ER fail] = runSpecificModelsI(trainIDX,valIDX,wr,options)
    fail = 0; RR = 0; ER = 0; predict = 0;
    

    switch( options.method )
      case 'rejoSVM'
        options.wr = wr;

        osvm_model = oSVM_train( trainIDX, options, options.optimization);
        predict    = oSVM_test ( osvm_model, valIDX)';
        
      case 'weights'
        weights_model = trainModels(trainIDX, wr, options);
        predict       = testModels(valIDX, weights_model, options);
        
      case 'MLP_weights'
        net     = NN_trainModels( trainIDX, wr, options);
        predict = NN_testModels ( valIDX, net, options );

      case 'rejoNN'
        options.wr = wr;
        net     = oNN_train( trainIDX, options );
        predict = oNN_test( valIDX, net, options)';    
        
      case {'frankhall','MLP_frankhall'}
        net     = frankhall_train( trainIDX, wr, options );
        % classVal'
        predict = frankhall_test( valIDX, net, options );

      case 'fumera'
        [RR ER fail] = fumera( trainIDX, valIDX, wr, options );
        if fail, return, end
        
      case 'rejoSOM'
        INCOMPLETE
        options.wr = wr;
        som_model = rejoSOM_train( trainIDX, options );
        predict   = rejoSOM_predict( som_model, valIDX )';
        
      case {'SOM_weights','SOM_weights_supervised'}
        som_model = trainModels( trainIDX, wr, options );
            
        % x = linspace(0,1,100);
        
        % [X Y] = meshgrid(x,x);
        % dataTest = [X(:) Y(:)];
        % [predict] = testModels(dataTest,som_model,options,wr);
        
        % %plot_features( [dataTest,predict] )
        % dlmwrite( 'som_weights.csv',[dataTest,predict] )
        
        % IND = classTrain == 1;
        % figure
        % plot(dataTrain(IND,1),dataTrain(IND,2),'+r'), hold on
        % plot(dataTrain(~IND,1),dataTrain(~IND,2),'ob'), hold on
        % som_grid(som_model{1}.net,'Coord',som_model{1}.net.codebook)

        % figure
        % plot(dataTrain(IND,1),dataTrain(IND,2),'+r'), hold on
        % plot(dataTrain(~IND,1),dataTrain(~IND,2),'ob'), hold on
        % som_grid(som_model{2}.net,'Coord',som_model{2}.net.codebook)

        % kkk
            
        predict   = testModels( valIDX, som_model, options, wr );
        
        
    end
    
    return

%%                                                                                                     
%
function [predict prob net] = runSpecificModelsII(trainIDX,valIDX,wr,options);
    net                 = runSpecificmodelsIIa(trainIDX,wr,options);
    [predict acc prob ] = runSpecificmodelsIIb(valIDX,net,options);
    return
    
    
%%                                                                                                     
%
function net = runSpecificmodelsIIa( trainIDX, wr, options )
    global datafeatures
    global dataclasses
    
    nElem = length(trainIDX);
    
    switch( options.method )
      case 'knn'
        kdtreeNS = KDTreeSearcher(datafeatures(trainIDX,:));
        net = {kdtreeNS, trainIDX};

      case 'threshold'
        configStr = sprintf('-s 0 -t %d -d %d -r 1 -g %d -c %d -e %d -b %d -m %d -q',...
                            options.kernel,options.degree,options.gamma,options.C,...
                            options.epsilon,options.probability,options.workmem);
        net       = svmtrain(dataclasses(trainIDX), datafeatures(trainIDX,:), configStr);
        
      case {'MLP_threshold','MLP_threshold_ensemble'}
        options.wr = wr;
        global mycost
        mycost         = ones(1,nElem);
        net            = NN_train(trainIDX, options);
      
      case 'frankhall_threshold'
        net = frankhall_train_threshold( trainIDX, options );
    
      case 'MLP_frankhall_threshold'
        options.wr = wr;
        global mycost
        mycost = ones(1,nElem);
        net    = frankhall_train_threshold( trainIDX, options );
    
      case {'SOM_threshold','SOM_threshold_supervised'}
        global mycost
        mycost = ones( 1, nElem );

        data = datafeatures( trainIDX, : );
        y    = dataclasses(trainIDX);
        
        if strcmp(options.method, 'SOM_threshold') == 1
            net = somtrain( data, y, options );

            % net.net
            % net.net.topol
            
            % IND = y == 1;
            % plot(data( IND,1),data( IND,2),'+r'), hold on
            % plot(data(~IND,1),data(~IND,2),'ob'), hold on
            % som_grid(net.net,'Coord',net.net.codebook)
            % kkk

        elseif strcmp(options.method, 'SOM_threshold_supervised')==1
            K = options.nclasses;
            [dlen,dim] = size(data);
            newy = zeros(dlen,K);
            
            % 1 of k coding
            newy(sub2ind([dlen K], (1:dlen)', y)) = 1;

            net = somtrain( [data, newy], y, options, 2 );
            net = somRemoveExtraDims(net,options);
            
            % IND = y == 1;
            % plot( data( IND,1), data( IND,2),'+r' ), hold on
            % plot( data(~IND,1), data(~IND,2),'ob' )

            % w = net.net;
            % plot(w(:,1),w(:,2),'xk')

        end
            
    end
    
    return
    
    
%%                                                                                                     
%
function [predict acc prob] = runSpecificmodelsIIb(valIDX,net,options)
    global datafeatures
    global dataclasses
    
    acc = 0;
    nElem = length( valIDX );
    prob  = zeros(nElem,1);
    
    switch (options.method)
      case 'knn'
        d = knnsearch(net{1},datafeatures(valIDX,:),'k',options.k);
        trainIDX = net{2} ;
        res = dataclasses(trainIDX(d(:)));
        res = reshape(res,nElem,options.k);

        predict = mode(res,2);

        for i=1:nElem
            prob(i) = calcEntropy(res(i,:),options);
        end
        
      case 'threshold'
        [predict acc prob] = svmpredict (dataclasses(valIDX), datafeatures(valIDX,:), net,'-b 1');

      case {'MLP_threshold','MLP_threshold_ensemble'}
        [predict prob] = NN_test( valIDX, net, options );
      
      case {'frankhall_threshold','MLP_frankhall_threshold'}
        [ predict prob ] = frankhall_test_threshold( valIDX, net, options);
    
      case {'SOM_threshold','SOM_threshold_supervised'}
        [predict prob] = sompredict( valIDX, net, options );
    end

    return
    
    
%%
%
function roc_data = runSpecificModelsIII( ens_trainIDX, testIDX, wr, ens_best_options, roc_data )
    global dataclasses
    classTest  = dataclasses(testIDX);

    predict = zeros(length(ens_trainIDX{1}),ens_best_options{1}.nensemble);
    for nensemble=1:ens_best_options{1}.nensemble
        trainIDX     = ens_trainIDX{nensemble};
        best_options = ens_best_options{nensemble};
        
        [predict(:,nensemble) prob{nensemble} net{nensemble}] = ...
            runSpecificModelsII( trainIDX, trainIDX, wr, best_options);
    end
    
    switch( ens_best_options{1}.method )
      case 'MLP_threshold_ensemble'
        predict
    end
    %kkk;
    
    
    P_train  = predict;
    % PA_train = prob(:,1);
    % PB_train = prob(:,2);

    for i=1:length(wr)
            
        for nensemble=1:ens_best_options{1}.nensemble
            trainIDX     = ens_trainIDX{nensemble};
            classTrain   = dataclasses(trainIDX);
            best_options = ens_best_options{nensemble};

            best_error     = inf;
            best_threshold = 0;

            for threshold = 0.50:0.01:1.
                % Process to find out points belonging to the reject region
                irej = calc_rej(threshold,prob{nensemble});
                
                RR   = sum(irej)/length(trainIDX);
                idx  = ~irej;
                
                trueClass = classTrain(idx);
            
                predictOutOfReject = P_train(idx,nensemble);
                
                erro = find( trueClass ~= predictOutOfReject );
                ER   = length(erro) / length(classTrain);
                
                % Performance evaluation
                performance = wr(i)*RR+ER;
                
                if ( (performance < best_error) && (RR ~= 0) )
                    best_error     = performance;
                    best_threshold = threshold;
                end
            end
            ens_best_options{nensemble}.best_threshold = best_threshold;
        end
        
        % With the best model and threshold, we analize the
        % error/rejection on test data
        % dataTrain,classTrain,dataVal,classVal,wr,options
        
        predict = zeros(length(testIDX),ens_best_options{1}.nensemble);
        for nensemble=1:ens_best_options{1}.nensemble
            [ pred acc prob_est] = runSpecificmodelsIIb( testIDX, net{nensemble}, ens_best_options{nensemble});
        
            irej   = calc_rej( ens_best_options{nensemble}.best_threshold, prob_est );
            
            pred( irej) = 2;

            predict(:,nensemble) = pred;
        end
        
        if ens_best_options{1}.nensemble > 1
            predict = mode(predict,2);
        end
        
        irej = ~mod(predict,2);
        
        RR  = sum(irej)/length(testIDX);
        idx = ~irej;
        
        trueClass          = classTest(idx);
        predictOutOfReject = predict(idx);
        
        erro = find(trueClass ~= predictOutOfReject);
        ER   = length(erro)/ length(classTest);

        roc_data= [roc_data; RR ER 0 0 wr(i) best_threshold];
    end
    
    return
    
function irej = calc_rej(threshold,prob)
    irej = max( prob, [], 2 ) < threshold;
    return

    
%%                                                                                                     
%
function net = NN_trainModels( trainIDX, wr, options )
    
    global dataclasses
    global mycost
 
    classTrain = dataclasses(trainIDX);

    i = 1;
    for j=1:2:options.nclassesOrig
        ind  = logical( classTrain == j );
        
        mycost = zeros(1,size(classTrain,1));
        
        mycost( ind  ) = 1-wr;
        mycost( ~ind ) = wr;
        
        net{i} = NN_train( trainIDX, options );
        i = i + 1;

    end

    return
    
%%                                                                               
%
function predict = NN_testModels( valIDX, net, options )
    
    predictP = zeros(length(net),length(valIDX));
    for j=1:length(net)
        predictP(j,:) = NN_test ( valIDX, net{j}, options )';
    end
    predict = testModelsAux(predictP);
    return;
    
    
%%                                                                               
%
function net = trainModels( trainIDX, wr, options )
    global datafeatures
    global dataclasses
    
    switch( options.method )
      case 'weights'
        k = 1;
        for i=1:2:options.nclasses
            configStr{k} = sprintf('-s 0 -t %d -d %d -r 1 -g %d -c %d -e %d -b %d -m %d -q', ...
                                   options.kernel,options.degree,options.gamma,options.C,options.epsilon,...
                                   options.probability,options.workmem);
            for j=1:2:options.nclasses
                if j == i
                    configStr{k} = [configStr{k} sprintf(' -w%d %f',j,wr)];
                else
                    configStr{k} = [configStr{k} sprintf(' -w%d %f',j,1-wr)];
                end
            end
            
            k = k + 1;
            
        end
        
        for i=1:length(configStr)
            net{i} = svmtrain( dataclasses(trainIDX), datafeatures(trainIDX,:), configStr{i} );
        end
        
      case {'SOM_weights','SOM_weights_supervised'} % som weights ----------------------
        
        data = datafeatures( trainIDX, : );
        y    = dataclasses(trainIDX);
        
        K = options.nclasses;
        [dlen,dim] = size(data);
        
        newy = zeros(dlen,K);
        
        % 1 of k coding
        newy(sub2ind([dlen K], (1:dlen)', y)) = 1;
        
        k = 1;
        for i=1:2:K
            ind = logical( y == i );
            
            switch( options.method )
              case 'SOM_weights'
                net{k} = somtrainweights(ind,data,y,wr,options,i);
              case 'SOM_weights_supervised'
                net{k} = somtrainweights(ind,[data,newy],y,wr,options,i);
            end
            k = k + 1;
        end    
        
        
        
        % plot(x(:,1),x(:,2),'+r')
        % hold on
        % w = net{1}.net.IW{:};
        % plot(w(:,1),w(:,2),'ob')
        % w = net{2}.net.IW{:};
        % plot(w(:,1),w(:,2),'oc')
        % kk

                    
        
        % plot(x(:,1),x(:,2),'+r')
        % hold on
        % som_grid( net{1}.net, 'Coord', net{1}.net.codebook(:,1:2) )
        % som_grid( net{2}.net, 'Coord', net{2}.net.codebook(:,1:2) )
        
        % kkk
            
    end
    
    return
    
%%                                                                               
%
function predict = testModels(valIDX, net, options, wr)
    global datafeatures
    nElem    = length(valIDX);
    
    predictP = zeros( size(net,2), nElem );
    prob     = zeros( size(net,2), nElem );
    % init 
    
    switch( options.method )
      case 'weights'
    
        for i = 1:size(net,2)
            predictP(i,:) = svmpredict (ones(nElem,1), datafeatures(valIDX,:), net{i})';
        end
        
        predictP;
        predict = testModelsAux(predictP);
    
      case {'SOM_weights','SOM_weights_supervised'}
        
        switch( options.rejectSOMmethod )
          case 'probability'
            kk
            % % figure
            % % som_grid( net{1}.net, 'Coord', net{1}.net.codebook )
            % % hold on
            % % plot(dataVal(:,1),dataVal(:,2),'+r')
            
            % % figure
            % % som_grid( net{2}.net, 'Coord', net{2}.net.codebook )
            % % hold on
            % % plot(dataVal(:,1),dataVal(:,2),'+r')
            
            % prob = {};
            % for i = 1:size(net,2)
            %     [dummy prob1] = sompredict(dataVal,net{i},options);
            %     prob1 = prob1';
            %     prob{i} = prob1;
            % end

            % r  = prob{1} > prob{2};
            % r1 = sum(r,2);
            
            % ind = r1 == 1;
            % predict( ind ) = 2;
            % ind = r1 < 1;
            % predict( ind ) = 3;
            % ind = r1 > 1;
            % predict( ind ) = 1;
          
          
            % predict = predict';
          
          otherwise
            for i = 1:size(net,2)
                [predictP(i,:) prob(i,:)] = sompredict(valIDX,net{i},options);
            end
            predict = testModelsAux(predictP);

        end
    end
    
    return

%%                                                                         
%
function predict = testModelsAux(predictP)
    predict = (sum(predictP,1)/2)';
    
    % predict = zeros(1,size(predictP,2));
    % idx     = logical( zeros(size(predict)) );
    
    % for i = 1:size(predictP,1)-1
    %     classi  = predictP(i,:);
    %     classi1 = predictP(i+1,:);
            
    %     idx = idx | classi ~= classi1;
            
    % end

    % predict(~idx) = predictP(1,~idx);
    % predict(idx ) = 2;
        
    % predict = predict';
    
    return
    
%%                                                 
% 
function [merror, RR, ER]  = calcErrorReject(predict,valIDX,wr,options)
    global datafeatures
    global dataclasses
    
    % performance assessment
    % reject rate
    irej    = ~mod(predict,2);
    
    nElem   = length(valIDX);
    classes = dataclasses(valIDX);
    
    RR   = sum(irej)/nElem;
    idx  = ~irej;
    
    % misclassification rate
    trueClass          = classes(idx);
    predictOutOfReject = predict(idx);
    error              = find( trueClass ~= predictOutOfReject );

    ER   = length(error) / nElem;
    
    merror = wr*RR+ER;
    return
