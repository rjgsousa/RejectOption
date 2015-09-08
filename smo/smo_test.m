
function predict = smo_test(xTest,model)
    kernel = model.options.kernel;
    
    if ( strcmp( kernel, 'linear') || ...
         ( strcmp (kernel,'polynomial') && model.options.degree==1))
        
        z = repmat( model.weights, 1, size(xTest, 1) );
        
        p = z .* xTest';
        p = sum(p,1) - model.bias;
        
    else
        
        options            = model.options;
        supportVectorClass = model.supportVectorClass;
        supportVector      = model.smoSVs;
        
        K = my_svm_kernelfunction( xTest, supportVector, options );
        
        z = repmat( supportVectorClass, 1, size(xTest,1) );
        p = K .* z';
        p = sum(p,2) - model.bias;
        
    end
    
    idx = p > 0;
    
    predict( idx) =  1;
    predict(~idx) = -1;
    
    return