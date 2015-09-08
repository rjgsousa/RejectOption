function myplot3d(features,classes_rep,classes)
    plotgraphopt = ['*k'; '*g'; '+k'; 'xr'; '>y'];
    
    maxc=max(classes_rep);
    minc=min(classes_rep);
    
    K = maxc-minc+1
    
    figure, hold on, grid on
    for i = 1:K
        idx  = logical ( classes == i );
        %plot3(features(idx,1) ,features(idx,2) ,features(idx,3) ,plotgraphopt(i,:),'LineWidth', 1,'MarkerSize',10);
    end
    idx = logical ( classes_rep == -1 );
    plot3(features(idx,1) ,features(idx,2) ,features(idx,3) ,'k>','LineWidth', 1,'MarkerSize',10);
    plot3(features(~idx,1),features(~idx,2),features(~idx,3),'ko','LineWidth', 1,'MarkerSize',10);

    %kk
    return;