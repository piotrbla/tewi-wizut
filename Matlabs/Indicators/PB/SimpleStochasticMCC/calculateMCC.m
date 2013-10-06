function [ CM, MCC, P, R ] = calculateMCC( M )
%calculates MCC Matthews Correlation Coefficient
%  easy to interpret predictor classification (+1 - perfect predictor, 0 - random, -1 perfectly perverse predictor)
% CM - confusion matrix,  MCC - Matthews Correlation Coefficient, P - precision, R
CM = [M.TP M.FP; M.FN M.TN];
MCC = (M.TP*M.TN-M.FP*M.FN)/sqrt((M.TP+M.FP)*(M.TP+M.FN)*(M.TN+M.FP)*(M.TN+M.FN));
P=M.TP/(M.TP+M.FP);
R=M.TP/(M.TP+M.FN);
end

