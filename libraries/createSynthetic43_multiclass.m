
%% Create Synthetic Data n.º 4
%
function [data] = createSynthetic43_multiclass(nSamples)
%theta = [-inf, -1, 0.25, inf];
    theta = [-inf -1.5 -1.25 -1 -.5, -0.1 0.1 0.5 1.1 inf];
    dimension = 2;
    features = rand(nSamples, dimension);
           
    data = [];
    for i = 1:nSamples
        d = features(i,:);
        x = d - 0.5;
        x = prod (x);
        x = x*10;
        stdDev = 0.125;
        epsilon = stdDev*randn; 
        x = x+epsilon;
        class = x;
        class = theta > class;
        class = find(~class);
        class = size(class, 2);

        if ( mod(class, 2) == 0 )
            z = rand;
            xx = (x-theta(class))/(theta(class+1)-theta(class));
            if (z < xx)
                class = class+1;
            else
                class = class-1;
            end
        end
        % if class == 3
        %     class = 2;
        % end
        data = [data; d class];
    end 
    
    % dlmwrite('data.csv',data)
    return