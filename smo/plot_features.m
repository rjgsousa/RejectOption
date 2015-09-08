function H = plot_features(data,H1)
    plot_info = ['b<';'gs';'ro';'y>';'kd';'bs';'go';'r>';'yd';'bo'];
    
    classes = data(:,end);
    dimension = size(data,2)-1;
    
    if dimension > 3, return, end

    K = max(data(:,end));
    if nargin == 2
        figure(H1);
    else
        H = figure;
    end
    hold on
    %grid
    for i=1:K
        idx = find(classes == i);
        if dimension == 2
            plot(data(idx,1),data(idx,2),plot_info(i,:),'MarkerSize',5,'LineWidth',1,'MarkerFaceColor',plot_info(i,1),'MarkerEdgeColor','k')
        elseif dimension == 3
            plot3(data(idx,1), data(idx,2), data(idx,3), plot_info(i,:),'MarkerSize',5)
        end
    end
    
    return