function plotregion(trainSetClass,trainSetFeatures,test_data_X,test_data_Y,x1,x2,x11,x22,SVs)
    figure;
    hold on;
    idx = find (trainSetClass == 0);
    plot (trainSetFeatures(idx,1),trainSetFeatures(idx,2),  'or', 'LineWidth', 2);
    idx = find (trainSetClass == 1);
    plot (trainSetFeatures(idx,1),trainSetFeatures(idx,2),  '*b', 'LineWidth', 2);

    if size(SVs,1) ~= 0
        for i=1:size(SVs,1)
            plot(SVs(i,1),SVs(i,2),'+g')
        end
    end

    x1x2out = reshape(test_data_Y, [length(x1) length(x2)]);
    hold on;
    %margin
    contour(x11, x22, x1x2out, [1 1] , 'b-');
    %boundary
    contour(x11, x22, x1x2out, [0.5 0.5], 'k-');
    %margin
    contour(x11, x22, x1x2out, [0 0], 'g-');
    hold off;

    figure
    hold on;
    idx = find (test_data_Y == 0);
    plot (test_data_X(idx,1), test_data_X(idx,2),  'or', 'LineWidth', 1);
    idx = find (test_data_Y == 1);
    plot (test_data_X(idx,1), test_data_X(idx,2),  '*b', 'LineWidth', 1);
    hold off;

    return;
