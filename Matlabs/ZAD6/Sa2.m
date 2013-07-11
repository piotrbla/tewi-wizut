function [ sumReturn,Calmar,sumRa, returnPoint, countLose ] = Sa2(C,spread,paramALength,paramAVolLength,...
    paramADuration,paramAVolThreshold,paramABuffer,paramASL, maxes, volAverages, pocz, ilosc, maxLose)

% zwraca� countlose i przekazywac maxcountlose
sumReturn = 0;
Calmar = 0;
sumRa = 0;
cSizes = size(C);
candlesCount = cSizes(1);
sumRa=zeros(1,candlesCount);
Ra=zeros(1,candlesCount);
dZ=zeros(1,candlesCount);
la=0; %liczba otwieranych pozycji
ls = 0;
countLose = 0;
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
pocz = pocz + 1;
lastCandle = pocz + ilosc - 2;
compared = maxes(pocz:lastCandle,1) + paramABuffer <C(pocz:lastCandle,4) ;
for i=pocz:lastCandle
    returnPoint = i - pocz;
%    if maxes(i) + paramABuffer <C(i,4) 
    if compared(i-pocz+1)
        if volAverages(i)<paramAVolThreshold
            Ra(i)=C(i+paramADuration,4)-C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniÍciu po paramADuration kroku
            L=min(C(i+1:i+paramADuration,3));
            
            if (-C(i+1,1)+L)<-paramASL
                Ra(i)=-paramASL;
                ls=ls+1;
            end
            if Ra(i) < 0
                countLose = countLose + 1;
            else
                countLose = 0;
            end
            la=la+1;
        end
    end
    sumRa(i)=sumRa(i-1) + Ra(i);  %krzywa narastania kapita≥u
    
    if sumRa(i)>recordReturn
        recordReturn=sumRa(i);
    end
    if countLose > maxLose
        return
    end
    if sumRa(i)-recordReturn<recordDrawdown
         recordDrawdown=sumRa(i)-recordReturn;  %obsuniecie maksymalne
    end
end
sumReturn=sumRa(lastCandle);
Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara

end