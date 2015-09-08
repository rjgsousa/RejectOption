
function smo(xTrain,yTrain,options)
    global smomodel
    
    smomodel = struct();
    smomodel.N          = length(yTrain);
    smomodel.dim        = size(xTrain,2);
    smomodel.alpha      = zeros(smomodel.N,1);
    smomodel.errorcache = zeros(smomodel.N,1); 
    smomodel.bias       = 0;
    smomodel.weights    = zeros(smomodel.dim,1);
    smomodel.iter       = 0;
    smomodel.nonbound   = zeros(smomodel.N,1);
    smomodel.nocache    = true;
    
    examineAll = true;
    numChanged = 0;
    
    while( numChanged > 0 || examineAll == true )
        numChanged = 0;
        
        % examine all training points
        if ( examineAll ) 
            for example1 = 1:smomodel.N
                result     = examineExample( example1, xTrain, yTrain, options );
                numChanged = numChanged + result;
            end
            
        else  % examine only non bound

            for example1 = 1:smomodel.N
                if (smomodel.alpha(example1) > options.epsilon) & (smomodel.alpha(example1) < options.C-options.epsilon);
                    result     = examineExample( example1, xTrain, yTrain, options );
                    numChanged = numChanged + result;
                end
            end
            
        end
        
        if examineAll == true
            examineAll = false;
        elseif numChanged == 0
            examineAll = true;
        end
    end

    nonbound = find ( smomodel.alpha > options.epsilon & smomodel.alpha <options.C-options.epsilon);
    nonbound = length(nonbound);
    
    bound    = length( smomodel.alpha ) - nonbound;

    smomodel.alpha'
    fprintf(1,'Number of bound Lagrange Mult.: %d\n',bound);
    fprintf(1,'Number of nonbound Lagrange Mult.: %d\n',nonbound);
    return