function [ sumReturn,Calmar,sumRb, returnPoint, countLose ] = Sb2(C,spread,paramBLength,paramBVolLength,...
    paramBDuration,paramBVolThreshold,paramBBuffer,paramBSL, maxes, volAverages, pocz, ilosc,maxLose)

sumReturn = 0;
Calmar = 0;
cSizes = size(C);
candlesCount = cSizes(1);
sumRb=zeros(1,candlesCount);
Rb=zeros(1,candlesCount);
dZ=zeros(1,candlesCount);
lb=0; %liczba otwieranych pozycji
ls = 0;
countLose = 0;
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
pocz = pocz + 1;
lastCandle = pocz + ilosc - 2;
compared = maxes(pocz:lastCandle,1) + paramBBuffer <C(pocz:lastCandle,4);
for i=pocz:lastCandle
    returnPoint = i- pocz;
    if compared(i-pocz+1)
        if volAverages(i)<paramBVolThreshold
            Rb(i)=-C(i+paramBDuration,4)+C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniÍciu po paramADuration kroku
            H=max(C(i+1:i+paramBDuration,2));
            
            if (C(i+1,1)-H)<-paramBSL
                Rb(i)=-paramBSL;
                ls=ls+1;
            end
            
            if Rb(i)<0
                countLose = countLose + 1;
            else
                countLose = 0;
            end
            lb=lb+1;
        end
    end
    sumRb(i)=sumRb(i-1) + Rb(i);  %krzywa narastania kapita≥u
    
    if sumRb(i)>recordReturn
        recordReturn=sumRb(i);
    end
    
    if countLose > maxLose
        return
    end
    
    if sumRb(i)-recordReturn<recordDrawdown
        recordDrawdown=sumRb(i)-recordReturn;  %obsuniecie maksymalne
    end
end
sumReturn=sumRb(lastCandle);
Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara

end

