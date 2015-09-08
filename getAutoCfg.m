    
    
function [msize munits] = getAutoCfg( D )
    [dlen dim] = size(D);
    
    munits = ceil(5 * dlen^0.5); % this is just one way to make a guess...

    % then determine the map size (msize)
    if dim == 1, % 1-D data
        
        msize = [1 ceil(munits)]; 

    elseif dlen<2, % eigenvalues cannot be determined since there's no data

        msize = round(sqrt(munits)); 
        msize(2) = round(munits/msize(1));

    else % determine map size based on eigenvalues
        
        % initialize xdim/ydim ratio using principal components of the input
        % space; the ratio is the square root of ratio of two largest eigenvalues	
        
        % autocorrelation matrix
        A = zeros(dim)+Inf;
        for i=1:dim, D(:,i) = D(:,i) - mean(D(isfinite(D(:,i)),i)); end  
        for i=1:dim, 
            for j=i:dim, 
                c = D(:,i).*D(:,j); c = c(isfinite(c));
                A(i,j) = sum(c)/length(c); A(j,i) = A(i,j); 
            end
        end  
        % take mdim first eigenvectors with the greatest eigenvalues
        [V,S]   = eig(A);
        eigval  = diag(S);
        [y,ind] = sort(eigval); 
        eigval  = eigval(ind);
        
        %me     = mean(D);
        %D      = D - me(ones(length(ind),1),:); % remove mean from data
        %eigval = sort(eig((D'*D)./size(D,1))); 
        if eigval(end)==0 | eigval(end-1)*munits<eigval(end), 
            ratio = 1; 
        else
            ratio  = sqrt(eigval(end)/eigval(end-1)); % ratio between map sidelengths
        end
        
        % in hexagonal lattice, the sidelengths are not directly 
        % proportional to the number of units since the units on the 
        % y-axis are squeezed together by a factor of sqrt(0.75)
        msize(2)  = min(munits, round(sqrt(munits / ratio * sqrt(0.75))));
        msize(1)  = round(munits / msize(2));
        
        % if actual dimension of the data is 1, make the map 1-D    
        if min(msize) == 1, msize = [1 max(msize)]; end;
    end
    
    return;
