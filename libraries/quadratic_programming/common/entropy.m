function H = entropy(p);

%H = entropy(p)
%
%Computes the entropy of p. If p is a vector, it assumes binary
%distributions, otherwise its columns are treated as the individual
%probabilities of a multinomial

[n, m] = size(p);

if (n == 1)
  p = [p; 1-p];
  n = 2;
end;

logp = log(p);
logp(isnan(logp)) = 0;			% remove NaNs
H = -sum(sum(logp .* p));
