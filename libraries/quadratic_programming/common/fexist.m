function x = fexist(filename)
% FEXIST Check if file exists
%        FEXIST('filename') returns:
%        0 if filename does not exist
%        1 if filename exists in the given path

fd = fopen(filename);
if fd ~= -1
	x = 1;
	fclose(fd);
else
	x = 0;
end
