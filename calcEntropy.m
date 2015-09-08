function entropy = calcEntropy( vec, options ) 
    entropy = 0;
    totalElements = length(vec);
    
    if totalElements == 0, return, end
    
    switch( options.entropy )
      case 'entropy'
        for i=1:options.nclasses
            p = sum(vec==i)/totalElements;

            if p == 0, continue, end
            
            entropy = entropy - p * log2(p);
        end
        entropy = 1-entropy;
      
      case 'gini'
        % options.nclasses
        for i=1:options.nclasses
            p = sum(vec==i)/totalElements;

            if p == 0, continue, end
            
            entropy = entropy + p*p;
        end
    
      case 'classerror'
        p = zeros(options.nclasses,1);
        for i=1:options.nclasses
            p(i) = sum(vec==i)/totalElements;
        end
        entropy = max(p);
        
    end

    return
