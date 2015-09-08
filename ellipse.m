function ellipse(roc)
    angle = 90;

    plotgraphopt = ['b-'; 'g-'; 'c-'; 'k-'; 'm-'; 'b-'; 'g-'; 'c-'; 'k-'; 'm-'; 'b-'; 'g-'; 'c-';];
    
    for j = 1:size(roc,1)
        x = roc(j,1);
        y = roc(j,2);
        b = roc(j,3); %% std from reject
        a = roc(j,4); %% std from error
        
        beta = -angle * (pi / 180);
        sinbeta = sin(beta);
        cosbeta = cos(beta);
        
        data = [];

        i = 0:360;

        alpha = i * (pi / 180);
        sinalpha = sin(alpha);
        cosalpha = cos(alpha);
        
        X = x + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
        Y = y + (a * cosalpha * sinbeta + b * sinalpha * cosbeta);
        
        data = [X' Y'];
        
        plot(data(:,1),data(:,2), plotgraphopt(j,:) );
        hold on
    end
    
    plot( roc(:,1), roc(:,2), 'r-' );
    return;