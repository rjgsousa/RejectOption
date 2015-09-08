%-------------------------------------------------------------------------------------------------
%% 
function value = checkinterval(mmin,mmax)
    global filename
    step = 0;
    if mmin ~= mmax
        step  = (log2(mmax) - log2(mmin))/20;
        value = log2(mmin):step:log2(mmax);
    else
        a = log2(mmin)-1;
        b = log2(mmin)+1;
        step = 0.25;
        value = min(a,b):step:max(a,b);
    end

    fprintf(filename,'mmin: %f mmax: %f step: %f\n',mmin,mmax,step);
    return