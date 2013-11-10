function [] = S1d (C,md,rynek)
%(C) Antoni Wiliñski 2013
%skrypt strategii S1 w projekcie TEWI
%S1d - czwarty kwadrant - oznaczajacy za³o¿enie, ze trend jest spadkowy i
%nale¿y otwierac pozycje krótkie


candlesCount = size(C,1);
%candlesCount(1)=5000;
bestSumRd = -Inf;
bestCalmard = -Inf;

for md=md
    means=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        means(i) = mean(C(i-min(i-1,md):i-1,4));
    end
    sumRd=zeros(1,6000);
    wykr=zeros(1,6000);
    Rd=zeros(1,6000);
    pocz=md+1;
    if size(C,1)<5000
        kon = 2047;
    else
        kon=5000-1;
    end
    ld=0; %liczba otwieranych pozycji
    
    for i=pocz:kon
        if means(i)>C(i,4)
            Rd(i)=-C(i+1,4)+C(i+1,1);%short zamykana po jednym kroku (na koñcu swiecy, w której nastapi³o otwarcie)
            ld=ld+1;
        end
        sumRd(i)=sum(Rd(pocz:i));
    end
    
    %obliczenie wspó³czynnika Calmara (stosunku zysku koñcowego do najwiekszego
    %obsuniecia)
    
    recZ=0;  %rekord zysku
    recO=0;  %rekord obsuniecia
    
    for j=1:kon
        if sumRd(j)>recZ
            recZ=sumRd(j);
        end
        dZ(j)=sumRd(j)-recZ; %róznica pomiedzy bie¿¹c¹ wartoscia kapita³u skumulowanego a dotychczasowym rekordem
        if dZ(j)<recO
            recO=dZ(j);  %obsuniecie maksymalne
        end 
    end
    
    %wyniki koñcowe
    Calmar=-sumRd(kon)/recO;  %wskaznik Calmara
    if sumRd(kon)>bestSumRd
        bestSumRd = sumRd(kon);
        bestSumAll = sumRd;
        bestCalmard = Calmar;
        bestLd = ld;  %liczba otwartych pozycji
        bestLdp=ld/(kon-pocz);
        bestMd = md;
        disp(['Zysk: ' num2str(sumRd(kon)) ' dla md: ' num2str(md)]);
    end 
end


ToTable = [round2(bestSumRd,0.001) round2(bestCalmard,0.001) bestMd bestLd];
save(['texRd_' rynek '.txt'],'ToTable','-ascii','-double')


hFig = figure;
set(hFig, 'Position', [200 200 840 400]);
bestSumAll = bestSumAll(bestSumAll~=0);
plot(bestSumAll);
xlim([0 length(bestSumAll)]);
xlabel('Swiece');
ylabel('Skumulowany zysk');
set(hFig, 'PaperPositionMode','auto') ;  %# WYSIWYG
print(hFig,'-depsc', '-r0',[mfilename '_' rynek]);