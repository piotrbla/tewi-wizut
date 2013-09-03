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
pip =1; % wielkosc pipsa na danym rynku

bestReturn = -1000;
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
    BestCalLEarn=0;
    
    for j=2:lastCandleLearn
        
        if ValK(j)>ValD(j) || ValK(j)<=ValD(j)
            Ra(j)=C(j+krok)-O(j+1)-spread ;% zysk z j-tej pozycji long zamykanej na zamkniêciu po 1 kroku 
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
end
[roz miej]=max(sumRa);
bestMa=paramZakrespocz(miej);
% bestMa=miej;
sumFinal=sumRa(lastCandleLearn);
CalmarLearn=-sumFinal/DownReturn;

O=paramSectionTest(:,1);
L=paramSectionTest(:,3);
H=paramSectionTest(:,2);
C=paramSectionTest(:,4);


tmp=countCandleTest-1;
ValK2=zeros(1, countCandleLearn);

%----------------test
for paramALengthT=bestMa %liczba œwiec wstecz ( do max)
   for i=2:tmp
       max3=max(H(max(i-paramALengthT, 1):i));
       min3=min(L(max(i-paramALengthT, 1):i));
      ValK2(i)=100*(C(i)-min3)/(max3-min3);
   end
    ValD2=ema(ValK2,3);
    sumRaTest=zeros(1,tmp);
    RaTest=zeros(1,tmp);
   lastCandleTest=tmp;
    
    
    %-------------obliczanie zysków
    WinReturnTest=0;
    DownReturnTest=0;
    CalmarTest=0;
    BestCalTest=0;
    
    for j=2:lastCandleTest
        
        if ValK2(j)>ValD2(j) && ValK2(j)<=ValD2(j)
            RaTest(j)=C(j+krok)-O(j+1)-spread ;% zysk z j-tej pozycji long zamykanej na zamkniêciu po 1 kroku 
        end

        sumRaTest(j)=sumRaTest(j-1)+RaTest(j); %krzywa narastania kapita³u
        
        if sumRaTest(j)>WinReturnTest
            WinReturnTest=sumRaTest(j);
        end
        
        DownReturnTmpTest=sumRaTest(j)-WinReturnTest;
        if  DownReturnTmpTest<DownReturnTest
            DownReturnTest= DownReturnTmpTest;
        end
     
    end
  
end
sumFinTest=sumRaTest(lastCandleTest);
CalmarTest=-sumFinal/DownReturn;  

hFig1 = figure(1);
set(hFig1, 'Position', [200 200 640 480]);
plot(sumRa);
title(['Return: ', mfilename]);
xlabel('Candles count');
ylabel('Zysk');
set(hFig1, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig1,'-dpng', '-r0',[mfilename '_ZyskUcz'])

hFig1 = figure(2);
set(hFig1, 'Position', [200 200 640 480]);
plot(sumRaTest);
title(['Return: ', mfilename]);
xlabel('Candles count');
ylabel('Zysk');
set(hFig1, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig1,'-dpng', '-r0',[mfilename '_ZyskTest'])

hFig2 = figure(3);
set(hFig2, 'Position', [200 200 640 480]);
plot(ValK(3:300),'r');
hold on;
plot(ValD(3:300));
title(['Stochastic Fast - strategia: ', mfilename]);
xlabel('Candles count');
ylabel('Oscillator');
set(hFig2, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig2,'-dpng', '-r0', [mfilename '_K_i_D_uczace'] )

hFig2 = figure(4);
set(hFig2, 'Position', [200 200 640 480]);
plot(ValK2(3:300),'r');
hold on;
plot(ValD2(3:300));
title(['Stochastic Fast - strategia: ', mfilename]);
xlabel('Candles count');
ylabel('Oscillator');
set(hFig2, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig2,'-dpng', '-r0', [mfilename '_K_i_D_testujace'])