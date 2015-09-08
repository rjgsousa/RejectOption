function x = isscal(s)
% ISSCAL Check if s is a vector
%        ISSCAL(s) returns
%        1 if s is a scalar
%        0 if s is not a scalar

sizev = size(s);
x = (length(sizev) == 2) & (min(sizev) == 1) & (max(sizev) == 1);
