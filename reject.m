
%% Reject main code file 
% 
% Developed by (alphabethic order): 
% - Jaime S. Cardoso
%   Professor at FEUP and Researcher at INESC Porto
% - Beatriz Barbero
%   Researcher at INESC Porto
% - Ricardo Sousa
%   PhD. Student and Researcher at INESC Porto
%  
% Code License (to be defined)
function reject(general_opt)
    
    if nargin ~= 1
        % argument sanity check
        usage();
        return;
    end

    % max num of threads
    % MaxNumCompThreads(1);

    warning off all;
    
    % debug info will be written to this file
    global filename

    
    datasetID = general_opt.datasetID;
    method    = general_opt.method;
    % ----------------------------------------------------------------------------------
    % CONFIGURATION SECTION
    % method name
    % method = 'threshold';
    
    file = ['log_',method,'_',datasetID,'.log'];
    delete( file )
    filename = fopen( file, 'w' );

    
    if ~isfield( general_opt, 'normalize' ) 
        normalize = false;
    else
        normalize = general_opt.normalize;
    end

    % C-values
    if ~isfield( general_opt, 'C' ) 
        Cvalue = -5:2:3;    %-5:2:10; %-5:2:15;
        Cvalue = 2.^Cvalue;
    else
        Cvalue = general_opt.C;
    end
    
    % Gamma values
    if ~isfield ( general_opt, 'gamma' )
        gamma  = -3:2:-1;
        gamma  = 2.^gamma; 
    else
        gamma  = general_opt.gamma;
    end

    % rejosvm specific configuration values
    if ~isfield ( general_opt, 'h' )
        h = 1:4; %3:7 - syntheticI
    else
        h = general_opt.h;
    end
    
    if ~isfield ( general_opt, 's' )
        s = [2,4];
    else
        s = general_opt.s;
    end

    % weights 
    wr     = 0.04:0.2:.48; % test values
                           % wr     = 0.04:0.04:0.48; 
                           % wr     = 0.04:0.1:0.48;
                           % wr = [ 0.0800    0.1200    0.1600    0.2000    0.2800    0.3200    0.3600    0.4000    0.4800];
    % precision 
    epsilon = 1e-5;
    
    % kernel degree
    degree  = general_opt.degree;

    % folds
    foldsx  = .05:.05:.8;
    folds   = [foldsx' 1-foldsx'];
    nfolds  = 5;
    
    % neural network options
    % number of neurons
    if ~isfield ( general_opt, 'nneurons' )
        nneurons = 5:5:10
    else
        nneurons = general_opt.nneurons;
    end
    
    % number of layers
    if ~isfield ( general_opt, 'nlayers' )
        nlayers  = 2; %1:4; %2
    else
        nlayers = general_opt.nlayers;
    end

    % number of layers
    if ~isfield ( general_opt, 'trainepochs' )
        trainepochs = 15; %1:4; %2
    else
        trainepochs = general_opt.trainepochs;
    end
    
    if ~isfield ( general_opt, 'nensembleAll' )
        nensembleAll    = 1;
    else
        nensembleAll    = general_opt.nensembleAll;
    end
    
    if ~isfield ( general_opt, 'topologyType' )
        topologyType = 'square';
    else
        topologyType = general_opt.SOMtopologyType;
    end
    
    if ~isfield ( general_opt, 'SOMcfgcv' )
        somcfgcv = true;
    else
        somcfgcv = general_opt.SOMcfgcv;
    end
    
    if ~isfield ( general_opt, 'lattice' )
        lattice = 'hextop';
    else
        lattice = general_opt.lattice;
    end

    if ~isfield ( general_opt, 'distthresh' )
        distthresh = 2;
    else
        distthresh = general_opt.distthresh;
    end

    if ~isfield ( general_opt, 'k' )
        k = 3;
    else
        k = general_opt.k;
    end
    
    % learning rate
    lr       = general_opt.learningrate; %0.05;
    entropy  = general_opt.entropy;
    
    paramRange = struct('neurons',nneurons,'layers',nlayers,'h',h,'s',s,'C',Cvalue,'gamma',gamma,'SOMcfgcv',somcfgcv)
    pause
    
    parameters = struct();
    parameters.k         = k;
    parameters.Cvalue    = Cvalue;
    parameters.gamma     = gamma;
    parameters.h         = h;
    parameters.s         = s;
    parameters.nneurons  = nneurons;
    parameters.nlayers   = nlayers;
    parameters.distthresh   = distthresh;
    parameters.nensembleAll = nensembleAll;
    
    % number of rounds
    nrounds = 50; % 100;

    % kernel type
    kerneltype = general_opt.kernel; %'linear'; 'semipolynomial';
                                     %'polynomial'; 'rbf'; 'sigmoid'

    switch (method)
      case {'rejoSVM','MLP_threshold','MLP_weights','rejoNN','fumera', ...
            'MLP_frankhall_threshold','MLP_frankhall', 'frankhall', 'MLP_threshold_ensemble'}
        kernel = kerneltype;
        
      case {'threshold','threshold_ensemble','weights','weights_ensemble','frankhall_threshold'}
        
        switch ( kerneltype )
          case 'linear'
            kernel = 0;
          case 'polynomial'
            kernel = 1;
          case 'rbf'
            kernel = 2;
          case 'sigmoid'
            kernel = 3;
        end
        
      case {'SOM_threshold','SOM_threshold_supervised','SOM_weights','SOM_weights_supervised','rejoSOM','knn'}
        kernel = '';
        
      otherwise
        fprintf(1,'error: method ''%s'' unknown\n',method);
        usage();
        return
    end

    if ( strcmp(method,'threshold') == 1 || ...
         strcmp(method,'MLP_threshold') == 1 || ...
         strcmp(method,'frankhall_threshold') == 1 || ...
         strcmp(method,'MLP_frankhall_threshold') == 1 || ...
         strcmp(method,'threshold_ensemble') == 1 )

        probability = 1;
    else
        probability = 0;
    end
    
    % -------------------------------------------------------
    % lets combine all them  
    combinations = combine_parameters( general_opt, parameters);
    method_parameter = 1;
    
    % ----------------------------------------------------------------------------------
    % specific options for the my_svm_dual_train
    options = struct('trial',general_opt.trial,'epsilon',epsilon,'method',method,'method_parameter',method_parameter); 
    options.project_lib_path = 'libraries/';
    options.fumera_path      = fullfile('Fumera','fumera_code');
    options.workmem      = 1024;
    %options.test         = false;
    options.normalize    = normalize;
    % SVM Specific Options
    options.coef         = 1;
    options.kernel       = kernel;
    options.degree       = degree;
    options.weights      = 1;
    options.wr           = wr;
    options.folds        = folds;
    options.nfolds       = nfolds;
    options.nrounds      = nrounds;
    options.probability  = probability;
    options.maxiter      = 7000;
    options.optimization = 'cplex';
    % Neural Network Specific Options
    options.learningrate = lr;
    options.trainfnt     = 'trainrp'; %trainrp
    options.errorfnt     = 'mse';
    options.trainepochs  = trainepochs;
    options.transferFcn  = general_opt.transferFcn; %tansig
    options.adaptfcn     = 'trains';   %'trainb';
    options.learnFcn     = 'learngdm'; %'learngdm';
    options.wbInitFcn    = ''; % rands, initzero
    options.layerInitFcn = 'initnw';   %'initnw'
    options.performRatio = ''; %0.5;
    options.outputsize   = 1; % don't touch
    % stuff for ensemble learning
    options.nensembleAll = nensembleAll;
    % stuff for SOM
    options.SOMtoolbox      = general_opt.SOMtoolbox;
    options.SOMconfig       = [];
    options.SOMtopologyType = topologyType;
    options.entropy       = entropy;
    options.lattice       = lattice;
    options.rejectSOMmethod = general_opt.rejectSOMmethod;
    options.SOMcfgcv      = somcfgcv;
    % Stuff to save for the models
    options.C        = [];
    options.gamma    = [];
    options.nneurons = [];
    options.nlayers  = [];
      
    if ( method_parameter == 0 && ...
         ( strcmp(options.method,'threshold') == 1||...
           strcmp(options.method,'SOM_threshold') == 1||...
           strcmp(options.method,'SOM_threshold_supervised') == 1) )
        options.nbins = 1;
    end
    
    options
    pause
    
    %message = 'Dataset division is *NOT* done equally through all classes. Dataset with 600 points.';
    %fprintf(1,'\n\n****** %s ******\n\n',upper(message));
    fprintf(1,'Using dataset ''%s'' on method ''%s'' \n', datasetID, method );
    % ----------------------------------------------------------------------------------
    % Thinner grid search
    for j = 1 %1:2

        best_options = reject_run( options, combinations, datasetID);

        break;
        
        switch( method )
          case {'MLP_threshold','MLP_weights','rejoNN'}
            break;
        end
        
        combinations = thinner_grid( best_options, filename );
        
        if j == 1
            fprintf(filename,'I will start doing a thinner grid search\n');
            fprintf(filename,'Combinations size: %d\n',size(combinations,2));
        end

    end
    
    fclose( filename );
    return

