
%%                          
%
function [predict prob] = frankhall_test_threshold( valIDX, net, options)
    global datafeatures
    x = datafeatures(valIDX,:);
    
    predict = [];
    k = 1;
    npoints = size(x,1);
    for i = 1:2:options.nclassesOrig-1
        predict1 = zeros(npoints,1);
        dummy = zeros(npoints,1);

        switch ( options.method )
          case 'frankhall_threshold' %----------------------------------------------------
            [predict1 acc prob1] = svmpredict ( dummy, x, net{k}, '-b 1');

            if isempty( prob1 )
                prob1 = zeros(npoints,2);
            end
            
            % prob1
            % determines in which columns is the -1 class
            ci = find( net{k}.Label == 1 );
            if ( isempty( ci ) )
                prob1 = zeros(npoints,1);
            else
                prob1 = prob1(:,ci);
            end
            
          case 'MLP_frankhall_threshold' %----------------------------------------------------
            prob1 = sim (net{k}, x')';

            ind = prob1 <= 0.5;
            predict1(  ind ) =  0;
            predict1( ~ind ) =  1;
            %prob1 = 1-prob1;
        end
        
        predict = [predict, predict1];
        
        if ( k == 1 )
            prob(:,k)    = 1 - prob1;
            probCUM(:,k) = prob1;
        else
            prob(:,k)    = (1-prob1) .* probCUM(:,k-1);
            probCUM(:,k) = prob1 .* probCUM(:,k-1);
        end
        k = k + 1;
    end
    prob(:,k) = probCUM(:,k-1);

    % probCUM
    % prob
    % sum(prob,2)
    % predict
    % predict = (sum(predict,2)+1)*2-1
    
    [v predictI] = max(prob,[],2);
    predict = (sum(predictI,2))*2 - 1;
    % pause
    % kakak

    return