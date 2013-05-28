%(C) Antoni Wiliñski 2013
%skrypt strategii S1 w projekcie TEWI
%S1a - pierwszy kwadrant - oznaczajacy za³o¿enie, ze trend jest rosnacy i
%nale¿y otwierac pozycje d³ugie wg zasady Buy Stop

%Dane:
tStart=tic;
eurusd1h020313;
cSizes = size(C);
candlesCount = cSizes(1);
bestCalmar = 0;
bestMa = 0;
%commission = 0.00016;
commission = 0.000;
%parametry:
ma=6; %liczba swiec wstecz do obliczenia sredniej

for ma=4:4
    sumRa=zeros(1,candlesCount);
    Ra=zeros(1,candlesCount);
    dZ=zeros(1,candlesCount);
    pocz=ma+1;
    kon=candlesCount-1;
    la=0; %liczba otwieranych pozycji
    
    
    for i=pocz:kon
        if mean(C(i-ma:i,4))>C(i,4)
            Ra(i)=C(i+1,4)-C(i+1,1)-commission; %zysk z i-tej pozycji long zamykanej po jednym kroku (na koñcu swiecy, w której nastapi³o otwarcie)
            la=la+1;
        end
        sumRa(i)=sum(Ra(pocz:i));  %krzywa narastania kapita³u
    end
    
    %obliczenie wspó³czynnika Calmara (stosunku zysku koñcowego do najwiekszego
    %obsuniecia)
    
    recordReturn=0;  %rekord zysku
    recordDrawdown=0;  %rekord obsuniecia
    
    for j=1:kon
        if sumRa(j)>recordReturn
            recordReturn=sumRa(j);
        end
        
        dZ(j)=sumRa(j)-recordReturn; %róznica pomiedzy bie¿¹c¹ wartoscia kapita³u skumulowanego a dotychczasowym rekordem
        
        if dZ(j)<recordDrawdown
            recordDrawdown=dZ(j);  %obsuniecie maksymalne
        end
        
    end
    
    %wyniki koñcowe
    
    Calmar=-sumRa(kon)/recordDrawdown;  %wskaznik Calmara
    if bestCalmar<Calmar
        bestCalmar=Calmar;
        bestMa = ma;
    end
    sumRa(kon)               %zysk koñcowy
end
sumReturn = sumRa(kon)
bestCalmar
la                       %liczba otwartych pozycji
bestMa
sharpeRatio = sharpe(sumRa, 0)

% lap=la/(kon-pocz)
%
figure(1)
plot(sumRa)

%figure(2)
%plot(C(pocz:kon,4))
tElapsed=toc(tStart)