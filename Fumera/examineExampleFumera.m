function progress = examineExampleFumera(example1,xTrain,yTrain,options)
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
    
    % KKTDontHold = ( ( r1 < -options.tol && alpha1 < options.C ) || ...
    %                 ( r1 >  options.tol && alpha1 > 0 ) );
    KKTDontHold = ( alpha1/options.C >= sqrt(2)/5 - options.epsilon ||...
                    y1 * p <= 1 + options.epsilon );
    
    % -------------------------------------------------------------
    if ( KKTDontHold == 1 )

        [example21 example22] = secondChoice( example1, E1, options,xTrain,yTrain );
        res = takeStep(example1,example21,E1,xTrain,yTrain,options);
        if ( res == true )
            return
        end
    
        res = takeStep(example1,example22,E1,xTrain,yTrain,options);
        if ( res == true )
            return
        end
    end
    
    progress = false;
    return
    
function [example21 example22] = secondChoice(example1,E1,options,xTrain,yTrain)
    global smomodel

    %E1 = my_svm_dual_test( xTrain, yTrain, xTrain(example1,:), options)'-yTrain(example1);
    %E2 = my_svm_dual_test( xTrain, yTrain, xTrain, options)'-yTrain;
    
    alphas = smomodel.alpha;
    f      = zeros(smomodel.N,1);
    % golden section search method
    % alpha1 = smomodel.alpha(example1);

    % GSSM init
    for j=1:smomodel.N
        a = min(0,alphas(j));
        b = max(alphas(j),options.C);
        
        r = (sqrt(5)-1)/2; % golden ratio

        x1 = a + (1-r)*(b-a);
        x2 = a + r*(b-a);
        for i=1:smomodel.maxiter % GSSM
            if ( yTrain(example1) == yTrain(j) )
                z = setxor(1:length(yTrain),[example1,j])
                f1 = yTrain(example1)*alphas(example1) + yTrain(j)*alphas(j);
                f2 = sum( yTrain(z).*alphas(z) );
                continue
            else
                f1 = train(x1,xTrain([example1 j],:),yTrain([example1 j]),options);
                f2 = train(x2,xTrain([example1 j],:),yTrain([example1 j]),options);
            end

            if f1 <= f2
                a  = x1;
                x1 = x2;
                x2 = a + r*(b-a);
            else
                b  = x2;
                x2 = x1;
                x1 = a + (1-r)*(b-a);
            end
            
            % if ( (abs(x1-b) < smomodel.tol2) || ...
            %      ( abs(a-x2) < smomodel.tol2) )
            %     kkk
            %     break
            % end
        end
        
        x = .5*(a-b);
        f(j)      = train(x,xTrain([example1 j],:),yTrain([example1 j]),options);
        alphas(j) = x;
        
    end
    alphas
    %f
    kkk
    
    % if smomodel.nocache 
    %     p      = my_svm_dual_test( xTrain, yTrain, xTrain, options)'
    %     diff   = abs( E1 - (p-yTrain) );
    % else
    %     diff   = abs( E1 - smomodel.errorcache );
    % end
    [V idx]  = sort(diff,'descend');
    
    example21     = idx(1);
    example22     = idx(2);
    return
    
function progress = takeStep(example1,example2,E1,xTrain,yTrain,options)
    global smomodel
    progress = false;
    % fprintf(1,'Example1 vs. Example2: (%d,%d)\n',example1,example2);
    
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
    
    
    