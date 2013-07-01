function [ sumReturn,Calmar] = Sa(C,spread, paramADuration,paramAVolThreshold,paramABuffer,paramASL, maxes, volAverages, pocz, ilosc)

cSizes = size(C);
candlesCount = cSizes(1);
sumRa=zeros(1,candlesCount);
Ra=0;
dZ=0;
la=0; %liczba otwieranych pozycji
ls = 0;
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
pocz = pocz + 1;
lastCandle = pocz + ilosc - 2;
compared = maxes(pocz:lastCandle) + paramABuffer <C(pocz:lastCandle,4) ;
for i=pocz:lastCandle
    
%    if maxes(i) + paramABuffer <C(i,4) 
    if compared(i-pocz+1) && volAverages(i)<paramAVolThreshold
            Ra=C(i+paramADuration,4)-C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniÍciu po paramADuration kroku
            L=min(C(i+1:i+paramADuration,3));
            
            if (-C(i+1,1)+L)<-paramASL
                Ra=-paramASL;
                ls=ls+1;
            end
            
            la=la+1;
        end
    sumRa(i)=sumRa(i-1) + Ra;  %krzywa narastania kapita≥u
    
    if sumRa(i)>recordReturn
        recordReturn=sumRa(i);
    end
    
	dZ=sumRa(i)-recordReturn; %rÛznica pomiedzy bieøπcπ wartoscia kapita≥u skumulowanego a dotychczasowym rekordem
    
    if dZ<recordDrawdown
        recordDrawdown=dZ;  %obsuniecie maksymalne
    end
end
sumReturn=sumRa(lastCandle);
Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara

end

