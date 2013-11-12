function [] = S1c (C,mc,rynek)
%(C) Antoni Wiliñski 2013
%skrypt strategii S1 w projekcie TEWI
%S1c - trzeci kwadrant - oznaczajacy za³o¿enie, ze trend jest horyzontalny i
%nale¿y otwierac pozycje d³ugie wg zasady Buy Limit

candlesCount = size(C,1);
%candlesCount(1)=5000;
bestSumRc = -Inf;
bestCalmarc = -Inf;


for mc=mc
    means=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        means(i) = mean(C(i-min(i-1,mc):i,4));
    end
    sumRc=zeros(1,6000);
    Rc=zeros(1,6000);
    pocz=mc+1;
    if size(C,1)<5000
        kon = 2047;
    else
        kon=5000-1;
    end
    lc=0; %liczba otwieranych pozycji

    for i=pocz:kon
        if means(i)>C(i,4)
            Rc(i)=C(i+1,4)-C(i+1,1); %zysk z i-tej pozycji long zamykanej po jednym kroku (na koñcu swiecy, w której nastapi³o otwarcie)
            lc=lc+1;
        end
        sumRc(i)=sum(Rc(pocz:i));  %krzywa narastania kapita³u
    end
    
    %obliczenie wspó³czynnika Calmara (stosunku zysku koñcowego do najwiekszego
    %obsuniecia)
    
    recZ=0;  %rekord zysku
    recO=0;  %rekord obsuniecia
    
    for j=1:kon
        if sumRc(j)>recZ
            recZ=sumRc(j);
        end
        dZ(j)=sumRc(j)-recZ; %róznica pomiedzy bie¿¹c¹ wartoscia kapita³u skumulowanego a dotychczasowym rekordem
        if dZ(j)<recO
            recO=dZ(j);  %obsuniecie maksymalne
        end
    end
    %wyniki koñcowe
    Calmar=-sumRc(kon)/recO;  %wskaznik Calmara
    if sumRc(kon)>bestSumRc
        bestSumRc = sumRc(kon);
        bestSumAll = sumRc;
        bestCalmarc = Calmar;
        bestLc = lc;  %liczba otwartych pozycji
        bestLcp=lc/(kon-pocz);
        bestMc = mc;
        disp(['Zysk: ' num2str(sumRc(kon)) ' dla mc: ' num2str(mc)]);
    end  
end

ToTable = [round2(bestSumRc,0.001) round2(bestCalmarc,0.001) bestMc bestLc];
save(['texRc_' rynek '.txt'],'ToTable','-ascii','-double')


hFig = figure;
set(hFig, 'Position', [200 200 840 400]);
bestSumAll = bestSumAll(bestSumAll~=0);
plot(bestSumAll);
xlim([0 length(bestSumAll)]);
xlabel('Swiece');
ylabel('Skumulowany zysk');
set(hFig, 'PaperPositionMode','auto') ;  %# WYSIWYG
print(hFig,'-depsc', '-r0',[mfilename '_' rynek]);
