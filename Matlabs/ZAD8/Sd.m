function [ sumReturn,Calmar,sumRd ] = Sd(C,spread,paramDLength,paramDVolLength,...
    paramDDuration,paramDVolThreshold,paramDBuffer,paramDSL, maxes, volAverages, pocz, ilosc)

cSizes = size(C);
candlesCount = cSizes(1);
sumRd=zeros(1,candlesCount);
Rd=zeros(1,candlesCount);
dZ=zeros(1,candlesCount);
ld=0; %liczba otwieranych pozycji
ls = 0;
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
pocz = pocz + 1;
lastCandle = pocz + ilosc - 2;
compared = maxes(pocz:lastCandle,1) - paramDBuffer >C(pocz:lastCandle,4);
for i=pocz:lastCandle
    if compared(i-pocz+1)
        if  volAverages(i)<paramDVolThreshold
            Rd(i)=-C(i+paramDDuration,4)+C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniÍciu po paramADuration kroku
            H=max(C(i+1:i+paramDDuration,2));
            
            if (C(i+1,1)-H)<-paramDSL
                Rd(i)=-paramDSL;
                ls=ls+1;
            end
            
            ld=ld+1;
        end
    end
    sumRd(i)=sumRd(i-1) + Rd(i);  %krzywa narastania kapita≥u
    
    if sumRd(i)>recordReturn
        recordReturn=sumRd(i);
    end
    
    if sumRd(i)-recordReturn<recordDrawdown
         recordDrawdown=sumRd(i)-recordReturn; %obsuniecie maksymalne
    end
end
sumReturn=sumRd(lastCandle);
Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara

end