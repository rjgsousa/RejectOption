function plot_roc(scrsz,roc_data,prefix,dofigure,options)
    
    if dofigure
        h = figure('Position',[1 scrsz(4) scrsz(3) scrsz(4)]);
        %figure
        %herrorbar(roc_data(:,1),roc_data(:,2),roc_data(:,3),'--r')
        ellipse(roc_data);
        %plot(roc_data(:,1),roc_data(:,2),'--r')
        t = text(roc_data(:,1),roc_data(:,2), num2str(roc_data(:,5)));
        grid on
        xlabel('Reject')
        ylabel('Error')
        %axis([0 1 0 1])
        name = strcat(prefix,'_error_vs_reject.png');
        saveas(h,name)
    end

    name = strcat(prefix,'_error_vs_reject');
    
    if options.nensemble > 1
        name = sprintf('%s_nensemble=%03.0f',name,options.nensemble);
    end
    
    name = [name, '.txt'];
    dlmwrite(name,[roc_data(:,1) roc_data(:,2) roc_data(:,3) roc_data(:,4)]);
    
%     try
%         x = roc_data(:,1);
%         %x = min(roc_data(:,1)):.01:max(roc_data(:,1));
%         %y = spline(roc_data(:,1),roc_data(:,2),x);
%         p = polyfit(roc_data(:,1),roc_data(:,2),2);
%         y = p(1).*roc_data(:,1).^2 + p(2).*roc_data(:,1) + p(1);
%         h = figure('Position',[1 scrsz(4) scrsz(3) scrsz(4)]);
%         %figure
%         herrorbar(x,y,roc_data(:,3),'--g');
%         grid on
%         title('Interpolated')
%         xlabel('Reject')
%         ylabel('Error')
%         %axis([0 1 0 1])
%         name = strcat(prefix,'_error_vs_reject_interpolated.png');
%         saveas(h,name)
%         name = strcat(prefix,'_error_vs_reject_interpolated.txt');
%         dlmwrite(name,[x y roc_data(:,3)]);
%     catch ME
%         info = sprintf('Interpolator error - not enough info');
%         disp(info);
%     end

    return