
%% Create Synthetic Data
%
function [data] = genDataset2(nSamples)
theta = [-inf, .5 inf];
%    theta = [-inf -1.5 -1.25 -1 -.5, -0.1 0.1 0.5 1.1 inf];
    dimension = 2;
    features = rand(nSamples, dimension);
           
    data = [];
    for i = 1:nSamples
        d = features(i,:);
        x = d - 0.5;
        x = prod (x);
        x = x*10;
        stdDev  = 0.125;
        epsilon = stdDev*randn; 
        x     = x+epsilon;
        class = x;
        class = theta > class;
        class = find(~class);
        class = size(class, 2);

        data = [data; d class];
    end 
    return