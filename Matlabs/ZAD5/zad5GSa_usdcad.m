clc
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%
% Ustawienia:
USDCAD60_111120110000;
mfilename = 'S4a-usdcad';
pip = 0.00001; % wielkosc pipsa na danym rynku
spread = 40 * pip; % spread dla rynku

VparamASectionLearn = 600:100:1500; % 2 przebieg (dla tych najlepszych = wyn) wyn-75 : 25 : wyn+75; % dlugosc
paramASectionTest = 250; % dlugosc
%%%%%%%%%%%%%%%%%%%%%%

% Parametry podstawowe
VparamALength = [20 44 2 8 14];% 26 38 50];% 32]; % liczba swiec dla obliczenia sredniej
VparamAVolLength = [14 8 10 28 22];% 12 6 16 36 42 2];% 48];%2:2:30; % liczba sweic wstecz dla obliczenia sredniego wolumenu
VparamADuration = [62 26 14 44 32];% 2 20 68 8 50];% 38]; % dlugosc trwania otwartej pozycji
VparamAVolThreshold = [80 -100 30 100 -60]; % prog dla volumenu
VparamABuffer = -10*pip:10*pip:10*pip; % wielkosc bufora
VparamASL = [0.01 0.02];%8*spread:2*spread:30*spread; % wartosc stop loss


zad5Sa_usdcad
[u i] = max(sectionResult);
VparamASectionLearn = (paramy(i,1)-1) - 75 : 25 : (paramy(i,1)-1) - 75;
zad5Sa_usdcad
[u i] = max(sectionResult);

bestReturn=-10000;
cSizes = size(C);
candlesCount = cSizes(1);
bestCalmar = 0;
bestMa = 0;
bestparamALength = 0;
bestparamAVolLength = 0;
bestparamADuration = 0;
bestparamABuffer = 0;
bestparamAVolThreshold = 0;
bestparamASL = 0;
lastCandle = 0 ;
paramASectionLearn = paramy(i,1);
sectionCounter = floor((candlesCount - paramASectionLearn) / paramASectionTest) - 2;
sectionResult = zeros(1,sectionCounter);

for startingSection = 0:sectionCounter
    %for startingSection = 0:sectionCounter
    %	disp(['# startingSection', num2str(startingSection), ...
    %           '  sectionCounter:', num2str(sectionCounter), '  vr:', num2str(vr)]);
    bigPoint = (startingSection*paramASectionTest)+1;%% poczatek naszego duzego okna uczacego
    disp(['# Postep - przesuniecie okna na ', num2str(bigPoint), ' swiece dla okresu ', num2str(paramASectionLearn), ' Czas: ', num2str(toc(tStart))]);
    bestReturn=-10000;
    sectionLearnStart = bigPoint;
    
    for vi = 1:length(VparamALength)
        paramALength = VparamALength(vi);
        
        maxes=zeros(paramASectionLearn,1);
        kon=(sectionLearnStart+paramASectionLearn)-1;
        ii=1;
        for i=sectionLearnStart:kon
            maxes(ii) = max(C(i-min(i-1,paramALength):i,4));
            ii=ii+1;
        end
        
        for vj = 1:length(VparamAVolLength)
            paramAVolLength = VparamAVolLength(vj);
            
            %disp(['# Postep: ', num2str(round(iterCounter/iterTotal*100)), '%   Czas: ', num2str(toc(tStart))]);
            
            volAverages=zeros(1, paramASectionLearn);
            ii=1;
            for i=sectionLearnStart:kon
                volAverages(ii) = mean(C(i-min(i-1,paramAVolLength):i,5))-C(i,5);
                ii=ii+1;
            end
            
            for vk = 1:length(VparamADuration)
                paramADuration = VparamADuration(vk);
                
                for vl = 1:length(VparamAVolThreshold)
                    paramAVolThreshold =  VparamAVolThreshold(vl);
                    
                    for vm = 1:length(VparamABuffer)
                        paramABuffer = VparamABuffer(vm);
                        
                        for vn = 1:length(VparamASL)
                            paramASL = VparamASL(vn);
                            [ sumReturn,Calmar ] = Sa (C(bigPoint:bigPoint+paramASectionLearn+paramADuration,:),spread, paramADuration, paramAVolThreshold, paramABuffer, paramASL, maxes, volAverages,1, paramASectionLearn);
                            if bestReturn<sumReturn
                                bestReturn=sumReturn;
                                bestCalmar=Calmar;
                                bestparamALength = paramALength;
                                bestparamAVolLength = paramAVolLength ;
                                bestparamADuration = paramADuration;
                                bestparamABuffer = paramABuffer;
                                bestparamAVolThreshold = paramAVolThreshold;
                                bestparamASL = paramASL;
                                disp(['> zysk: ', num2str(sumReturn)]);
                            end
                            
                            iterCounter = iterCounter + 1;
                            
                        end
                    end
                end
            end
        end
    end
    
    maxes=zeros(paramASectionTest+max(bestparamALength,bestparamAVolLength) + bestparamADuration, 1);
    volAverages=zeros(1, paramASectionTest+max(bestparamALength,bestparamAVolLength) + bestparamADuration);
    poczDanychTest = bigPoint+paramASectionLearn-max(bestparamALength,bestparamAVolLength);
    kon=bigPoint+paramASectionLearn + paramASectionTest+ bestparamADuration-1;
    ii=1;
    for i=poczDanychTest:kon
        maxes(ii) = max(C(i-min(i-1,bestparamALength):i,4));
        volAverages(ii) = mean(C(i-min(i-1,bestparamAVolLength):i,5))-C(i,5);
        ii=ii+1;
    end
    
    [ sumReturn,Calmar ] = Sa (C(poczDanychTest:kon,:),spread, bestparamADuration, bestparamAVolThreshold, bestparamABuffer, bestparamASL, maxes, volAverages,max(bestparamALength,bestparamAVolLength),paramASectionTest);
    sectionResult(startingSection+2) = sectionResult(startingSection+1) + sumReturn;
    
end
hFig = figure(1);
set(hFig, 'Position', [200 200 640 480])
plot(sectionResult(sectionResult ~= 0));
title(['Zysk skumulowany - strategia/rynek: ', mfilename]);
xlabel('Liczba œwiec');
ylabel('Zysk');
set(hFig, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig,'-dpng', '-r0',mfilename)
