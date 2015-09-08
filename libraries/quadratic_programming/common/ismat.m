function x = ismat(m)
% ISMAT  Check if v is a vector
%        ISMAT(m) returns
%        1 if m is a matrix
%        0 if m is not a matrix (note: scalars and vectors are also allowed)

sizev = size(m);
x = (length(sizev) == 2);
