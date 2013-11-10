function [] = S1a (C,ma,rynek)
%(C) Antoni Wiliñski 2013
%skrypt strategii S1 w projekcie TEWI
%S1a - pierwszy kwadrant - oznaczajacy za³o¿enie, ze trend jest rosnacy i
%nale¿y otwierac pozycje d³ugie wg zasady Buy Stop

candlesCount = size(C,1);

% candlesCount(1)=5000;
bestSumRa = -Inf;
bestCalmara = -Inf;

for ma=ma
    means=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        means(i) = mean(C(i-min(i-1,ma):i,4));
    end
    sumRa=zeros(1,6000);
    Ra=zeros(1,6000);
    pocz=ma+1;
    if size(C,1)<5000
        kon = 2047;
    else
        kon=5000-1;
    end
    la=0; %liczba otwieranych pozycji

    for i=pocz:kon
        if means(i)<C(i,4)
       % if mean(C(i-ma:i,4))<C(i,4) && mean(C(i-ma:i,4))>C(i-1,4)
            Ra(i)=C(i+1,4)-C(i+1,1); %zysk z i-tej pozycji long zamykanej po jednym kroku (na koñcu swiecy, w której nastapi³o otwarcie)
            la=la+1;
        end
        sumRa(i)=sum(Ra(pocz:i));  %krzywa narastania kapita³u
    end
    
    %obliczenie wspó³czynnika Calmara (stosunku zysku koñcowego do najwiekszego
    %obsuniecia)
    
    recZ=0;  %rekord zysku
    recO=0;  %rekord obsuniecia
    
    for j=1:kon
        if sumRa(j)>recZ
            recZ=sumRa(j);
        end
        dZ(j)=sumRa(j)-recZ; %róznica pomiedzy bie¿¹c¹ wartoscia kapita³u skumulowanego a dotychczasowym rekordem
        if dZ(j)<recO
            recO=dZ(j);  %obsuniecie maksymalne
        end 
    end
    %wyniki koñcowe
    Calmar=-sumRa(kon)/recO;  %wskaznik Calmara
    if sumRa(kon)>bestSumRa
        bestSumRa = sumRa(kon);
        bestSumAll = sumRa;
        bestCalmara = Calmar;
        bestLa = la;  %liczba otwartych pozycji
        bestLap=la/(kon-pocz);
        bestMa = ma;
        disp(['Zysk: ' num2str(sumRa(kon)) ' dla ma: ' num2str(ma)]);
    end              
end


ToTable = [round2(bestSumRa,0.001) round2(bestCalmara,0.001) bestMa bestLa];
save(['texRa_' rynek '.txt'],'ToTable','-ascii','-double');

hFig = figure;
set(hFig, 'Position', [200 200 840 400]);
bestSumAll = bestSumAll(bestSumAll~=0);
plot(bestSumAll);
xlim([0 length(bestSumAll)]);
xlabel('Swiece');
ylabel('Skumulowany zysk');
set(hFig, 'PaperPositionMode','auto') ;  %# WYSIWYG
print(hFig,'-depsc', '-r0',[mfilename '_' rynek]);
