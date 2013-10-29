function [] = S1b (C,mb,rynek)
%(C) Antoni Wili�ski 2013
%skrypt strategii S1 w projekcie TEWI
%S1b - drugikwadrant kwadrant - oznaczajacy za�o�enie, ze trend jest horyzontalny i
%nale�y otwierac pozycje kr�tkie wg zasady Sell Limit

candlesCount = size(C,1);
%candlesCount(1)=5000;
bestSumRb = -Inf;
bestCalmarb = -Inf;

for mb=mb
    means=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        means(i) = mean(C(i-min(i-1,mb):i,4));
    end
    sumRb=zeros(1,6000);
    Rb=zeros(1,6000);
    pocz=mb+1;
    if size(C,1)<5000
        kon = 2047;
    else
        kon=5000-1;
    end
    lb=0; %liczba otwieranych pozycji
    
    for i=pocz:kon
        if means(i)<C(i,4)
            Rb(i)=-C(i+1,4)+C(i+1,1); %zysk z i-tej pozycji short zamykanej po jednym kroku (na ko�cu swiecy, w kt�rej nastapi�o otwarcie)
            lb=lb+1;
        end
        sumRb(i)=sum(Rb(pocz:i));  %krzywa narastania kapita�u
    end
    
    %obliczenie wsp�czynnika Calmara (stosunku zysku ko�cowego do najwiekszego
    %obsuniecia)
    
    recZ=0;  %rekord zysku
    recO=0;  %rekord obsuniecia
    
    for j=1:kon
        if sumRb(j)>recZ
            recZ=sumRb(j);
        end
        dZ(j)=sumRb(j)-recZ; %r�znica pomiedzy bie��c� wartoscia kapita�u skumulowanego a dotychczasowym rekordem
        if dZ(j)<recO
            recO=dZ(j);  %obsuniecie maksymalne
        end
    end
    %wyniki ko�cowe
    Calmar=-sumRb(kon)/recO;  %wskaznik Calmara
    if sumRb(kon)>bestSumRb
        bestSumRb = sumRb(kon);
        bestSumAll = sumRb;
        bestCalmarb = Calmar;
        bestLb = lb;  %liczba otwartych pozycji
        bestLbp=lb/(kon-pocz);
        bestMb = mb;
        disp(['Zysk: ' num2str(sumRb(kon)) ' dla mb: ' num2str(mb)]);
    end 
    
end


ToTable = [round2(bestSumRb,0.001) round2(bestCalmarb,0.001) bestMb bestLb];
save(['texRb_' rynek '.txt'],'ToTable','-ascii','-double');


hFig = figure;
set(hFig, 'Position', [200 200 840 400]);
bestSumAll = bestSumAll(bestSumAll~=0);
plot(bestSumAll);
xlim([0 length(bestSumAll)]);
xlabel('Candles');
ylabel('Profit');
set(hFig, 'PaperPositionMode','auto') ;  %# WYSIWYG
print(hFig,'-depsc', '-r0',[mfilename '_' rynek]);