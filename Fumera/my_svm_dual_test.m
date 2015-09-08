
function predict = my_svm_dual_test(x,y,xTest,options)
    global smomodel
    
    if ( strcmp( options.kernel, 'linear') || ...
         ( strcmp (options.kernel,'polynomial') && options.degree==1))
        
        z = repmat( smomodel.weights, 1, size(xTest, 1));

        p = z .* xTest';
        p = sum(p,1) - smomodel.bias;
        
    else
        
        alpha = smomodel.alpha;
        
        ind   = alpha > options.epsilon ;

        alpha = alpha(ind);
        y     = y(ind);

        supportVectorClass = y .* alpha;
        supportVector      = x(ind,:);
        
        K = my_svm_kernelfunction(xTest,supportVector,options);
        
        z = repmat( supportVectorClass, 1, size(xTest,1) );
        p = K .* z';
        p = sum(p,2) - smomodel.bias;
    
    end
    
    idx = p > 0;
    predict( idx) =  1;
    predict(~idx) = -1;
    
    return