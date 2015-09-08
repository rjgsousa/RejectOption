
%% Loads real dataset
%
function [data,classes] = loadRealDataset(normalize,project_lib_path,datasetname)
    datasetnameOrig = datasetname;
    datasetname = lower( datasetname );

    underscore  = strfind(datasetname,'_');
    if ~isempty ( underscore )
        subproblem  = upper( datasetname(underscore+1:end) );
        datasetname = datasetname(1:underscore-1);
    end
    
    switch ( datasetname )
      case 'lev'
        data = dlmread([project_lib_path 'arie_ben_david/LEV.csv']);
        classes = data(:,end);
        classes = classes*2+1;
        
        data(:,end) = [];

      case 'letter'
        % path  = [project_lib_path '../datafiles/letter/letter-recognition.data'];
        % fd    = fopen( path );
        % data1 = textscan(fd,'%c,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d');
        % fclose(fd);
        
        % class = data1{1};
        % [class scaleFactor] = mystr2double( class );
        % data  = double( cell2mat(data1(2:end)) );
    
        % subprob1 = str2double(sprintf('%d',subproblem(1)))-scaleFactor;
        % subprob2 = str2double(sprintf('%d',subproblem(2)))-scaleFactor;
        
        % ind1 = find( class == subprob1 );
        % ind2 = find( class == subprob2 );
        
        % data    = data([ind1;ind2],:);
        % classes = [class(ind1); class(ind2)];
        
        % minc = min(classes);
        % maxc = max(classes);
        
        % classes = (classes - minc)/(maxc-minc);
        % classes = classes*2+1;

        path = [project_lib_path datasetname '_' lower(subproblem) '_pre.csv'];
        data = dlmread(path);
        classes = data(:,end);
        data(:,end) = [];
        
      case 'coluna'
        path = [project_lib_path 'coluna_rotulado_normal_patologico.csv'];
        data = dlmread(path);
        
        classes     = data(:,end);
        classes     = classes+2;
        data(:,end) = [];


      case 'bcct'
        path = [project_lib_path 'bcct/bcct_all.csv'];
        data = dlmread(path);
        ndim = size(data, 2);
        
        switch( datasetnameOrig)
          case 'bcct_multiclass_featsel'
            classes = data(:,ndim);
            classes = classes*2-1;
            data    = data(:,[9 11 17 23]);

          case 'bcct_featsel'
            classes = data(:,ndim);
            ind1 = ( classes == 1 ) | ( classes == 2 ) ;
            classes( ind1) = 1;
            classes(~ind1) = 3;
            data    = data(:,[9 11 17 23]);
          
          case 'bcct_all'
            classes = data(:,ndim);
            data(:,end) = [];
            classes = classes*2-1;

          otherwise
            myerror('oups')
        end
      otherwise 
        errorstr = sprintf('dataset ''%s'' unknonwn.\n',datasetname);
        error(errorstr);
    end

    idx     = randperm(size(data,1));
    data    = data(idx,:);
    classes = classes(idx,:);

    return
    
%%                                                     
function [class scaleFactor] = mystr2double(class)
    
    d = zeros(length(class),1);
    for i = 1:length( class )
        z    = sprintf('%d',class(i));
        d(i) = str2double( z );
    end
    
    scaleFactor = min(d);
    class = (d-scaleFactor);
    return 
    
    
    
%     % ------------------------------------------------------------------
% %% bcct
% function [trainSetFeatures,trainSetClass] = bcct()
%     data = dlmread('bcct.csv');

%     trainSetFeatures = data(:,1:end-1);
%     trainSetClass    = data(:,end);

%     idx0 = find(trainSetClass == 1);
%     idx0 = [idx0; find(trainSetClass == 2)];

%     idx1 = find(trainSetClass == 3);
%     idx1 = [idx1; find(trainSetClass == 4)];

%     trainSetClass(idx0) = 1;
%     trainSetClass(idx1) = 3;
    
%     idx  = randperm(size(trainSetFeatures,1));
%     trainSetFeatures = trainSetFeatures(idx,:);
%     trainSetClass    = trainSetClass(idx,:);

%     return;

% %% bcct w/ feature selection
% function [trainSetFeatures,trainSetClass] = bcct_featsel()
%     [trainSetFeatures,trainSetClass] = bcct();
    
%     trainSetFeatures = trainSetFeatures(:,[9 12 13 16 24]);
%     return;


% % ------------------------------------------------------------------
% %% bcct
% function [trainSetFeatures,trainSetClass] = bcct_multiclass()
%     data = dlmread('bcct.csv');

%     trainSetFeatures = data(:,1:end-1);
%     trainSetClass    = data(:,end);

%     idx0 = find(trainSetClass == 1);
%     idx1 = find(trainSetClass == 2);
%     idx2 = find(trainSetClass == 3);
%     idx3 = find(trainSetClass == 4);

%     trainSetClass(idx0) = 1;
%     trainSetClass(idx1) = 3;
%     trainSetClass(idx2) = 5;
%     trainSetClass(idx3) = 7;
    
%     idx  = randperm(size(trainSetFeatures,1));
%     trainSetFeatures = trainSetFeatures(idx,:);
%     trainSetClass    = trainSetClass(idx,:);
    
%     return;

% %% bcct w/ feature selection
% function [trainSetFeatures,trainSetClass] = bcct_multiclass_featsel()
%     [trainSetFeatures,trainSetClass] = bcct_multiclass();
    
%     trainSetFeatures = trainSetFeatures(:,[9 12 13 16 24]);
%     return;
