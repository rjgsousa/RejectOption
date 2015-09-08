function aggregate
    
    featureReal  = dlmread('caractreais.csv');
    featureSynth = dlmread('caractSint.csv');
        
    classReal    = dlmread('classreais.csv');
    classSynth   = dlmread('classSint.csv');
    
    unknownClass = logical( classReal == 14 );
    classReal(~unknownClass) = 1;
    classReal(unknownClass)  = 2;
    
    unknownClass = logical( classSynth == 14 );
    classSynth(~unknownClass) = 1;
    classSynth(unknownClass)  = 2;

    dataReal  = [aggregateaux(featureReal), classReal];
    dataSynth = [aggregateaux(featureSynth), classSynth];

    classes = [classReal; classSynth];
    data = [dataReal; dataSynth];
    data = [data, classes];

    dlmwrite('OMRreal.csv',dataReal,'delimiter',',');
    dlmwrite('OMRsynth.csv',dataSynth,'delimiter',',');
    dlmwrite('OMRall.csv',data,'delimiter',',');
   
    return
    
function data = aggregateaux(feature)
    data = [];
    for i = 1:5:size(feature,1)-4
        aux  = feature(i:i+4,:)';
        data = [data; aux(:)'];
    end

    return