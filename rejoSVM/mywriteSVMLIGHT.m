
function mywriteSVMLIGHT(features_rep, classes_rep, weights, locationDB)

fd = fopen(locationDB, 'w' );
for i=1:size(features_rep,1)
    if ~isempty( classes_rep )
        fprintf(fd,'%d',classes_rep(i));
    end
    
    for j=1:size(features_rep,2)
        fprintf(fd,' %d:%f',j,features_rep(i,j));
    end
    
    if ~isempty( weights )
        fprintf(fd,' cost:%f\n',weights(i));
    else
        fprintf(fd,'\n');
    end
end
fclose(fd);
