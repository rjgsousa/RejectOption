function plot_features(data, symbol)
    plot_info = ['b<';'gs';'ro';'y>';'kd';'bs';'go';'r>';'yd';'bo'];
    
    if nargin == 2
        plot_info(:,2) = repmat(symbol,size(plot_info,1),1);
    end
    
    classes = data(:,end);
    dimension = size(data,2)-1;
    
    if dimension > 3, return, end

    K = max(data(:,end))
    %figure
    hold on
    %grid
    for i=1:K
        idx = find(classes == i);
        if nargin == 2
            plot(data(idx,1),data(idx,2),plot_info(i,:),'MarkerSize',9)
        elseif dimension == 2
            plot(data(idx,1),data(idx,2),plot_info(i,:),'MarkerSize',9,'LineWidth',2,'MarkerFaceColor',plot_info(i,1),'MarkerEdgeColor','k')
        elseif dimension == 3
            plot3(data(idx,1), data(idx,2), data(idx,3), plot_info(i,:),'MarkerSize',5)
        end
    end
    
    return