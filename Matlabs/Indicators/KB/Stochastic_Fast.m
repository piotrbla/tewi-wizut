% Katarzyna Buda 
% Stochastic Fast
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
tmp=countCandleLearn-1;
ValK=zeros(1, countCandleLearn);
paramZakrespocz=0;
chwi=1;
for paramALengthL=10:100 %liczba œwiec wstecz ( do max)
    chwi=chwi;
    paramZakrespocz(chwi)=paramALengthL;
   for i=2:tmp
       max3=max(H(max(i-paramALengthL, 1):i));
       min3=min(L(max(i-paramALengthL, 1):i));
      ValK(i)=100*(C(i)-min3)/(max3-min3);
   end
    ValD=ema(ValK,3);
    sumRa=zeros(1,tmp);
    Ra=zeros(1,tmp);
   lastCandleLearn=tmp;
       
    %-------------obliczanie zysków
    WinReturn=0;
    DownReturn=0;
    CalmarLearn=0;
    BestCalLearn=0;
    
    for j=2:lastCandleLearn
        
        if ValK(j)>ValD(j) && ValK(j-1)<=ValD(j)
            Ra(j)=C(j+krok)-O(j+1)-spread ;% zysk z j-tej pozycji long zamykanej na zamkniêciu po 1 kroku 
          else if ValK(j)<ValD(j) && ValK(j-1)>=ValD(j) 
            Ra(j)=-C(j+krok)+O(j+1)+spread; 
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
CalmarLearn=-sumFinal/DownReturn;

if bestReturn < sumFinal
    bestMa=paramALengthL;
end
end

% bestMa=miej;
sumFinal=sumRa(lastCandleLearn);
CalmarLearn=-sumFinal/DownReturn;

%---------------------------------------------------------------------------test!!!!!
O1=0;
H1=0;
L1=0;
C1=0;
O1=paramSectionTest(:,1);
L1=paramSectionTest(:,3);
H1=paramSectionTest(:,2);
C1=paramSectionTest(:,4);

% 
% 
 tmp=countCandleTest-1;
 ValK2=zeros(1, countCandleTest);
% 
% %----------------test
chwi=1;
for paramALengthT=bestMa; %liczba œwiec wstecz ( do max)
    chwi=chwi;
    paramZakrespocz(chwi)=paramALengthT;
   for i=2:tmp
       max3=max(H1(max(i-paramALengthT, 1):i));
       min3=min(L(max(i-paramALengthT, 1):i));
      ValK2(i)=100*(C1(i)-min3)/(max3-min3);
   end
    ValD2=ema(ValK2,3);
    sumRaT=zeros(1,tmp);
    RaT=zeros(1,tmp);
   lastCandleTest=tmp;
       
    %-------------obliczanie zysków
    WinReturnT=0;
    DownReturnT=0;
    CalmarTest=0;
    BestCalTest=0;
    
    for j=2:lastCandleTest
        
    if ValK2(j)>ValD2(j) && ValK2(j-1)<=ValD2(j)
            RaT(j)=C1(j+krok)-O1(j+1)-spread ;% zysk z j-tej pozycji long zamykanej na zamkniêciu po 1 kroku 
          else if ValK2(j)<ValD2(j) && ValK2(j-1)>=ValD2(j) 
            RaT(j)=-C1(j+krok)+O1(j+1)+spread; 
               end
        end
        sumRaT(j)=sumRaT(j-1)+RaT(j); %krzywa narastania kapita³u
        
        if sumRaT(j)>WinReturnT
            WinReturnT=sumRaT(j);
        end
        
        DownReturnTmpT=sumRaT(j)-WinReturnT;
        if  DownReturnTmpT<DownReturnT
            DownReturnT= DownReturnTmpT;
        end
     
    end
    chwi=chwi+1;   
end
 

sumFinalT=sumRaT(lastCandleTest);
CalmarTest=-sumFinalT/DownReturnT;  

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
plot(ValK(3:100),'r');
hold on;
plot(ValD(3:100));
title(['Stochastic Fast - strategia: ', mfilename]);
xlabel('Candles count');
ylabel('Oscillator');
set(hFig3, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig3,'-dpng', '-r0', [mfilename '_K_i_D_uczace'] )

hFig4 = figure(4);
set(hFig4, 'Position', [200 200 640 480]);
plot(ValK2(3:100),'r');
hold on;
plot(ValD2(3:100));
title(['Stochastic Fast - strategia: ', mfilename]);
xlabel('Candles count');
ylabel('Oscillator');
set(hFig4, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig4,'-dpng', '-r0', [mfilename '_K_i_D_testujace'])