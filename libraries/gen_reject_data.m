function gen_reject_data()
    accept_label = 1;
    reject_label = 2;
    
    data = dlmread('hyper_n500_d2_c5_var0.txt');
    
    features = data(:,1:2);
    classes  = data(:,3);
    
    ind_review = find(classes == 3);

    %% gathers classes 1 and 2 as accept classes 
    classes_accept = [1,2];
    %% gathers classes 4 and 5 as reject classes 
    classes_reject = [4,5];
    
    ind_accept = [];
    ind_reject = [];

    for i=1:length(classes_accept)
        ind = find ( classes == classes_accept(i) );
        ind_accept = [ind_accept; ind];
    end

    for i=1:length(classes_reject)
        ind = find ( classes == classes_reject(i) );
        ind_reject = [ind_reject; ind];
    end

    %% feature data gathering
    accept = features(ind_accept,:);
    review = features(ind_review,:);
    reject = features(ind_reject,:);

    new_features = [accept, repmat(accept_label,size(accept,1),1); ...
                    reject, repmat(reject_label,size(reject,1),1)];

    %% the points in the (pseudo) review option (original class 3)
    %% will be randomly assessed to accept or reject classes
    prob = rand(length(ind_review),1);
    ind  = logical(prob >= 0.5 );
    review_class(ind)  = reject_label;
    review_class(~ind) = accept_label;
    
    review_class = review_class';
    
    new_features = [new_features;...
                    review, review_class];

    data = plot_reject_option_data(new_features);

    dlmwrite('lixo.txt',data)
    return;
    
