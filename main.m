
function main()
% matlab -nojvm < main.m > log_fumera_syntheticI 2>&1 &
    % method:
    %     - frankhall
    %     - fumera
    %     - rejoSVM
    %     - weights
    %     - threshold
    %     - rejoNN
    %     - NN_weights
    %     - NN_threshold
    
    general_opt = struct();
    
    general_opt.trial       = '1';
    general_opt.method      = '';
    general_opt.nensembleAll= 1;% [3 5 10:10:50];
    
    general_opt.learningrate  = ''; %0.05
    general_opt.rejectSOMmethod = 'parzen';
    % 'weightscosts', 'parzen'
    % 'trainreject_supervised'

    % frankhall
    % som_threshold, matlab
    % som_weights, somtoolbox
    general_opt.method      = 'frankhall';
    general_opt.SOMtoolbox  = 'somtoolbox';
    general_opt.SOMcfgcv    = true;

    general_opt.SOMtopologyType = 'square';
    general_opt.entropy         = 'gini';
    general_opt.lattice         = 'hexa'; %'hexa', 'rect';
    
    general_opt.transferFcn = {'tansig','tansig'};
    general_opt.datasetID   = 'syntheticII'; %'synthetic4_multiclass';
    general_opt.normalize   = true;
    general_opt.kernel      = 'polynomial';
    general_opt.degree      = 2;
    
    general_opt.k           = [2:4];
    general_opt.C           = [2.^(-5:2:3)]; % [7];
    general_opt.gamma       = [2.^(-3:2:1)]; % [2^-1 2];
    general_opt.h           = 1; %[10];
    general_opt.s           = [3];  % [];  % 2;
    general_opt.nneurons    = [5:5:25]; % 100; % 5:5:30
    general_opt.nlayers     = [2];  % 2:3
    general_opt.trainepochs = [15]; % 15
    reject(general_opt);
