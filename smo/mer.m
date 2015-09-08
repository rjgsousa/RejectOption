
%%
%
function merror = mer(l1,l2)
    [l1 l2];
    merror = length( find(  ( l1 - l2 ) ~= 0 ) )/ length(l1);
    
    fprintf(1,'MER: %.2f\n',merror);
    return