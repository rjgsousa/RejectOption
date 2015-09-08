function res = chunkmult(Z, csize, colscale)
%
%

if nargin < 3
  error('Wrong number of arguments');
end;

[n,m] = size(Z);
if size(colscale,1) ~= m
  error('Column scaling vector is wrong size');
end

d = sqrt(colscale);			% numerically more stable
nchunks = ceil(m / csize);

%buffer = zeros(n,csize);		% where we premultiply
res    = zeros(n);			% result

for i=1:nchunks
  lower_b = (i-1) * csize + 1;
  upper_b = min(i * csize, m);
  
  buffer = Z(:,lower_b:upper_b)';
  buffer_d = d(lower_b:upper_b);
  for i=1:n
    buffer(:,i) = buffer(:,i) ./ buffer_d;
  end;
  res = res + buffer' * buffer;
end;






