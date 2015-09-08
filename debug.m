clc, clear all
data = load('data.mat');
data = data.data;

classes_rep = data(:,end);
features    = data(:,1:end-1);

osvm = load('osvm_model.mat');
osvm = osvm.osvm_model
options = osvm.options

%% ---------------------------------------------
bias  = osvm.bias;
alpha = osvm.supportVectorAlphaClasses;
osvm.supportVector
%% ----------------------------------------------
myplot3d(features,classes_rep,[]);


size(features)
size(alpha)
kk

W = sum( repmat(alpha,1,size(features,2)).* features.* repmat(classes_rep,1,size(features,2)),1);

x1 = [-1:.25:2];
x2 = [-1:.25:1];

%% o modelo é linear!
[x11, x22] = meshgrid(x1, x2);
x33 = - bias - W(1)*x11 - W(2)*x22;
x33 = x33/W(3);

contour3( x11, x22, x33 )
surface(x11,x22,x33,'EdgeColor',[.6 .6 .6],'FaceColor','none')

