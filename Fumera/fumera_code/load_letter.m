function [trainSetFeatures,trainSetClass] = load_letter()
    fd = fopen('letter-recognition.data','r');
    class = [];
    data  = [];

    i = 1;
    while 1
        fline = fgetl(fd);
        if ~ischar(fline),   break,   end
        
        %disp(fline)
        % fline(1)
        c = str2num(sprintf('%d',fline(1)))-65+1;

        if ~( c == 2 || c == 5 ), continue, end
        % classes are between 1-26
        class(i) = c;
        main = str2num(fline(3:end));
        data(i,:)  = main;

        i = i + 1;
    end
    fclose(fd);

    % %% lets create spaces between class so reject option (oSVM) may work
    % class = (class-65)*2;

    trainSetFeatures = data;
    trainSetClass = class';
    
    
    trainSetClass = 2*(max(trainSetClass)-trainSetClass)/(max(trainSetClass)-min(trainSetClass))-1;

    dlmwrite('be.txt',[trainSetFeatures trainSetClass]);
    return
