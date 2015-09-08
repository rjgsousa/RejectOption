
%% Frank & Hall
%
function predict = frankhall_test( valIDX , net, options)
    global datafeatures
    x = datafeatures(valIDX,:);

    predict = [];
    for i=1:length(net)
        
        switch( options.method )
          case 'frankhall'
            predictAux = svmclassify( net{i}, x );
            
            % predictAux = svmpredict (ones(size(x,1),1), x, net{i},'-b 0');
            predict    = [predict predictAux];
          
          case 'MLP_frankhall'
            
            prob1 = sim ( net{i}, x' )';

            % prob1
            % pause
            
            predict(:,i) = prob1 > 0;
        end
    end
    % predict
    
    predict = sum(predict,2)+1;

    % predict

    return