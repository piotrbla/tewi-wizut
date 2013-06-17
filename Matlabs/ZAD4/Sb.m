function [ sumReturn,Calmar ] = Sb(C,spread,paramBLength,paramBVolLength,...
    paramBDuration,paramBVolThreshold,paramBBuffer,paramBSL, maxes, volAverages, pocz, ilosc)

cSizes = size(C);
candlesCount = cSizes(1);
sumRb=zeros(1,candlesCount);
Rb=zeros(1,candlesCount);
dZ=zeros(1,candlesCount);
lb=0; %liczba otwieranych pozycji
ls = 0;
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
pocz = pocz + 1;
lastCandle = pocz + ilosc - 2;

for i=pocz:lastCandle
    
    if maxes(i) + paramBBuffer <C(i,4) && volAverages(i)<paramBVolThreshold
        Rb(i)=-C(i+paramBDuration,4)+C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniÍciu po paramADuration kroku
        H=max(C(i+1:i+paramBDuration,2));
        
        if (C(i+1,1)-H)<-paramBSL
            Rb(i)=-paramBSL;
            ls=ls+1;
        end
        
        lb=lb+1;
    end
    sumRb(i)=sumRb(i-1) + Rb(i);  %krzywa narastania kapita≥u
    
    if sumRb(i)>recordReturn
        recordReturn=sumRb(i);
    end
    
    dZ(i)=sumRb(i)-recordReturn; %rÛznica pomiedzy bieøπcπ wartoscia kapita≥u skumulowanego a dotychczasowym rekordem
    
    if dZ(i)<recordDrawdown
        recordDrawdown=dZ(i);  %obsuniecie maksymalne
    end
end
sumReturn=sumRb(lastCandle);
Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara

end

