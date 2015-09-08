

%% Create Artificial/Synthetic Data 
% Generates two gaussian with different means
function data = genSyntheticII( nSamples )
    octave = 0;
    
    dimension = 2;

    var1 = 3;
    var2 = 5;
    
    mean1 = -2;
    mean2 =  2;
    
    % sample1 = randn(nSamples,dimension);
    % sample2 = randn(nSamples,dimension);
    
    % sample1 = mean1 + var1*sample1;
    % sample2 = mean2 + var2*sample2;
    sample1 = mvnrnd([mean1 mean1], [var1 0; 0 var1], nSamples);
    sample2 = mvnrnd([mean2 mean2], [var2 0; 0 var2], nSamples);
    
    % data  = [sample1 repmat(1,nSamples,1); sample2 repmat(3,nSamples,1)];
    classes = [repmat(1,nSamples,1); repmat(3,nSamples,1)];
    
    % noise   = 0.125 * randn( nSamples*2, 3 );
    % noise   = repmat([.125 .025 .225 0.025 .125],nSamples*2,1).* randn( nSamples*2, dimension );
    % noise   = repmat(0.025+0.225*rand(1,dimension),nSamples*2,1).* randn( nSamples*2, dimension );
    noise   = repmat(0.025+0.225*rand(1,dimension),nSamples*2,1);

    data    = [sample1; sample2];
    data    = data + noise;
    
    % classes = mix(data,classes);

    data    = [data, classes];
    
    
%     scrsz = get(0,'ScreenSize');
%     h = figure('Position',[1 scrsz(4) scrsz(3) scrsz(4)]);
%     idx = find(classes == 1);
%     plot3(data(idx,1),data(idx,2),data(idx,3),'b+')
%     hold on
%     idx = find(classes == 3);
%     plot3(data(idx,1),data(idx,2),data(idx,3),'ro')
%     grid on

    idx  = randperm(nSamples*2);
    data = data(idx,:);

    
    %dlmwrite('syntheticII_data.csv',data)
    
    if octave, print -dpng createArtificialData3.png; end
return

%----------------------------------------------------------------------
%% 
%
function newclasses = mix(data, classes)
    theta = [-inf, -0.75, 0.75, inf];

    newclasses = [];
    
    for i = 1:size(data,1)
        d = data(i,:);
        x = d - 0.5;
        x = prod (x);
        x = x*10;
        stdDev = 0.125;
        epsilon = stdDev*randn; 
        class = x + epsilon;
        class = theta > class;
        class = find(~class);
        class = size(class, 2);

        tclass = class;

        if ( class == 2 )
            z = rand;
            xx = ( x+.75 )/( .75+.75 );
            if ( z < xx )
                class = 3;
            else
                class = 1;
            end
        end
        
        newclasses = [newclasses; class];
    end
    return