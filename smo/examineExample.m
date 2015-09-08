function progress = examineExample(example1,xTrain,yTrain,options)
    global smomodel

    progress = true;
    
    alpha1 = smomodel.alpha( example1 );
    y1     = yTrain( example1 );
    
    if ( ( alpha1 > options.epsilon ) && ( alpha1 < options.C-options.epsilon ) &&...
         smomodel.nocache == false )
        E1 = smomodel.errorcache( example1 );
    else
        p  = my_svm_dual_test( xTrain, yTrain, xTrain(example1,:), options);
        E1 = p - y1;
    end
    r1 = E1*y1;
    
    KKTDontHold = ( ( r1 < -options.tol && alpha1 < options.C ) || ...
                    ( r1 >  options.tol && alpha1 > 0 ) );
    
    % -------------------------------------------------------------
    if ( KKTDontHold == 1 )
        nonbound       = find ( ( smomodel.alpha > options.epsilon ) & ( smomodel.alpha < options.C-options.epsilon  ) );
        numberNonBound = length( nonbound );
        
        if ( numberNonBound > 1 )
            % second choice
            example2 = secondChoice( E1, nonbound, options,xTrain,yTrain );
            if ~isnan( example2 )
                %fprintf(1,'1 :: ---------------------------->\n')
                res = takeStep(example1,example2,E1,xTrain,yTrain,options);
                if ( res == true )
                    return
                end
            end
        end
        
        % .... First Heuristic
        if numberNonBound > 0
            k   = randi(smomodel.N,1);
            idx = [ k:smomodel.N 1:k-1 ];

            for example = 1:length( idx )
                example2 = idx( example );
                if ( smomodel.alpha(example2)>options.epsilon && smomodel.alpha(example2)<options.C-options.epsilon)

                    %fprintf(1,'2:: ---------------------------->\n')
                    res = takeStep(example1,example2,E1,xTrain,yTrain,options);
                    if ( res == true )
                        return
                    end
                    
                end
            end
        end
        
        % .... Second Heuristic
        k   = randi( smomodel.N, 1 );
        idx = [k:smomodel.N, 1:k-1];

        for example = 1:smomodel.N
            example2 = idx( example );
            
            % fprintf(1,'3:: ---------------------------->\n')
            res = takeStep(example1,example2,E1,xTrain,yTrain,options);
            if ( res == true )
                return
            end
        end
    end

    progress = false;
    return
    
function example2 = secondChoice(E1,idxNonBound,options,xTrain,yTrain)
    global smomodel

    if smomodel.nocache 
        p  = my_svm_dual_test( xTrain, yTrain, xTrain(idxNonBound,:), options)';
        diff         = abs( E1 - (p-yTrain(idxNonBound) ));
    else
        diff         = abs( E1 - smomodel.errorcache( idxNonBound ) );
    end
    [v example2] = max( diff );
    example2     = idxNonBound( example2 );
    
    return
    
