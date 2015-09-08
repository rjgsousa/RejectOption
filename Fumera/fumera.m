
%%                                                   
function [RR, ER, fail] = fumera(trainIDX, testIDX,wr,options)
    global datafeatures
    global dataclasses
    
    x = datafeatures(trainIDX,:);
    y = dataclasses(trainIDX);
    
    xTest = datafeatures(trainIDX,:);
    yTest = dataclasses(trainIDX);
    
    fail = 0; ER = 0; RR = 0;
    
    path = options.fumera_path
    parsetofumeradb([x,y],[path '/db.txt']);
    parsetofumeradb([x,y],[path '/db_test.txt']);
    
    % train
    command = sprintf('%s/svm-r_learn %s/db.txt %s/model -t %f -c %f -w %f',...
                      path,path,path,options.epsilon,options.C,wr);
    [s, w] = system(command);
    if s ~= 0, fail = 1; return, end
    
    % predict
    command = sprintf('%s/svm-r_classify %s/db.txt %s/db_test.txt %s/model %s/predict',...
                      path,path,path,path,path);
    [s, w] = unix(command);
    if s ~= 0, fail = 1; return, end
    
    % reads prediction
    fd = fopen( [path '/predict'] );
    predict  = textscan(fd, '%f%f%f%s%f%f%s');
    fclose(fd);
    RR = predict{5};
    ER = predict{6};
    
    % cleans prediction
    command = sprintf('rm -f %s/predict',path);
    unix(command);
    
    return