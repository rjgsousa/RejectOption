

function f = train(alpha,x,y,options)

    global smomodel
    
    N = length(y);
    
    x
    
    %% aplies a kernel (linear, polynomial, and so on)
    K = my_svm_kernelfunction( x, x, options );
    y = repmat(y, 1, N);
    
    %% Hmatrix calculation
    f = K.*y.*y'*alpha*alpha;
    f = sum(sum(f));
    
    f = alpha - .5*f;
    
    f = f + 0.8* options.C * smomodel.N;

    return