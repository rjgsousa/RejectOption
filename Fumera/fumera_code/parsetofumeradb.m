function parsetofumeradb(a,filepathname)
    
    [npoints nfeats ] = size(a);
    
    fd = fopen(filepathname,'w');

    fprintf(fd,'%d %d\n',npoints,nfeats-1);
    for i = 1:npoints
        % class
        fprintf(fd,'%d ',a(i,end));
        for j = 1:nfeats-1
            fprintf(fd,'%f ',a(i,j));
        end
        fprintf(fd,'\n');
    end
    
    fclose(fd);