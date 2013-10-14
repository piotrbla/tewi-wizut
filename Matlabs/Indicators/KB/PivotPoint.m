clc; close all; clear all;
load('usdjpy60');
paramSectionLearn = C(1:5400,:);
paramSectionTest = C(5401:end,:);

[m,n]=size(paramSectionLearn);
[m1 n1]=size(paramSectionTest);

O=paramSectionLearn(:,1);
L=paramSectionLearn(:,3);
H=paramSectionLearn(:,2);
C=paramSectionLearn(:,4);

%Parametry 
pip = 0.01; % wielkosc pipsa na danym rynku
spread = 1.8 * pip; % spread dla rynku
% pip =1; % wielkosc pipsa na danym rynku

bestReturn = -100;
bestMa = 0;
%Czêœæ ucz¹ca

countCandleLearn=m;
lastCandleLearn=0;
krok=1;
%Czêœæ valid

paramALengthT=0;
countCandleTest=m1;
lastCandleTest=0;
chwi=1;
tmp=countCandleLearn-1;

P = (H + L + C) / 3;
R1 = 2*P - L;
S1 = 2*P - H;

sumRa=zeros(1,tmp);
Ra=zeros(1,tmp);
lastCandleLearn=tmp;
   
WinReturn=0;
DownReturn=0;
CalmarLearn=0;
BestCalLearn=0;
for paramALengthL=10:100 %liczba œwiec wstecz ( do max)
    chwi=chwi;

paramZakrespocz(chwi)=paramALengthL;
       
    %-------------obliczanie zysków

    
    for j=2:lastCandleLearn
        
        if R1(j)>C(j) && R1(j)<=C(j-1)
            Ra(j)=C(j+krok)-O(j+1)-spread ;% zysk z j-tej pozycji long zamykanej na zamkniêciu po 1 kroku 
        else if S1(j)<C(j) && S1(j)>=C(j-1)
             Ra(j)=-C(j+krok)+O(j+1)+spread   ; 
            end
        end

        sumRa(j)=sumRa(j-1)+Ra(j); %krzywa narastania kapita³u
        
        if sumRa(j)>WinReturn
            WinReturn=sumRa(j);
        end
        
        DownReturnTmp=sumRa(j)-WinReturn;
        if  DownReturnTmp<DownReturn
            DownReturn= DownReturnTmp;
        end
     
    end
    chwi=chwi+1;
 sumFinal=sumRa(lastCandleLearn);   
    if bestReturn < sumFinal
    bestMa=paramALengthL;
 end
end

% bestMa=miej;
% sumFinal=sumRa(lastCandleLearn);
CalmarLearn=-sumFinal/DownReturn;

%--------------------------------------------------------------------test
% O=0;
% L=0;
% H=0;
% C=0;

Ot=paramSectionTest(:,1);
Lt=paramSectionTest(:,3);
Ht=paramSectionTest(:,2);
Ct=paramSectionTest(:,4);

Pt=0; R1t=0; R2t=0; S1t=0; S2t = 0;

tmp1=countCandleTest-1;

Pt = (Ht + Lt + Ct) / 3;
R1t = 2*Pt - Lt;
S1t = 2*Pt - Ht;

sumRaT=zeros(1,tmp1);
RaT=zeros(1,tmp1);
lastCandleTest=tmp1;
   
WinReturnT=0;
DownReturnT=0;
CalmarLearnT=0;
BestCalLearnT=0;

for paramALengthT=bestMa %liczba œwiec wstecz ( do max)
paramZakrespocz(chwi)=paramALengthT;
       
    %-------------obliczanie zysków
 
    for j=2:lastCandleTest
        
    if R1t(j)>Ct(j) && R1t(j)<=Ct(j-1)
            RaT(j)=Ct(j+krok)-Ot(j+1)-spread ;% zysk z j-tej pozycji long zamykanej na zamkniêciu po 1 kroku 
        else if S1(j)<C(j) && S1(j)>=C(j-1)
             RaT(j)=-Ct(j+krok)+Ot(j+1)+spread   ; 
            end
        end

        sumRaT(j)=sumRaT(j-1)+RaT(j); %krzywa narastania kapita³u
        
        if sumRaT(j)>WinReturnT
            WinReturnT=sumRaT(j);
        end
        
        DownReturnT=sumRaT(j)-WinReturnT;
        if  DownReturnT<DownReturnT;
            DownReturnT= DownReturnT;
        end
     end
end

hFig1 = figure(1);
set(hFig1, 'Position', [200 200 640 480]);
plot(sumRa);
title(['Return: ', mfilename]);
xlabel('Candles count');
ylabel('Zysk');
set(hFig1, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig1,'-dpng', '-r0',[mfilename '_ZyskUcz'])

hFig2 = figure(2);
set(hFig2, 'Position', [200 200 640 480]);
plot(sumRaT);
title(['Return: ', mfilename]);
xlabel('Candles count');
ylabel('Zysk');
set(hFig2, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig2,'-dpng', '-r0',[mfilename '_ZyskTest'])

hFig3 = figure(3);
set(hFig3, 'Position', [200 200 640 480]);
plot(C(3:300));
hold on
plot(R1(3:300),'r')
plot(S1(3:300),'g')

hold off
title(['Return: ', mfilename]);
xlabel('Candles count');
ylabel('R1 S1');
set(hFig2, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig2,'-dpng', '-r0',[mfilename '_R1 S1'])

hFig4 = figure(4);
set(hFig4, 'Position', [200 200 640 480]);
plot(Ct(3:300));
hold on
plot(R1t(3:300),'r')
plot(S1t(3:300),'g')

hold off
title(['Return: ', mfilename]);
xlabel('Candles count');
ylabel('R1 S1');
set(hFig2, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig2,'-dpng', '-r0',[mfilename 'waliduj¹ce R1 S1'])