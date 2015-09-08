function x = isvec(v)
% ISVEC  Check if v is a vector
%        ISVEC(v) returns
%        1 if v is a vector
%        0 if v is not a vector (note: scalars are also allowed)

sizev = size(v);
x = (length(sizev) == 2) & (min(sizev) == 1);
