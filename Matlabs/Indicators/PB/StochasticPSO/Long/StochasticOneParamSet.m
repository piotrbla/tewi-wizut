%(C) Piotr B³aszyñski 2013
%skrypt strategii Stochastic Fast w projekcie TEWI - z dopasowaniem parametrów przy u¿yciu PSO
function [ zyl, Calmar, l_open] = StochasticOneParamSet( C, spread, pocz, kon, ...
    paramALength, paramAEmaLength, ...
    paramADuration, paramASL)
%UNTITLED StochasticFast for one ParamSet


%Dane:
cSizes = size(C);
candlesCount = cSizes(1);

kValues=zeros(1, candlesCount);
for i=2:kon %O-1, H-2, L-3, C-4
    maxValue = max(C(i-min(i-1,paramALength)+1:i,2));
    minValue = min(C(i-min(i-1,paramALength)+1:i,3));
    kValues(i)= 100*((C(i,4)-minValue)/(maxValue-minValue));
end
dValues = ema(kValues, paramAEmaLength);
%disp(['paramALength ', num2str(paramALength), '  paramAEmaLength ', num2str(paramAEmaLength)]);

sumRa=zeros(1,candlesCount);
Ra=zeros(1,candlesCount);
dZ=zeros(1,candlesCount);
%pocz=max(paramAEmaLength, paramALength)+2;
la=0; %liczba otwieranych pozycji
lastCandle = kon-max(paramALength, paramAEmaLength) - paramADuration;
for i=pocz:lastCandle
    
    if kValues(i)>dValues(i) && kValues(i-1)<=dValues(i-1)
        Ra(i)=C(i+paramADuration,4)-C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
        L=min(C(i+1:i+paramADuration,3));
        if (-C(i+1,1)+L)<-paramASL
            Ra(i)=-paramASL;
        end
        la=la+1;
    end
    sumRa(i)=sumRa(i-1) + Ra(i);  %krzywa narastania kapita³u
end


recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia

for j=1:lastCandle
    if sumRa(j)>recordReturn
        recordReturn=sumRa(j);
    end
    
    dZ(j)=sumRa(j)-recordReturn; %róznica pomiedzy bie¿¹c¹ wartoscia kapita³u skumulowanego a dotychczasowym rekordem
    
    if dZ(j)<recordDrawdown
        recordDrawdown=dZ(j);  %obsuniecie maksymalne
    end
    
end

%wyniki koñcowe
sumReturn=sumRa(lastCandle);
Calmar=-sumReturn/recordDrawdown;
zyl = sumReturn;
l_open = la;


