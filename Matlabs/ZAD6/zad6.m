function [] = zad5(C,pip,spread,file_name, ff1, ff2, VparamALength,VparamAVolLength,...
    VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL,paramASectionLearn, maxLose)
%(C) Antoni WiliÅ„ski 2013
%skrypt strategii S4 w projekcie TEWI
% Zadanie 6 
% clc
% clear all
% close all
tStart=tic;

%%%%%%%%%%%%%%%%%%%%%%
% TUTAJ GDY ROBIMY FUNKCJE  NIE USUWAJMY A KOMENTUJMY ;)
% Parametry podstawowe
% load ('bossapln60');
% pip = 0.01; % wielkosc pipsa na danym rynku
% spread = 10 * pip; % spread dla rynku
%%%%%%%%%%%%%%%%%%%%%%

% VparamALength = 5;%[5:10:30]; % liczba swiec dla obliczenia sredniej
% VparamAVolLength = 5;%[5:10:30]; % liczba sweic wstecz dla obliczenia sredniego wolumenu
% VparamADuration = 5;%[5:10:30]; % dlugosc trwania otwartej pozycji
% VparamAVolThreshold = 10;%[10:-10:-10]; % prog dla volumenu
% VparamABuffer =  -2*pip;%[-2*pip:-3*pip:-20*pip]; % wielkosc bufora
% VparamASL = 8*spread;%[8*spread:3*spread:20*spread]; % wartosc stop loss

%%%%%%%%%%%%%%%%%%%%%%
% Parametry dla zadania 6
% paramASectionLearn = 500; % 2 przebieg (dla tych najlepszych = wyn) wyn-75 : 25 : wyn+75; % dlugosc
paramASectionTest = 500; % dlugosc

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

% sectionResult = zeros(1,length(VparamASectionLearn));
bigSum = zeros(cSizes,1);

sectionCounter = floor((candlesCount - paramASectionLearn) / paramASectionTest) - 2;
bigPoint = 1;
while 1
%     bigPoint = (startingSection*paramASectionTest) + 1;%% poczatek naszego duzego okna uczacego
    disp(['# Postep - przesuniecie okna na ', num2str(bigPoint), ' Czas: ', num2str(toc(tStart))]);
    bestReturn=-10000;
    sectionLearnStart = bigPoint+2;

    for vi = 1:length(VparamALength)
        paramALength = VparamALength(vi);

        maxes=zeros(paramASectionLearn,2);
        kon=(sectionLearnStart+paramASectionLearn)-1;
        ii=1;
        for i=sectionLearnStart:kon
            maxes(ii,1) = max(C(i-min(i-1,paramALength):i,4));
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
                            [ sumReturn,Calmar, sumRa ] = ff1 (C(bigPoint:bigPoint+paramASectionLearn+paramADuration,:),spread,paramALength, paramAVolLength, paramADuration, paramAVolThreshold, paramABuffer, paramASL, maxes, volAverages,1, paramASectionLearn);
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
        volAverages,max(bestparamALength,bestparamAVolLength),paramASectionTest,maxLose);
    returnPoints = [returnPoints; returnPoint]; 
    
    sumRa = sumRa + bigSum(max([1 poczDanychTest-1]),1);
    bigSum(poczDanychTest:kon,1) = sumRa;
    bigPoint = bigPoint + returnPoint;
    
    iterCounter = iterCounter + 1;
    if (bigPoint >= candlesCount - paramASectionLearn - paramASectionTest)
        break;
    end

end

% ZAPIS

nazwa=[file_name,'.','csv'];
bigSum = bigSum(bigSum~=0);
csvwrite(nazwa,bigSum);

hFig = figure(1);
set(hFig, 'Position', [200 200 640 480])
plot(bigSum);
title(['Zysk skumulowany - strategia: ', file_name, ' ',num2str(sumRa(end))]);
xlabel('Liczba Swiec');
ylabel('Zysk');
set(hFig, 'PaperPositionMode','auto')   
print(hFig,'-dpng', '-r0',file_name)

fileID =fopen([file_name '.txt'],'w');

fprintf(fileID, 'Koñcowy wynik: ');
fprintf(fileID, '%0.4f\n',bigSum(end));
fprintf(fileID, 'Iloœæ przesuniêæ okna - uruchomieñ strategii: ');
fprintf(fileID, '%i\n',iterCounter);
fprintf(fileID, 'Œrednia d³ugoœæ trwania okresu testuj¹cego: ');
fprintf(fileID, '%i\n',round(mean(returnPoints)));
fprintf(fileID, 'Minimalna d³ugoœæ trwania okresu testuj¹cego: ');
fprintf(fileID, '%i\n',min(returnPoints));
fprintf(fileID, 'Maksymalna d³ugoœæ trwania okresu testuj¹cego: ');
fprintf(fileID, '%i\n',max(returnPoints));

fclose(fileID);
