
%% data loading
%
function [trainSetFeatures,trainSetClass] = loadDataSets( options, dataset )
    trainSetFeatures = [];
    trainSetClass    = [];

    switch(dataset)
        
      case 'syntheticI'
        [trainSetFeatures,trainSetClass] = syntheticI();
        
      case 'syntheticII'
        [trainSetFeatures,trainSetClass] = syntheticII();

        %% -------------------------------------------------------
      case 'synthetic3_multiclass'
        [trainSetFeatures,trainSetClass] = synthetic3_multiclass();
        
      case 'synthetic4_multiclass'
        [trainSetFeatures,trainSetClass] = synthetic4_multiclass();
      case 'synthetic4_multiclass_R4'
        [trainSetFeatures,trainSetClass] = synthetic4_multiclass_R4();
      case 'synthetic41_multiclass'
        [trainSetFeatures,trainSetClass] = synthetic41_multiclass();
      case 'synthetic42_multiclass'
        [trainSetFeatures,trainSetClass] = synthetic42_multiclass();
      case 'synthetic43_multiclass'
        [trainSetFeatures,trainSetClass] = synthetic43_multiclass();

      case 'synthetic51_multiclass'
        [trainSetFeatures,trainSetClass] = synthetic51_multiclass();

      case 'edistribution'
        [trainSetFeatures,trainSetClass] = edistribution();
      case 'genes'
        [trainSetFeatures,trainSetClass] = genes();
      case 'omrsynth'
        [trainSetFeatures,trainSetClass] = omrSynth();
      case 'omrreal'
        [trainSetFeatures,trainSetClass] = omrReal();
      case 'omrall'
        [trainSetFeatures,trainSetClass] = omrAll();
      
      otherwise
        [trainSetFeatures, trainSetClass] = loadRealDataset(options.normalize,options.project_lib_path,dataset);

    end
    
    % [0,1] dataset normalization 
    trainSetFeatures = normalization( trainSetFeatures );

    return
    

% ------------------------------------------------------------------------
%% pol
function [trainSetFeatures,trainSetClass] = syntheticI()
    data = genSyntheticI(400);
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    trainSetClass(trainSetClass==2) = 3;
    
    return;

%% two gaussians 
function [trainSetFeatures,trainSetClass] = syntheticII()
    data = genSyntheticII(200); % 200 for each class
    
    trainSetFeatures = data(:,1:end-1);    
    trainSetClass    = data(:,end);
   
    return;

    
% --------------------------------------------------------------
% --------------------------------------------------------------
    
    
    
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
%% pol
function [trainSetFeatures,trainSetClass] = synthetic3_multiclass()
    data = createSynthetic3_multiclass(600); %nclasses*200 = 600
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    %plot_features(data)
    %kk
    
    return;

%% pol
function [trainSetFeatures,trainSetClass] = synthetic4_multiclass()
    data = createSynthetic4_multiclass(400); %nclasses*200 = 600
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    return;

function [trainSetFeatures,trainSetClass] = synthetic4_multiclass_R4()
    data = createSynthetic4_multiclass_R4(1000); %nclasses*200 = 600
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    return;

% ------------------------------------------------------------------------
%% pol
function [trainSetFeatures,trainSetClass] = synthetic41_multiclass()
    data = createSynthetic41_multiclass(400); %nclasses*200 = 600
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    return;

% ------------------------------------------------------------------------
%% pol
function [trainSetFeatures,trainSetClass] = synthetic42_multiclass()
    data = createSynthetic42_multiclass(400); %nclasses*200 = 600
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    return;

% ------------------------------------------------------------------------
%% pol
function [trainSetFeatures,trainSetClass] = synthetic43_multiclass()
    data = createSynthetic43_multiclass(400); %nclasses*200 = 600
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    return;
    
% ------------------------------------------------------------------------
%% two gaussians - not as we would like it
function [trainSetFeatures,trainSetClass] = synthetic5()
    data = createSynthetic5(200); % 200 for each class
    
    trainSetFeatures = data(:,1:end-1);    
    trainSetClass    = data(:,end);
   
    return;

%% n gaussians 
function [trainSetFeatures,trainSetClass] = synthetic51_multiclass()
    data = createSynthetic51_multiclass(200,3); % 200 for each class
    
    trainSetFeatures = data(:,1:end-1);    
    trainSetClass    = data(:,end);
   
    return;
    
% ------------------------------------------------------------------------
%%
function [trainSetFeatures,trainSetClass] = edistribution()
    [data, classes] = Edistribution (1000);
    trainSetFeatures = data;
    
    idx1 = (classes == 0);
    
    trainSetClass(idx1,1) = 1;
    trainSetClass(~idx1,1) = 3;
    
    return
    
% ------------------------------------------------------------------
%% 
function [trainSetFeatures,trainSetClass] = genes()
    
    data1 = dlmread('tumour.csv');
    data2 = dlmread('normal.csv');

    data1 = data1(:,1:end-1);
    data2 = data2(:,1:end-1);

    trainSetFeatures = [data1; data2];
    trainSetClass    = [repmat(1,size(data1,1),1); repmat(3,size(data2,1),1)];

    idx  = randperm(size(trainSetFeatures,1));
    trainSetFeatures = trainSetFeatures(idx,:);
    trainSetClass    = trainSetClass(idx,:);
    return
    
% ------------------------------------------------------------------
%% 
function [trainSetFeatures,trainSetClass] = omrSynth()
    data = dlmread('OMRsynth.csv');
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    idx = logical(trainSetClass == 2);
    trainSetClass(idx) = 3;

    idx  = randperm(size(trainSetFeatures,1));
    trainSetFeatures = trainSetFeatures(idx,:);
    trainSetClass    = trainSetClass(idx,:);
    
    return

% ------------------------------------------------------------------
%% 
function [trainSetFeatures,trainSetClass] = omrReal()
    data = dlmread('OMRreal.csv');
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);

    idx = logical(trainSetClass == 2);
    trainSetClass(idx) = 3;

    idx  = randperm(size(trainSetFeatures,1));
    trainSetFeatures = trainSetFeatures(idx,:);
    trainSetClass    = trainSetClass(idx,:);
    return

% ------------------------------------------------------------------
%% 
function [trainSetFeatures,trainSetClass] = omrAll()
    data = dlmread('OMRall.csv');
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    idx = logical(trainSetClass == 2);
    trainSetClass(idx) = 3;

    idx  = randperm(size(trainSetFeatures,1));
    trainSetFeatures = trainSetFeatures(idx,:);
    trainSetClass    = trainSetClass(idx,:);
    
    return    

    
% ------------------------------------------------------------------
%% [0,1] dataset normalization 
function trainSetFeatures = normalization( trainSetFeatures )
    feat = trainSetFeatures(:);

    minv = min( feat );
    maxv = max( feat );
    trainSetFeatures = (trainSetFeatures-minv)/(maxv - minv);

    return