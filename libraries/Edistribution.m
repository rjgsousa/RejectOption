function  [x, cls]= Edistribution (Nsamples, Class)
    if nargin == 1
        rr = rand(Nsamples,1)>0.5;
        x = EdistributionCls0(Nsamples);
        x1= EdistributionCls1(Nsamples);
        x(rr,:) = x1(rr,:);
        cls = zeros(Nsamples,1);
        cls(rr) = 1;
        return;
    end
    if (Class == 0)
        x = EdistributionCls0 (Nsamples);
        cls = zeros(Nsamples,1);
    else
        x = EdistributionCls1 (Nsamples);
        cls = ones(Nsamples,1);
    end
    return

function  [x]= EdistributionCls0 (Nsamples)
%% zone 1
    x1 = rand(Nsamples, 2);

    %% zone 2,3,4
    randLinear=rand(Nsamples,1)+rand(Nsamples,1);
    randLinear(randLinear<1)=2-randLinear(randLinear<1);
    offset=0.4*floor(rand(Nsamples,1)*3); % 0 OR 0.4 OR 0.8
    x234 = [randLinear rand(Nsamples,1)*0.2+offset];

    %% choose between zone1 or zone234
    AA = 1/1.3;
    randb = rand(Nsamples,1) < AA;
    x = x234;
    x(randb,:) = x1(randb,:);
    return

%%
function  [x]= EdistributionCls1 (Nsamples)
    x = EdistributionCls0(Nsamples);
    x(:,1)=2-x(:,1);
    return