
addpath('.')

x = randn(10,2);
y = sign( randn(10,2) );
w = [.04+ones(10,1); .96+ones(10,1)];

svmtrain(y,x,'-c 1',w)

