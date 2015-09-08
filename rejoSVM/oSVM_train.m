function model = oSVM_train(trainIDX,  options, qqprog)
    global datafeatures
    global dataclasses
    
    features = datafeatures(trainIDX,:);
    classes  = dataclasses(trainIDX,:);
    
    [features_rep, classes_rep classes] = xreplicateData(features,classes,options);
    % debug
    % myplot3d(features_rep,classes_rep, original);

    weights = define_weights(features_rep,classes_rep,classes,options);
    options.weights = weights;

    model   = struct();
    maxiter = options.maxiter;
    if options.method_parameter == 1

        quadprog_options = optimset('MaxIter',options.maxiter,'TolFun',options.epsilon,'TolX', options.epsilon,'Display','off');
        smo_options      = svmsmoset( 'MaxIter',2*15000,'KKTViolationLevel',.5);

        handle_kernel_fun = @(U,V) my_svm_kernelfunction(U, V, options);
        model = svmtrain( features_rep , classes_rep, 'Autoscale', 0,...
                          'BoxConstraint', options.C .* weights, 'Kernel_Function', handle_kernel_fun,...
                          'QUADPROG_OPTS', quadprog_options ...
                          );
        % 'METHOD', 'SMO', 'SMO_OPTS', smo_options ...        
        model.options = options;

    else
        model = my_svm_dual_train ( features_rep, classes_rep, options, qqprog);
        model.options = options;
    end

    return;

    
