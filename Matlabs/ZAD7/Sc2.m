function [ sumReturn,Calmar,sumRc, returnPoint, countLose ] = Sc2(C,spread,paramCLength,paramCVolLength,...
    paramCDuration,paramCVolThreshold,paramCBuffer,paramCSL, maxes, volAverages, pocz, ilosc, maxLose)

sumReturn = 0;
Calmar = 0;
cSizes = size(C);
candlesCount = cSizes(1);
sumRc=zeros(1,candlesCount);
Rc=zeros(1,candlesCount);
dZ=zeros(1,candlesCount);
lc=0; %liczba otwieranych pozycji
ls = 0;
countLose = 0;
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
pocz = pocz + 1;
lastCandle = pocz + ilosc - 2;
compared = maxes(pocz:lastCandle,1) - paramCBuffer >C(pocz:lastCandle,4);
for i=pocz:lastCandle
    returnPoint = i - pocz;
    if compared(i-pocz+1)
        if  volAverages(i)<paramCVolThreshold
            Rc(i)=C(i+paramCDuration,4)-C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniÍciu po paramADuration kroku
            L=min(C(i+1:i+paramCDuration,3));
            
            if (-C(i+1,1)+L)<-paramCSL
                Rc(i)=-paramCSL;
                ls=ls+1;
            end
            if Rc(i)<0
                countLose = countLose +1;
            else
                countLose = 0;
            end
            lc=lc+1;
        end
    end
    sumRc(i)=sumRc(i-1) + Rc(i);  %krzywa narastania kapita≥u
    
    if sumRc(i)>recordReturn
        recordReturn=sumRc(i);
    end
    if countLose > maxLose
        return
    end
    if sumRc(i)-recordReturn<recordDrawdown
         recordDrawdown=sumRc(i)-recordReturn;  %obsuniecie maksymalne
    end
end
sumReturn=sumRc(lastCandle);
Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara

end

