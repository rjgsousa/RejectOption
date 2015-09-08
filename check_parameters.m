function results = check_parameters(method,trial,fold)

    fprintf(1,'\n\n');
    fprintf(1,'**************** Checking parameters.\n');
    path = ['results' num2str(trial)];
    path1 = sprintf('%s/*%s-*.mat',path, num2str(fold));
    
    d = dir(path1);
    fprintf(1,'Analysing: %s and remain.\n',[path '/' d(1).name]);
    
    nneurons = [];
    nlayers  = [];
    h        = [];
    s        = [];
    gamma    = [];
    C        = [];
    for i = 1:size(d,1) % number of runs
                        %fprintf(1,'Analysing: %s\n',[path '/' d(i).name]);
        data = load([path '/' d(i).name]);
        data = data.best_options;

        nn = zeros(1,size(data,2));
        for j = 1:size(data,2) % for each wr
            
            switch ( method )
              case {'SOM_threshold','SOM_weights'}
                nn(j) = prod(data{j}.SOMconfig);
              case {'rejoNN'}
                nn(j) = data{j}.nneurons;
                nl(j) = data{j}.nlayers;
                h_(j) = data{j}.h;
                s_(j) = data{j}.s;
                
              case {'NN_weights','NN_threshold'}
                nn(j) = data{j}.nneurons;
                nl(j) = data{j}.nlayers;

              case {'rejoSVM','rejoSVM_plus'}
                gamma_(j) = data{j}.gamma;
                C_(j)     = data{j}.C;

                h_(j) = data{j}.h;
                s_(j) = data{j}.s;
                
              case {'frankhall', 'frankhall_threshold'}
                gamma_(j) = data{j}.gamma;
                C_(j)     = data{j}.C;
              
              case 'fumera'
                C_(j)     = data{j}.C;
                
            end
        end

        switch( method )
          case {'SOM_threshold','SOM_weights'}
            nneurons = [nneurons;nn];
          case {'rejoNN'}
            nneurons = [nneurons;nn];
            nlayers  = [nlayers; nl];
            h        = [h; h_];
            s        = [s; s_];
          case {'NN_weights','NN_threshold'}
            nneurons = [nneurons;nn];
            nlayers  = [nlayers; nl];
          case {'rejoSVM','rejoSVM_plus'}
            h        = [h; h_];
            s        = [s; s_];
            gamma = [gamma; gamma_];
            C     = [C; C_];
        
          case {'frankhall','frankhall_threshold'}
            gamma = [gamma; gamma_];
            C     = [C; C_];
          
          case 'fumera'
            C     = [C; C_];
        end
        
    end

    C     = log(C)./log(2);
    gamma = log(gamma)./log(2);

    switch( method )
      case {'SOM_threshold','SOM_weights'}
        neurons = [ mean(nneurons,1); std(nneurons,0,1)] ;
        fprintf(1,'neurons\t|\tMean: %d, std: %d\n',neurons(1),neurons(2));
      case {'rejoNN'}
        neurons = [ mean(nneurons,1); std(nneurons,0,1)] 
        layers  = [ mean(nlayers,1); std(nlayers,0,1)]
        h       = [ mean(h,1); std(h,0,1)]
        s       = [ mean(s,1); std(s,0,1)]
        
        results = struct('neurons',neurons,'layers',layers,'h',h,'s',s)
      case {'NN_weights','NN_threshold'}
        neurons = [ mean(nneurons,1); std(nneurons,0,1)] 
        layers  = [ mean(nlayers,1); std(nlayers,0,1)]

        results = struct('neurons',neurons,'layers',layers)
      case {'rejoSVM','rejoSVM_plus'}
        gamma = [mean(gamma,1); std(gamma,0,1)]
        C     = [mean(C,1); std(C,0,1)]
    
        h       = [ mean(h,1); std(h,0,1)]
        s       = [ mean(s,1); std(s,0,1)]

        results = struct('h',h,'s',s,'C',C,'gamma',gamma)
    
      case {'frankhall', 'frankhall_threshold'}
        gamma = [mean(gamma,1); std(gamma,0,1)]
        C     = [mean(C,1); std(C,0,1)]
        results = struct('C',C,'gamma',gamma)

      case 'fumera'
        C     = [mean(C,1); std(C,0,1)]
        results = struct('C',C)
    end
    
    fprintf(1,'\n\n');
    return
