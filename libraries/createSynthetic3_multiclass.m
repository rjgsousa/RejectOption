
%%                                                           
%
function [data] = createSynthetic3_multiclass(nSamples)
    theta = [-inf, -1, -0.1, 0.25, 1, inf];
    theta = [-inf, -1.5, -1, -.25, 0, .25, 1, 1.5, 2 inf];
    dimension = 2;
    features = rand(nSamples, dimension);

    data = [];
    for i = 1:nSamples
        d = features(i,:);
        x = d - 0.5;
        x = prod (x);
        x = x*10;
        %stdDev = 0.125;
        epsilon = 0;%stdDev*randn; 
        class = x + epsilon;
        class = theta > class;
        class = find(~class);
        class = size(class, 2);

        if ( class == 2 )
            z  = rand;
            xx = ( x+1.5 ) / ( -1+1.5 );
            if ( z < xx )
                class = 3;
            else
                class = 1;
            end
        
        elseif ( class == 4 )
            z  = rand;
            xx = ( x+0.25 ) / ( 0.25 );
            if ( z < xx )
                class = 5;
            else
                class = 3;
            end
        
        elseif ( class == 6 )
            z  = rand;
            xx = ( x-0.25 ) / ( 1-0.25 );
            if ( z < xx )
                class = 7;
            else
                class = 5;
            end
        
        elseif ( class == 8 )
            z  = rand;
            xx = ( x-1.5 ) / ( 2-1.5 );
            if ( z < xx )
                class = 9;
            else
                class = 7;
            end
        end

        data = [data; d class];
    end 
    
    % data(:,end)'
    % plot_features(data)
        

    return;
