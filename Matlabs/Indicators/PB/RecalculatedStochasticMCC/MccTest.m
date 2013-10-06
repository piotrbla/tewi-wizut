for i =1:9999
    M.TP=i;M.FP=1000;M.FN=1000;M.TN=i;
    [ CM, MCC, P, R ] = calculateMCC( M );
    mccs(i)= MCC;
    precs(i) = P;
end
plot (mccs);
hold all;
plot (precs);