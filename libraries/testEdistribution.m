close all;

%cls 0
figure
xx = Edistribution (100000, 0);
hist3(xx)

%cls 1
figure
xx = Edistribution (100000, 1);
hist3(xx)

%boths classes
N = 400;
[x, cls] = Edistribution(N);
idx = (cls == 0);
figure
plot(x(idx,1),x(idx,2), '*r');
hold on
plot(x(~idx,1),x(~idx,2), 'ob');
hold off