%%                                                                                         
%
function usage
    fprintf(1,'You must identify the method and datasetID\n\n');
    fprintf(1,'Usage: ./reject method datasetID\n');
    fprintf(1,'method: \n');
    fprintf(1,['\t- threshold\n'...
               '\t- rejoSVM\n'...
               '\t- weights\n'...
               '\t- MLP_threshold\n'...
               '\t- MLP_weights\n'...
               '\t- rejoNN\n'...
               '\t- frankhall\n'...
               '\t- threshold_ensemble\n'...
               '\t- weights_ensemble\n'...
               '\t- SOM_threshold\n'...
               '\t- SOM_weights\n'...
               '\t- rejoSOM\n'...
               '\n']);
    fprintf(1,'datasetID: \n');
    fprintf(1,['\t- syntheticI\n'...
               '\t- syntheticII'...
               '\n\n']);

    return

%%                                                                                         
% thinner grid parameters definition
function combinations = thinner_grid( best_options, filename )
    mmeanC     = 0;
    mmeanGamma = 0;
    mmeanh     = 0;
    mmeans     = 0;
    
    size(best_options)
    
    nmodels = size(best_options,2);
    for i=1:nmodels
        mmeanC     = mmeanC + best_options{i}.C;
        mmeanGamma = mmeanGamma + best_options{i}.gamma;

        switch( best_options{i}.method )
          case {'rejoSVM','rejoNN'}
            mmeanh     = mmeanh + best_options{i}.h;
            mmeans     = mmeans + best_options{i}.s;
        end
    end
    mmeanC     = mmeanC/nmodels;
    mmeanGamma = mmeanGamma/nmodels;
    switch( best_options{i}.method )
      case {'rejoSVM','rejoNN'}
        mmeanh     = mmeanh/nmodels;
        mmeans     = mmeans/nmodels;
    end
            
    fprintf(filename,'C values\n');
    %Cvalue = checkinterval(mminC,mmaxC);
    Cvalue = checkinterval(mmeanC,mmeanC);
    Cvalue = 2.^Cvalue;
    
    fprintf(filename,'Gamma values\n');
    %gamma = checkinterval(mminGamma,mmaxGamma);
    gamma = checkinterval(mmeanGamma,mmeanGamma);
    gamma = 2.^gamma; 
    
    h = checkinterval(mmeanh,mmeanh);
    s = checkinterval(mmeans,mmeans);
    
    combinations = combvec( Cvalue, gamma, h, s );
    return
    