function progress = takeStep(example1,example2,E1,xTrain,yTrain,options)
    global smomodel
    progress = false;
    %fprintf(1,'Example1 vs. Example2: (%d,%d)\n',example1,example2);
    
    if example1 == example2, return, end
    
    alpha1 = smomodel.alpha( example1 );
    alpha2 = smomodel.alpha( example2 );
    
    y1 = yTrain( example1 );
    y2 = yTrain( example2 );
    
    if ( ( alpha2 > options.epsilon ) && ( alpha2 < options.C-options.epsilon ) &&...
         smomodel.nocache == false)
        E2 = smomodel.errorcache( example2 );
    else
        p  = my_svm_dual_test( xTrain, yTrain, xTrain(example2,:), options);
        E2 = p - y2;
    end
    
    s = y1*y2;
    
    if y1 ~= y2
        L = max(0,alpha2-alpha1);
        H = min(options.C,options.C+alpha2-alpha1);
    else
        L = max(0,alpha1+alpha2-options.C);
        H = min(options.C, alpha1+alpha2);
    end
    
    if L == H, return, end
    
    Z   = xTrain([example1 example2],:);
    K   = my_svm_kernelfunction(Z,Z,options);
    
    k11 = K(1,1);
    k12 = K(1,2);
    k22 = K(2,2);
    eta = 2*k12 - k11 - k22;

    if eta < 0
        a2 = alpha2 - y2 * ( E1 - E2 ) / eta;
        if ( a2 < L )
            a2 = L;
        elseif ( a2 > H )
            a2 = H;
        end
    else
        L1 = alpha1 + s * (alpha2 - L);
        H1 = alpha1 + s * (alpha2 - H);
        f1 = y1 * ( E1 + smomodel.bias ) - alpha1 * k11 - s * alpha2 * k12;
        f2 = y2 * ( E2 + smomodel.bias ) - alpha2 * k22 - s * alpha1 * k12;
        
        Lobj = -.5*L1*L1*k11-.5*L*L*k22-s*L1*L*k12-L1*f1-L*f2;
        Hobj = -.5*H1*H1*k11-.5*H*H*k22-s*H1*H*k12-H1*f1-H*f2;
        if ( Lobj > Hobj + options.epsilon )
            a2 = L;
        elseif ( Lobj < Hobj - options.epsilon )
            a2 = H;
        else
            a2 = alpha2;
        end
    end
    
    if a2 < 1e-8
        a2 = 0;
    elseif a2 > options.C - 1e-8
        a2 = options.C;
    end
    
    if ( abs ( a2 - alpha2 ) < options.epsilon * ( a2 + alpha2 + options.epsilon) )
        return
    end
    
    a1 = alpha1 + s * ( alpha2 - a2 );
    
    if a1 < 0
        a2 = a2 + s * a1;
        a1 = 0;
    elseif a1 > options.C
        a2 = a2 + s * (a1-options.C);
        a1 = options.C;
    end

    b1 = E1 + ...
         y1 * ( a1 - alpha1 ) * k11 + ...
         y2 * ( a2 - alpha2 ) * k12 + smomodel.bias;
    
    b2 = E2 + ...
         y1 * ( a1 - alpha1 ) * k12 + ...
         y2 * ( a2 - alpha2 ) * k22 + smomodel.bias;

    
    oldbias = smomodel.bias;
    if a1 > options.epsilon && a1 < options.C-options.epsilon
        bias = b1;
        smomodel.nonbound(example1) = 1;
    elseif a2 > options.epsilon && a2 < options.C-options.epsilon
        bias = b2;
        smomodel.nonbound(example2) = 1;
    else
        bias = (b1+b2)/2;
        smomodel.nonbound(example1) = 0;
        smomodel.nonbound(example2) = 0;
    end
    smomodel.bias = bias;
    
    % smomodel.errorcache'
    x1   = xTrain(example1,:);
    x2   = xTrain(example2,:);
    
    if smomodel.nocache == true
        for examplek = 1:smomodel.N
            member = ( ( smomodel.alpha(examplek) > options.epsilon ) && ( smomodel.alpha(examplek) < options.C-options.epsilon ));
            
            if (member && examplek ~= example1 && examplek ~= example2)
                
                xk   = xTrain(examplek,:);
                
                k1k  = my_svm_kernelfunction(x1,xk,options);
                k2k  = my_svm_kernelfunction(x2,xk,options);
                
                smomodel.errorcache( examplek ) = ...
                    smomodel.errorcache( examplek ) + ...
                    y1 * ( a1 - alpha1 ) * k1k + ...
                    y2 * ( a2 - alpha2 ) * k2k + oldbias - smomodel.bias;
            end
        end
    
        smomodel.errorcache( example1 ) = ...
            smomodel.errorcache( example1 ) + y1 * (a1 - alpha1) * k11 + y2 * (a2 - alpha2) * k12;
        if ( a1 > options.epsilon && a1 < options.C-options.epsilon )
            smomodel.errorcache( example1 ) = 0;
        end
        
        smomodel.errorcache( example2 ) = ...
            smomodel.errorcache( example2 ) + y1 * (a1 - alpha1) * k12 + y2 * (a2 - alpha2) * k22;
        if ( a2 > options.epsilon && a2 < options.C-options.epsilon )
            smomodel.errorcache( example2 ) = 0;
        end
    end
    
    if ( strcmp( options.kernel, 'linear') || ...
         ( strcmp (options.kernel,'polynomial') && options.degree==1))
        smomodel.weights = smomodel.weights + ...
            y1 * (a1 - alpha1) * xTrain(example1,:)'+...
            y2 * (a2 - alpha2) * xTrain(example2,:)';
    end
    
    smomodel.alpha( example1 ) = a1;
    smomodel.alpha( example2 ) = a2;
    
    progress      = true;
    smomodel.iter = smomodel.iter + 1;
    return
    
    
    