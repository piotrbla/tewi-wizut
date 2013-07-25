function [] = zad7(C,pip,spread,file_name, ff1, ff2, VparamALength,VparamAVolLength,...
    VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL,paramASectionLearn, maxLose)
%(C) Antoni WiliÅ„ski 2013
%skrypt strategii S4 w projekcie TEWI
% Zadanie 6
% clc
% clear all
% close all
tStart=tic;
bigSumA={};
resultsA=[];
it_time =1;
frequenty = 10; % co ile minut ma siê wyœiwetliæ monit o czasie
%%%%%%%%%%%%%%%%%%%%%%
% TUTAJ GDY ROBIMY FUNKCJE  NIE USUWAJMY A KOMENTUJMY ;)
% Parametry podstawowe
% load ('bossapln60');
% pip = 0.01; % wielkosc pipsa na danym rynku
% spread = 10 * pip; % spread dla rynku
%%%%%%%%%%%%%%%%%%%%%%
display(['<< BADANIE: S4' lower(file_name(end)) ' ZAD7 '  upper(file_name(1:(end-2))) ' >>']);
fileID =fopen([file_name '.txt'],'w');
fprintf(fileID, 'BADANIE: S4%s ZAD7 %s',  lower(file_name(end)), upper(file_name(1:(end-2))));
fprintf(fileID, '\n\nDlugosc okresu uczacego: ');
fprintf(fileID, '%i\n',paramASectionLearn);
fprintf(fileID, 'Liczba dopuszczalnych strat\t Koncowy wynik\t Ilosc przesuniec okna\t');
fprintf(fileID, 'Srednia dlugosc trwania okresu testujacego\t Minimalna dlugosc trwania okresu testujacego \t');
fprintf(fileID, 'Maksymalna dlugosc trwania okresu testujacego\n');
% VparamALength = 5;%[5:10:30]; % liczba swiec dla obliczenia sredniej
% VparamAVolLength = 5;%[5:10:30]; % liczba sweic wstecz dla obliczenia sredniego wolumenu
% VparamADuration = 5;%[5:10:30]; % dlugosc trwania otwartej pozycji
% VparamAVolThreshold = 10;%[10:-10:-10]; % prog dla volumenu
% VparamABuffer =  -2*pip;%[-2*pip:-3*pip:-20*pip]; % wielkosc bufora
% VparamASL = 8*spread;%[8*spread:3*spread:20*spread]; % wartosc stop loss
paramASectionTest = 500; % dlugosc
for actLose=1:length(maxLose)
    
    %%%%%%%%%%%%%%%%%%%%%%
    % Parametry dla zadania 6
    % paramASectionLearn = 500; % 2 przebieg (dla tych najlepszych = wyn) wyn-75 : 25 : wyn+75; % dlugosc
    
    
    %%%%%%%%%%%%%%%%%%%%%%
    % file_name = 'bossapln_a';
    % Przygotowanie pliku do zapisu
    %formatSpec = 'bigPoint\tReturn\tCalmar\tparamALength\tparamAVolLength\tparamADuration\tparamAVolThreshold\tparamABuffer\tparamASL\n';
    %fprintf(fileID,formatSpec);
    
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
    bigPoint = 0;
    iterTotal = 1000000;
    iterCounter = 0;
    returnPoints = [];
    sumRa = [];
    % sectionResult = zeros(1,length(VparamASectionLearn));
    bigSumA{actLose}=[];
    bigSum = zeros(cSizes,1);
    
    sectionCounter = floor((candlesCount - paramASectionLearn) / paramASectionTest) - 2;
    bigPoint = 1;
    while 1
        %     bigPoint = (startingSection*paramASectionTest) + 1;%% poczatek naszego duzego okna uczacego
        %disp(['# Postep - przesuniecie okna na ', num2str(bigPoint), ' Czas: ', num2str(toc(tStart))]);
        bestReturn=-10000;
        sectionLearnStart = 1+2;
        
        for vi = 1:length(VparamALength)
            if frequenty*it_time<toc(tStart)/60
                it_time = it_time +1;
                display(['S4' lower(file_name(end)) ' ' upper(file_name(1:(end-2))) ' czas: ' num2str(toc(tStart))]);
            end
            
            
            paramALength = VparamALength(vi);
            
            maxes=zeros(bigPoint+paramASectionLearn,2);
            kon=(bigPoint+sectionLearnStart+paramASectionLearn)-1;
            ii=1;
            for i=sectionLearnStart:kon
                maxes(ii,1) = max(C(i-min(i-1,paramALength):i,4));
                ii=ii+1;
            end
            
            for vj = 1:length(VparamAVolLength)
                paramAVolLength = VparamAVolLength(vj);
                
                %disp(['# Postep: ', num2str(round(iterCounter/iterTotal*100)), '%   Czas: ', num2str(toc(tStart))]);
                
                volAverages=zeros(1, paramASectionLearn+bigPoint);
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
                                [ sumReturn,Calmar, sumRa ] = ff1 (C(1:bigPoint+paramASectionLearn+paramADuration,:),spread,paramALength, paramAVolLength, paramADuration, paramAVolThreshold, paramABuffer, paramASL, maxes, volAverages,1, paramASectionLearn);
                                if bestReturn<sumReturn
                                    bestReturn=sumReturn;
                                    bestCalmar=Calmar;
                                    bestparamALength = paramALength;
                                    bestparamAVolLength = paramAVolLength ;
                                    bestparamADuration = paramADuration;
                                    bestparamABuffer = paramABuffer;
                                    bestparamAVolThreshold = paramAVolThreshold;
                                    bestparamASL = paramASL;
                                    %disp(['> zysk: ', num2str(sumReturn)]);
                                end
                                
                                
                                
                            end
                        end
                    end
                end
            end
        end
        
        maxes=zeros(paramASectionTest+max(bestparamALength,bestparamAVolLength) + bestparamADuration, 2);
        volAverages=zeros(1, paramASectionTest+max(bestparamALength,bestparamAVolLength) + bestparamADuration);
        poczDanychTest = bigPoint+paramASectionLearn-max(bestparamALength,bestparamAVolLength);
        kon=min(bigPoint+paramASectionLearn + paramASectionTest+ bestparamADuration-1,candlesCount);
        ii=1;
        for i=poczDanychTest:kon
            maxes(ii,1) = max(C(i-min(i-1,bestparamALength):i,4));
            volAverages(ii) = mean(C(i-min(i-1,bestparamAVolLength):i,5))-C(i,5);
            ii=ii+1;
        end
        
        [ sumReturn,Calmar, sumRa, returnPoint, countLose ] = ff2 (C(poczDanychTest:kon,:),spread,bestparamALength, ...
            bestparamAVolLength, bestparamADuration, bestparamAVolThreshold, bestparamABuffer, bestparamASL, maxes, ...
            volAverages,max(bestparamALength,bestparamAVolLength),paramASectionTest,maxLose(actLose));
        returnPoints = [returnPoints; returnPoint];
        
        sumRa = sumRa + bigSum(max([1 poczDanychTest-1]),1);
        bigSum(poczDanychTest:kon,1) = sumRa;
        bigPoint = bigPoint + returnPoint;
        
        iterCounter = iterCounter + 1;
        if (bigPoint >= candlesCount - paramASectionLearn - paramASectionTest)
            break;
        end
        
    end
    bigSumA{actLose}=bigSum(bigSum~=0);
    resultsA(actLose) = bigSumA{actLose}(end);
    
    fprintf(fileID, '%i\t',maxLose(actLose));
    fprintf(fileID, '%0.4f\t',bigSumA{actLose}(end));
    fprintf(fileID, '%i\t',iterCounter);
    fprintf(fileID, '%i\t',round(mean(returnPoints)));
    fprintf(fileID, '%i\t',min(returnPoints));
    fprintf(fileID, '%i\n',max(returnPoints));
    
    display(['S4' lower(file_name(end)) ' ' upper(file_name(1:(end-2))) ' Postep ogolny: ' num2str(actLose*100/length(maxLose)) '%']);
end
% ZAPIS

nazwa=[file_name,'.','csv'];
[maxResult, index] = max(resultsA);
csvwrite(nazwa,bigSumA{index});

hFig = figure(1);
set(hFig, 'Position', [200 200 640 480])
plot(bigSumA{index});
title(['Zysk skumulowany - strategia: ', file_name, ' ',num2str(bigSumA{index}(end))]);
xlabel('Liczba Swiec');
ylabel('Zysk');
set(hFig, 'PaperPositionMode','auto')
print(hFig,'-dpng', '-r0',file_name)




fprintf(fileID, '\nNajlepszy wynik dla %i dopuszczalnych strat wynosi: %0.4f',maxLose(index),bigSumA{index}(end));





 
fclose(fileID);
