function data = plot_reject_option_data(features)
    
    plot_info = ['b.';'g.';'r.'];
    data = [];
    figure
    for i=1:3
        c = plot_info(i,:);
        ind = find ( features(:,3) == i );
        x = features(ind,1);
        y = features(ind,2);
        j = features(ind,3);
        data = [data; x,y, j];
        plot(x,y,c,'MarkerSize',20);
        hold on
    end
   
    return;