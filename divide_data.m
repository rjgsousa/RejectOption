function [idxTrain, idxTest, K ] = divide_data( options )
    global datafeatures
    global dataclasses
    
    K = max(dataclasses)-min(dataclasses)+1;
    
    % split data
    nelements = size(datafeatures,1);
    trainSize = floor(nelements*options.trainsize);
    
    %% training and testing data indexes

    % guarantees that every class is represented
    % idxTrain = [];
    % idxTest  = [];
    % for i=1:options.nclasses
    %     idx      = find( data(:,end) == i );
    %     nelem    = floor( length(idx)*options.trainsize );
    %     idxTrain = [idxTrain; idx(1:nelem) ];
    %     idxTest  = [idxTest; idx(nelem+1:length(idx))];
    % end
    
    % idx1  = randperm(STREAM,length(idxTrain));
    % idxTrain = idxTrain(idx1);
    
    % random
    idxTrain = 1:trainSize;
    idxTest  = trainSize+1:nelements;
    
    return;
