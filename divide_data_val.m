function idxVal =  divide_data_val(idxTrain,options)
    
    foldsSize = floor( length(idxTrain) / options.nfolds );
    idxVal    = [];
    
    for i=1:options.nfolds
        idx      = floor( (i-1)*foldsSize+1:i*foldsSize );
        idxVal   = [idxVal; idx];
    end
    
    return
