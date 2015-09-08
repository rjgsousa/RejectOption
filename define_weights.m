
%%                                    
%
function weights = define_weights(features_rep, classes_rep, classes,options)
    nclasses = options.nclasses;

    % weights - jsc definition
    weights = (1-options.wr)*ones(length(classes_rep),1);

    %find replica number
    [dummy repNumber]=max(features_rep(:,options.trueDim+1:end), [], 2);
    idx1=(dummy==0);
    repNumber(idx1)=0;
    repNumber=repNumber+1;

    %change weights
    for rr=1:nclasses-1%number of replicas

        idx = (repNumber==rr);

        classNumberToChange = rr + 1 - mod(rr, 2);

        idx2 = (classes == classNumberToChange);

        idx = and(idx,idx2);

        weights (idx) = options.wr;

    end
   
    % [weights classes classes_rep features_rep]
    % kkk

    return
