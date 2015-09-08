function data = gen_ordinal_data(npoints)
    
%rand('twister',5489);
    % init seed
    method = 'osvm';
    %npoints = 100;
    dim = 2;
    
    switch method
      case 'naive'
        data = naive();
      case 'osvm'
        data = osvm_gen_data( npoints );
    end
    return;
    
function data = osvm_gen_data( npoints )
    data = rand(npoints,2);
    xi   = 0+.125.*randn(npoints,1)*0;

    x1 = data(:,1);
    x2 = data(:,2);
    
    b = [-inf, -1, -.1, .25, 1, inf];
    r = 2:6;
    
    condition = 10.*(x1-.5).*(x2-.5)+xi;
    solution = [];
    for i=r(1):r(end)
        solution = [solution, b(i-1) < condition & condition < b(i)];
    end

    %solution
    [i j] = find(solution == 1);
    [i idx] = sort(i);
    j = j(idx);

    %% -----------------------------
    plot_info = ['b.';'g.';'r.';'c.';'y.'];
    data = [];
    if 0, figure, end
    for i=1:5
        c = plot_info(i,:);
        ind = find ( j == i );
        x = x1(ind);
        y = x2(ind);
        data = [data; x,y,j(ind)];
        if 0
            plot(x,y,c,'MarkerSize',20);
            hold on
        end
    end
    %dlmwrite('data.txt',data)
    
    return;
    
function naive()
    ndata_points = 30;
    plot_info = struct('a1','r.','a2','go','a3','b+');
    
    data = [];
    
    a = [0, 10, 20];
    b = [10, 20, 30];
    
    for i=1:length(a)
        [x,y] = my_gen(a(i),b(i),ndata_points);
        f = getfield(plot_info,['a',num2str(i)]);
        plot(x,y,f);
        hold on
        data = [data; x, y, repmat(i,ndata_points,1)];
    end

    dlmwrite('data.txt',data)
    return;
    
% --------------------------------------------
function [x,y] = my_gen(a,b,n)
    y0 = 0;
    yt = 30;
    
    x = a  + (b-a).*rand(n,1);
    y = y0 + (yt-y0).*rand(n,1);
    return;