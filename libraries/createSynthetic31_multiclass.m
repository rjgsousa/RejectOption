
%%                                                           
%
function [data] = createSynthetic31_multiclass(nSamples)
    theta = [-inf, -5, -2.5, -1, -0.4, 0.1, 0.5, 1.1, 3, inf];
    dimension = 4;
    features = rand(nSamples, dimension);

    data = [];
    for i = 1:nSamples
        d = features(i,:);
        x = d - 0.5;
        x = prod (x);
        x = x*1000;
        %stdDev = 0.125;
        epsilon = 0;%stdDev*randn; 
        class = x + epsilon;
        class = theta > class;
        class = find(~class);
        class = size(class, 2);

        % class, 2)
        if ( mod(class, 2) == 0 )
            z  = rand;
            xx = ( x-theta(class) ) / ( theta(class+1)-theta(class) );
            if ( z < xx )
                class = class+1;
            else
                class = class-1;
            end
        end
        

        data = [data; d class];
    end 

    % for i = 1:10
    %     fprintf(1,'Class %d with %d items\n',i,length(find(data(:, ...
    %                                                       end)==i)))
    % end
    
    
    % data(:,end)'
    % plot_features(data)
    % data
    % kkk
        

    return;
