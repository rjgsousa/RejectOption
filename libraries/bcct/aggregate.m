
function aggregate
    
    data1 = dlmread('fougo17.raw.BCCT.core.database.csv');
    data2 = dlmread('hugo17.raw.BCCT.core.database.csv');
    data3 = dlmread('jsc17.raw.BCCT.core.database.csv');
    data4 = dlmread('mjc17.raw.BCCT.core.database.csv');
    data5 = dlmread('moura17.raw.BCCT.core.database.csv');
    data6 = dlmread('ricardo17.raw.BCCT.core.database.csv');
    data7 = dlmread('susy17.raw.BCCT.core.database.csv');
    data8 = dlmread('teresa17.raw.BCCT.core.database.csv');
    
    data = [data1;data2;data3;data4;data5;data6;data7;data8];
    
    
    data = data(:,1:31);
    
    dlmwrite('bcct.csv',data,'delimiter',',');
    return