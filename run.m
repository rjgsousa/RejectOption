
function [best_options, roc_data] = run( folds, combinations, wr, options)
    
    options.trainsize = folds(1);
    [ idxTrain, idxTest, K ] = divide_data( options );

    options.nclasses = K;

    fprintf(1,'Doing a %d-fold Cross Validation\n',options.nfolds);
    fprintf(1,'Train size: %d\n',length(idxTrain));

    data = struct();
    data.idxTrain        = idxTrain;
    data.idxTest         = idxTest;
    
    % run models
    fprintf(1,'(START) Time: %s\n',datestr(now,'HH:MM:SS'));
    
    STARTTIME = tic;
    
    [ best_options, roc_data ] = ...
        runModels1( folds, combinations, wr, options, data );

    toc(STARTTIME);

    %for i=1:length( best_options )
    %    best_options{i};
    %end
    
    return
    
    