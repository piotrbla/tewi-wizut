function [ CM, MCC, P, R ] = calculateMCC( M, S )
%calculates MCC Matthews Correlation Coefficient
%  easy to interpret predictor classification (+1 - perfect predictor, 0 - random, -1 perfectly perverse predictor)
% CM - confusion matrix,  MCC - Matthews Correlation Coefficient, P - precision, R

CM=cell(1,S);
MCC=zeros(1,S);
P=zeros(1,S);
R=zeros(1,S);
for i = 1:S
    CM(i) = {[M.TP(i) M.FP(i); M.FN(i) M.TN(i)]};
    MCC(i) = (M.TP(i)*M.TN(i)-M.FP(i)*M.FN(i))/sqrt((M.TP(i)+M.FP(i))*(M.TP(i)+M.FN(i))*(M.TN(i)+M.FP(i))*(M.TN(i)+M.FN(i)));
    P(i)=M.TP(i)/(M.TP(i)+M.FP(i));
    R(i)=M.TP(i)/(M.TP(i)+M.FN(i));
end
end

