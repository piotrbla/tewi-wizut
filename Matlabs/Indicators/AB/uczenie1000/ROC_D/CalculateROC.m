function [ ROC_vec ] = CalculateROC(C_learn,pocz, kon, CloseAgo)

ROC_vec = zeros(1,kon-CloseAgo+1);
ROC_vec(pocz-1) = ((C_learn(pocz-1,4) - C_learn(pocz-1-CloseAgo,4))/C_learn(pocz-1-CloseAgo,4))*100;
for i=pocz:kon
    ROC_vec(i) = ((C_learn(i,4) - C_learn(i-CloseAgo,4))/C_learn(i-CloseAgo,4))*100;
end

end

