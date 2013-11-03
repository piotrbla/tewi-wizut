function [ Sum, Calmar, iS, sumR] = ROCd( C, pocz, kon, spread,...
    Duration, VolThreshold, VolLength, Buffer, SL, CloseAgo)

iS = 0; % przekroczenie 0 w górê - kupno (L)
sumR = [];
R = zeros(1,size(C,1));
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia

[ ROC_vec ] = CalculateROC(C,pocz, kon, CloseAgo);

volAverages=zeros(1, kon);
for i=2:kon
    volAverages(i) = mean(C(i-min(i-1,VolLength):i,5))-C(i,5);
end

for i=pocz:kon
    if ROC_vec(i)*ROC_vec(i-1)<=0   % przeciêcie krzywej ROC z zerem
        if ROC_vec(i-1) - Buffer >ROC_vec(i)  && volAverages(i)<VolThreshold% warunek kupna
            iS = iS + 1;
            R(i) = -C(i+Duration,4)+C(i+1,1)-spread;
            
            H=max(C(i+1:i+Duration,2));
            
            if (C(i+1,1)-H)<-SL
                R(i)=-SL;
            end
            
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
sumR = sumR(pocz:kon);
end