
%% 
%
function [data] = createSynthetic3(nSamples)
    theta = [-inf, -0.75, 0.75, inf];
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
            z = rand;
            xx = ( x+.75 )/( .75+.75 );
            if ( z < xx )
                class = 3;
            else
                class = 1;
            end
        end

        if class == 3
           class = 2;
        end

        data = [data; d class];
    end 

    return;
