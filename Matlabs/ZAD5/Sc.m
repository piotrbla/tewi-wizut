function [ sumReturn,Calmar ] = Sc(C,spread,paramCLength,paramCVolLength,...
    paramCDuration,paramCVolThreshold,paramCBuffer,paramCSL, maxes, volAverages, pocz, ilosc)

cSizes = size(C);
candlesCount = cSizes(1);
sumRc=zeros(1,candlesCount);
Rc=zeros(1,candlesCount);
dZ=zeros(1,candlesCount);
lc=0; %liczba otwieranych pozycji
ls = 0;
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
pocz = pocz + 1;
lastCandle = pocz + ilosc - 2;
compared = maxes(pocz:lastCandle,1) - paramCBuffer >C(pocz:lastCandle,4);
for i=pocz:lastCandle
    if compared(i-pocz+1)
        if  volAverages(i)<paramCVolThreshold
            Rc(i)=C(i+paramCDuration,4)-C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniÍciu po paramADuration kroku
            L=min(C(i+1:i+paramCDuration,3));
            
            if (-C(i+1,1)+L)<-paramCSL
                Rc(i)=-paramCSL;
                ls=ls+1;
            end
            
            lc=lc+1;
        end
    end
    sumRc(i)=sumRc(i-1) + Rc(i);  %krzywa narastania kapita≥u
    
    if sumRc(i)>recordReturn
        recordReturn=sumRc(i);
    end
    
    if sumRc(i)-recordReturn<recordDrawdown
        recordDrawdown=dZ(i);  %obsuniecie maksymalne
    end
end
sumReturn=sumRc(lastCandle);
Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara

end
