function [] = S1b (C,mb,rynek)
%(C) Antoni Wiliñski 2013
%skrypt strategii S1 w projekcie TEWI
%S1b - drugikwadrant kwadrant - oznaczajacy za³o¿enie, ze trend jest horyzontalny i
%nale¿y otwierac pozycje krótkie wg zasady Sell Limit

candlesCount = size(C,1);
bestSumRb = -Inf;
bestCalmarb = -Inf;

for mb=mb%10:50
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
            Rb(i)=-C(i+1,4)+C(i+1,1); %zysk z i-tej pozycji short zamykanej po jednym kroku (na koñcu swiecy, w której nastapi³o otwarcie)
            lb=lb+1;
        end
        sumRb(i)=sum(Rb(pocz:i));  %krzywa narastania kapita³u
    end
    
    %obliczenie wspó³czynnika Calmara (stosunku zysku koñcowego do najwiekszego
    %obsuniecia)
    
    recZ=0;  %rekord zysku
    recO=0;  %rekord obsuniecia
    
    for j=1:kon
        if sumRb(j)>recZ
            recZ=sumRb(j);
        end
        dZ(j)=sumRb(j)-recZ; %róznica pomiedzy bie¿¹c¹ wartoscia kapita³u skumulowanego a dotychczasowym rekordem
        if dZ(j)<recO
            recO=dZ(j);  %obsuniecie maksymalne
        end
    end
    %wyniki koñcowe
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


ToTable = [bestSumRb bestCalmarb bestMb bestLb];
save(['texRb_' rynek '.txt'],'ToTable','-ascii','-double');

hFig = figure;
xlim([0 kon]);
set(hFig, 'Position', [200 200 840 400]);
bestSumAll = bestSumAll(bestSumAll~=0);
plot(bestSumAll);
xlabel('Candles');
ylabel('Profit');
set(hFig, 'PaperPositionMode','auto');   %# WYSIWYG
print(hFig,'-depsc', '-r0',mfilename);