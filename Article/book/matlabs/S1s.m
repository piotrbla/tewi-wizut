function [] = S1s (C,ma,mb,mc,md,rynek)
%(C) Antoni Wiliñski 2013
%skrypt strategii S1 w projekcie TEWI
%S1a - pierwszy kwadrant - oznaczajacy za³o¿enie, ze trend jest rosnacy i

%nale¿y otwierac pozycje d³ugie wg zasady Buy Stop


sumRs=zeros(1,6000);
Ra=zeros(1,6000);
Rb=zeros(1,6000);
Rc=zeros(1,6000);
Rd=zeros(1,6000);
Rs=zeros(1,6000);
pocz=max([ma, mb, mc, md])+1;
if size(C,1)<5000
    kon = 2047;
else
    kon=5000-1;
end
ls=0; %liczba otwieranych pozycji


for i=pocz:kon
    if mean(C(i-ma:i,4))<C(i,4)
        Ra(i)=C(i+1,4)-C(i+1,1); %zysk z i-tej pozycji long zamykanej po jednym kroku (na koñcu swiecy, w której nastapi³o otwarcie)
    end
    if mean(C(i-mb:i,4))<C(i,4)
        Rb(i)=-C(i+1,4)+C(i+1,1);
    end
    if mean(C(i-mc:i,4))>C(i,4) 
        Rc(i)=C(i+1,4)-C(i+1,1);
    end
    if mean(C(i-md:i,4))>C(i,4) 
        Rd(i)=-C(i+1,4)+C(i+1,1);
    end
    Rs(i) = Ra(i) + Rb(i) + Rc(i) + Rd(i);
    ls=ls+1;
    sumRs(i)=sum(Rs(pocz:i));  %krzywa narastania kapita³u
    sumRa(i)=sum(Ra(pocz:i));
    sumRb(i)=sum(Rb(pocz:i));
    sumRc(i)=sum(Rc(pocz:i));
    sumRd(i)=sum(Rd(pocz:i));
end

%obliczenie wspó³czynnika Calmara (stosunku zysku koñcowego do najwiekszego
%obsuniecia)

recZ=0;  %rekord zysku
recO=0;  %rekord obsuniecia

for j=1:kon
    if sumRs(j)>recZ
        recZ=sumRs(j);
    end
    dZ(j)=sumRs(j)-recZ; %róznica pomiedzy bie¿¹c¹ wartoscia kapita³u skumulowanego a dotychczasowym rekordem
    
    if dZ(j)<recO
        recO=dZ(j);  %obsuniecie maksymalne
    end
end

%wyniki koñcowe
Calmar=-sumRs(kon)/recO;  %wskaznik Calmara            %zysk koñcowy
ls;
lap=ls/(kon-pocz);
sumRs(kon);
bestSumAll = sumRs;
disp(['Zysk: ' num2str(sumRs(kon))]);

ToTable = [round2(sumRs(kon),0.001) round2(Calmar,0.001) NaN ls];
save(['texRs_' rynek '.txt'],'ToTable','-ascii','-double')


hFig = figure;
set(hFig, 'Position', [200 200 840 400]);
bestSumAll = bestSumAll(bestSumAll~=0);
plot(bestSumAll);
xlim([0 length(bestSumAll)]);
xlabel('Swiece');
ylabel('Skumulowany zysk');
set(hFig, 'PaperPositionMode','auto') ;  %# WYSIWYG
print(hFig,'-depsc', '-r0',[mfilename '_' rynek]);
