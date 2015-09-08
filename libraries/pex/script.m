
filename = 'bcct_all';

fd = fopen( [filename  '.data'],'w');
d  = dlmread([filename '.csv']);

[n m] = size(d);
m = m-1;
fprintf(fd,'DY\n%d\n%d\n',n,m);
for i=1:m-1
    fprintf(fd,'D%d;',i-1);
end
fprintf(fd,'D%d\n',m-1);

for i=1:n
    fprintf(fd,'P%g;',i-1);
    for j=1:m
        fprintf(fd,'%g;',d(i,j));
    end
    fprintf(fd,'%1.1f\n',double(d(i,m+1)));
end
fclose(fd);