%%                                                                                         
%
function combinations = combine_parameters( options, parameters)

    switch( options.method )
      case {'SOM_threshold', 'SOM_threshold_supervised', 'SOM_weights', ...
            'SOM_weights_supervised', 'rejoSOM'}
        if options.SOMcfgcv
            n = length( parameters.nneurons );
            
            if strcmp( options.SOMtopologyType, 'rectangle' ) == 1
                v = triu(ones(n,n));
            elseif strcmp( options.SOMtopologyType, 'square' ) == 1
                v = eye(n);
            else
                error('SOM topology type unknown.');
            end
            
            [I J] = find( v == 1 );
            
            parameters.nneurons = [parameters.nneurons(I); parameters.nneurons(J)];
        else
            parameters.nneurons = [];
        end
    end

    switch( options.method )
      case 'knn'
        combinations = combvec( parameters.k );
        
      case 'rejoSVM'
        switch( options.kernel )
          case 'linear'
            combinations = combvec( parameters.Cvalue, parameters.h, parameters.s );
          otherwise
            combinations = combvec( parameters.Cvalue, parameters.gamma, parameters.h, parameters.s );
        end
        
      case {'threshold','threshold_ensemble', 'weights', 'weights_ensemble', 'frankhall','frankhall_threshold'}
        switch( options.kernel )
          case 'linear'
            combinations = parameters.Cvalue;
          otherwise
            combinations = combvec( parameters.Cvalue, parameters.gamma );
        end
      
      case 'fumera'
        combinations = parameters.Cvalue;
        
      case {'MLP_threshold','MLP_threshold_ensemble','MLP_weights','MLP_frankhall_threshold','MLP_frankhall'}
        combinations = combvec( parameters.nneurons, parameters.nlayers );

      case 'rejoNN'
        combinations = combvec( parameters.nneurons, parameters.nlayers, parameters.h, parameters.s );        

      case {'SOM_threshold','SOM_threshold_supervised'}
        % , parameters.distthresh 
        switch( options.rejectSOMmethod )
          case {'weightscosts', 'somtoolboxprob', 'exprule'}
            combinations = combvec( parameters.nneurons, [1,5,10] );
          case 'parzen'
            combinations = combvec( parameters.nneurons, [1,5,10], parameters.gamma );
          otherwise
            error('*** combine_parameters *** ');
        end
        
      case {'SOM_weights','SOM_weights_supervised'}
        switch( options.rejectSOMmethod )
          case {'weightscosts', 'somtoolboxprob', 'exprule'}
            combinations = combvec( parameters.nneurons );
          case 'parzen'
            combinations = combvec( parameters.nneurons, parameters.gamma );
          otherwise
            error('*** combine_parameters *** ');
        end

      case 'rejoSOM'
        combinations = combvec( parameters.SOMcfg, parameters.h, parameters.s );

      otherwise
        str = sprintf('Method ''%s'' unknown.\n',options.method);
        error(str);
    end
