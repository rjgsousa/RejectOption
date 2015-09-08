
%% Reject run
function best_options = reject_run( options, combinations, datasetID )
% needed files
    rmpath('libraries/qpc')
    rmpath('libraries')
    rmpath('rejoSVM')
    rmpath('FrankHall')
    rmpath('somtoolbox/')
    
    switch( options.method )
      case {'SOM_weights','SOM_weights_supervised','SOM_threshold','SOM_threshold_supervised','rejoSOM'}
        if strcmp(options.SOMtoolbox,'matlab') == 1
            addpath('NeuralNetworks/');
        elseif strcmp(options.SOMtoolbox,'somtoolbox') == 1
            addpath('NeuralNetworks/')
            addpath('somtoolbox/')
        end
      otherwise
        addpath(genpath('NeuralNetworks/'))
    end
    
    addpath(options.project_lib_path)
    addpath(fullfile(options.project_lib_path,'qpc'))
    addpath('rejoSVM')
    addpath('FrankHall')
    % addpath('smo')

    if strcmp( options.method, 'rejoSVM' ) || strcmp( options.method, 'frankhall' )
        addpath('biolearning/')

    else
        rmpath(genpath('Fumera'))
        rmpath('libraries/libsvm/')
        addpath(genpath('Fumera/'))
        addpath('libraries/libsvm/')
    end
    
    
    % --------------------------------------------------------------------------------
    % screen size
    scrsz = get(0,'ScreenSize');
    
    wr      = options.wr;
    nrounds = options.nrounds;
    folds   = options.folds;
    method  = options.method;
    
    global datafeatures
    global dataclasses
    global STREAM
    
    first = true;

    switch( datasetID )
      case {'syntheticI','synthetic3_multiclass','synthetic4_multiclass','synthetic4_multiclass_R4','synthetic43_multiclass',...
            'synthetic51_multiclass','syntheticII'}
        real = false;
      case {'letter_ah','coluna','bcct_featsel','bcct_all','bcct_multiclass_featsel','lev'}
        real = true;
      otherwise
        myerror('dataset unknown.')
    end

    for NENSEMBLE = 1:length(options.nensembleAll)
        options.nensemble = options.nensembleAll(NENSEMBLE);
        
        for i = [12,16] %[5,8,12,16] % [1,5,8] %[1,5,8,12,16]

            %% resets rand seed
            STREAM = RandStream('mrg32k3a');
            RandStream.setDefaultStream(STREAM);

            m_roc1 = zeros(length(wr),nrounds);
            m_roc2 = zeros(length(wr),nrounds);
            
            for k = 1:nrounds
                roc_data = [];
                
                filename_error  = sprintf('%s%d_%c_error_tmp_results.mat',method,i,options.trial);
                filename_reject = sprintf('%s%d_%c_reject_tmp_results.mat',method,i,options.trial);

                % -------------------------------------------------------------------------
                % load datasets
                if ( first || ~real )
                    [ datafeatures, dataclasses ] = loadDataSets( options, datasetID );
                    
                else
                    n            = size(datafeatures,1);
                    idx          = randperm(STREAM,n);
                    datafeatures = datafeatures(idx,:);
                    dataclasses  = dataclasses(idx,:);
                end
                
                if strcmp( options.method, 'fumera' )
                    if first
                        dataclasses = 2*(max(dataclasses)-dataclasses)/(max(dataclasses)-min(dataclasses))-1;
                    
                        switch ( datasetID )
                          case 'syntheticI'
                            datafeatures = [datafeatures(:,1) datafeatures(:,2) datafeatures(:,1).*datafeatures(:,2)];
                          case 'syntheticII'
                            datafeatures = [ datafeatures(:,1) datafeatures(:,2) ...
                                             datafeatures(:,1).*datafeatures(:,2) ...
                                             datafeatures(:,1).^2 datafeatures(:,2).^2];
                        end
                    end
                end


                truedim = size (datafeatures, 2);
                options = setfield(options, 'trueDim', truedim);

                fprintf(1,'------------- %d round ----------------\n',k);

                %t0 = cputime;
                [best_options roc_data] = run( folds(i,:), combinations, wr, options);
                filename = ['results' options.trial '/best_options_' num2str(i)  '-'  num2str(k) '.mat'];
                fprintf(1,'Saved best options in %s\n',filename);
                save(filename,'best_options')

                %fprintf(1,'Method ''%s'' took %f seconds.\n',method,cputime-t0);

                m_roc1(:,k) = roc_data(:,1);
                m_roc2(:,k) = roc_data(:,2);
                
                RRprime = roc_data(:,1);
                ERprime = roc_data(:,2);
                
                % iterative mean
                if k == 1
                    RR = RRprime;
                    ER = ERprime;
                else
                    RR = (k-1)/k*RR + 1/k * RRprime;
                    ER = (k-1)/k*ER + 1/k * ERprime;
                end
                
                preliminarRes = [RR ER wr']

                save(filename_error , 'm_roc1')
                save(filename_reject, 'm_roc2')

            end
            
            m_roc3=std(m_roc1,0,2);
            m_roc4=std(m_roc2,0,2);
            m_roc1=mean(m_roc1,2);
            m_roc2=mean(m_roc2,2);
            
            roc_data(:,1)=m_roc1;
            roc_data(:,2)=m_roc2;
            roc_data(:,3)=m_roc3;
            roc_data(:,4)=m_roc4;
            roc_data(:,5)=wr';
            
            %save oSVM_model.mat best_model
            roc_data
            plot_roc(scrsz,roc_data,strcat(method,num2str(i),'_',options.trial),0,options);
            check_parameters(method,options.trial,i);
            %break
        end
    end % for NENSEMBLE = 1:options.nensembleAll

    return

