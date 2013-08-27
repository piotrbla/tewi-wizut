function [ Sum, sumR, ROC_vec, Calmar, iL] = ROC_L_dur( C, k, Duration, spread )

pocz = k+2;
kon = size(C,1)-Duration;
iL = 0; % przekroczenie 0 w górê - kupno (L)
sumR = zeros(1,size(C,1));
R = zeros(1,size(C,1));
ROC_vec = zeros(1,kon-k+1);
ROC_vec(pocz-1) = ((C(pocz-1,4) - C(pocz-1-k,4))/C(pocz-1-k,4))*100;

recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia

for i=pocz:kon
    ROC_vec(i) = ((C(i,4) - C(i-k,4))/C(i-k,4))*100;
    if ROC_vec(i)*ROC_vec(i-1)<=0   % przeciêcie krzywej ROC z zerem
        if ROC_vec(i-1)<ROC_vec(i)  % warunek kupna
            iL = iL + 1;
            R(i) = C(i+Duration,4)-C(i+1,1)-spread;
        end
    end
    sumR(i) = sum(R(pocz:i));
    
    if sumR(i)>recordReturn
        recordReturn=sumR(i);
    end
    
    if sumR(i)-recordReturn<recordDrawdown
        recordDrawdown=sumR(i)-recordReturn;  
    end
end

Calmar=-sumR(kon)/recordDrawdown;
Sum = sumR(kon);
end