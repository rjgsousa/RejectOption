
%% Create Synthetic Data n.º 4
%
function [data] = createSynthetic4_multiclass_R4(nSamples)
%theta = [-inf, -1, 0.25, inf];
    theta = [-inf, -1.25 -.5, 0.25, 1, inf];
    dimension = 4;
    features = rand(nSamples, dimension);
           
    data = [];
    for i = 1:nSamples
        d = features(i,:);
        x = d - 0.5;
        x = prod (x);
        x = x*1000;
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
        data = [data; d class];
    end 

    return