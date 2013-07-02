function [] = zad5(C,pip,spread,file_name, ff,VparamALength,VparamAVolLength,VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL)
%(C) Antoni Wiliński 2013
%skrypt strategii S4 w projekcie TEWI
% Zadanie 5 - testowanie długości zbiorów uczących
tStart=tic;

%%%%%%%%%%%%%%%%%%%%%%



% Parametry podstawowe


% Parametry dla zadania 5
VparamASectionLearn = 600:100:1500; % 2 przebieg (dla tych najlepszych = wyn) wyn-75 : 25 : wyn+75; % dlugosc
%VparamASectionLearn = 1500;%600:100:1500; % 2 przebieg (dla tych najlepszych = wyn) wyn-75 : 25 : wyn+75; % dlugosc
paramASectionTest = 250; % dlugosc

%%%%%%%%%%%%%%%%%%%%%%

% Przygotowanie pliku do zapisu
fileID =fopen([file_name '.txt'],'w');
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
iterTotal = length(VparamALength)*length(VparamAVolLength)*length(VparamADuration)*length(VparamAVolThreshold)*length(VparamABuffer)*length(VparamASL)*length(VparamASectionLearn);
iterCounter = 0;
%disp(['# Rozmiar badania: ', num2str(iterTotal), ' iteracji.']);

% ZAD4
sectionResult = zeros(1,length(VparamASectionLearn));
bigSum = zeros(cSizes,length(VparamASectionLearn));
for vr = 1:length(VparamASectionLearn)
   a=tic;
    paramASectionLearn = VparamASectionLearn(vr);
    sectionCounter = floor((candlesCount - paramASectionLearn) / paramASectionTest) - 2;
    %disp(['# Postep: ', num2str(round(iterCounter/iterTotal*100)), '% - nowy okres uczacy Czas: ', num2str(toc(tStart))]);
    disp(['# Postep - nowy okres uczacy: ', num2str(paramASectionLearn)]);
    for startingSection = 0:sectionCounter
        %for startingSection = 0:sectionCounter
        %	disp(['# startingSection', num2str(startingSection), ...
        %           '  sectionCounter:', num2str(sectionCounter), '  vr:', num2str(vr)]);
        bigPoint = (startingSection*paramASectionTest) + 1;%% poczatek naszego duzego okna uczacego
        disp(['# Postep - przesuniecie okna na ', num2str(bigPoint), ' swiece dla okresu ', num2str(paramASectionLearn), ' Czas: ', num2str(toc(tStart))]);
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
                                [ sumReturn,Calmar, sumRa ] = ff (C(bigPoint:bigPoint+paramASectionLearn+paramADuration,:),spread,paramALength, paramAVolLength, paramADuration, paramAVolThreshold, paramABuffer, paramASL, maxes, volAverages,1, paramASectionLearn);
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
        
        %paramy=[bigPoint; bestReturn; bestCalmar; bestparamALength; bestparamAVolLength; ...
        %    bestparamADuration;  bestparamAVolThreshold; bestparamABuffer; bestparamASL];
        %param_str = '%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\n';
        %fprintf(fileID, param_str, paramy);
        
        maxes=zeros(paramASectionTest+max(bestparamALength,bestparamAVolLength) + bestparamADuration, 2);
        volAverages=zeros(1, paramASectionTest+max(bestparamALength,bestparamAVolLength) + bestparamADuration);
        poczDanychTest = bigPoint+paramASectionLearn-max(bestparamALength,bestparamAVolLength);
        kon=bigPoint+paramASectionLearn + paramASectionTest+ bestparamADuration-1;
        ii=1;
        for i=poczDanychTest:kon
            maxes(ii,1) = max(C(i-min(i-1,bestparamALength):i,4));
            volAverages(ii) = mean(C(i-min(i-1,bestparamAVolLength):i,5))-C(i,5);
            ii=ii+1;
        end
        
        [ sumReturn,Calmar, sumRa ] = ff (C(poczDanychTest:kon,:),spread,bestparamALength, bestparamAVolLength, bestparamADuration, bestparamAVolThreshold, bestparamABuffer, bestparamASL, maxes, volAverages,max(bestparamALength,bestparamAVolLength),paramASectionTest);
        sectionResult(vr) = sectionResult(vr) + sumReturn;
        sumRa = sumRa + bigSum(max([1 poczDanychTest-1]),vr);
        bigSum(poczDanychTest:kon,vr) = sumRa;
        
    end
    toc(a)
end
sectionResult;
nazwa=[file_name,'.','csv'];
%csvwrite(nazwa,sectionResult);
fprintf(fileID, '\n\nWynik koncowy\n');
for i=1:length(sectionResult)
    fprintf(fileID, '%i\t%2.5\n',sectionResult(i));
    fprintf(fileID, '%i\t%2.5\n',VparamASectionLearn(i));
    fprintf(fileID, '\n');
end
[temp bigMax] = max(sectionResult);
sumRa = bigSum(:,bigMax);
sumRa = sumRa(sumRa~=0);

fprintf(fileID, '\n\nNajlepszy wynik:\n');
fprintf(fileID, '\n');
fprintf(fileID, '%i\t%2.5\n',sumRa(end));
fclose(fileID);


%% DRUGI OBIEG

file_name = [file_name, '2'];
fileID =fopen([file_name '.txt'],'w');
[temp bigMax] = max(sectionResult);
display(['VparamASectionLearn = ' num2str(VparamASectionLearn(bigMax))]);
VparamASectionLearn = VparamASectionLearn(bigMax)-75:25:VparamASectionLearn(bigMax)+75;% co 25
sectionResult = zeros(1,length(VparamASectionLearn));
bigSum = zeros(cSizes,length(VparamASectionLearn));
for vr = 1:length(VparamASectionLearn)
    paramASectionLearn = VparamASectionLearn(vr);
    sectionCounter = floor((candlesCount - paramASectionLearn) / paramASectionTest) - 2;
    %disp(['# Postep: ', num2str(round(iterCounter/iterTotal*100)), '% - nowy okres uczacy Czas: ', num2str(toc(tStart))]);
    disp(['# Postep - nowy okres uczacy: ', num2str(paramASectionLearn)]);
    for startingSection = 0:sectionCounter
        %for startingSection = 0:sectionCounter
        %	disp(['# startingSection', num2str(startingSection), ...
        %           '  sectionCounter:', num2str(sectionCounter), '  vr:', num2str(vr)]);
        bigPoint = (startingSection*paramASectionTest) + 1;%% poczatek naszego duzego okna uczacego
        disp(['# Postep - przesuniecie okna na ', num2str(bigPoint), ' swiece dla okresu ', num2str(paramASectionLearn), ' Czas: ', num2str(toc(tStart))]);
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
                                [ sumReturn,Calmar, sumRa ] = ff (C(bigPoint:bigPoint+paramASectionLearn+paramADuration,:),spread,paramALength, paramAVolLength, paramADuration, paramAVolThreshold, paramABuffer, paramASL, maxes, volAverages,1, paramASectionLearn);
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
        
        %paramy=[bigPoint; bestReturn; bestCalmar; bestparamALength; bestparamAVolLength; ...
        %    bestparamADuration;  bestparamAVolThreshold; bestparamABuffer; bestparamASL];
        %param_str = '%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\n';
        %fprintf(fileID, param_str, paramy);
        
        maxes=zeros(paramASectionTest+max(bestparamALength,bestparamAVolLength) + bestparamADuration, 2);
        volAverages=zeros(1, paramASectionTest+max(bestparamALength,bestparamAVolLength) + bestparamADuration);
        poczDanychTest = bigPoint+paramASectionLearn-max(bestparamALength,bestparamAVolLength);
        kon=bigPoint+paramASectionLearn + paramASectionTest+ bestparamADuration-1;
        ii=1;
        for i=poczDanychTest:kon
            maxes(ii,1) = max(C(i-min(i-1,bestparamALength):i,4));
            volAverages(ii) = mean(C(i-min(i-1,bestparamAVolLength):i,5))-C(i,5);
            ii=ii+1;
        end
        
        [ sumReturn,Calmar, sumRa ] = ff (C(poczDanychTest:kon,:),spread,bestparamALength, bestparamAVolLength, bestparamADuration, bestparamAVolThreshold, bestparamABuffer, bestparamASL, maxes, volAverages,max(bestparamALength,bestparamAVolLength),paramASectionTest);
        sectionResult(vr) = sectionResult(vr) + sumReturn;
        sumRa = sumRa + bigSum(max([1 poczDanychTest-1]),vr);
        bigSum(poczDanychTest:kon,vr) = sumRa;
        
    end
end
sectionResult;
nazwa=[file_name,'.','csv'];
%csvwrite(nazwa,sectionResult);
fprintf(fileID, '\n\nWynik koncowy\n');
for i=1:length(sectionResult)
    fprintf(fileID, '%i\t%2.5\n',sectionResult(i));
    fprintf(fileID, '%i\t%2.5\n',VparamASectionLearn(i));
    fprintf(fileID, '\n');
end



%% CA�KOWITE WYNIKI
[temp bigMax] = max(sectionResult);
display(['VparamASectionLearn = ' num2str(VparamASectionLearn(bigMax))]);

sumRa = bigSum(:,bigMax);
sumRa = sumRa(sumRa~=0);
hFig = figure(1);
set(hFig, 'Position', [200 200 640 480])
plot(sumRa);
title(['Zysk skumulowany - strategia: ', file_name, ' ',num2str(sumRa(end))]);
xlabel('Liczba úwiec');
ylabel('Zysk');
set(hFig, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig,'-dpng', '-r0',file_name)
display(['Najlepszy zysk skumulowany = ' num2str(sumRa(end))]);

fprintf(fileID, '\n\nNajlepszy wynik:\n');
fprintf(fileID, '\n');
fprintf(fileID, '%i\t%2.5\n',sumRa(end));
fclose(fileID);

%% ZAPIS NAJLEPSZEGO ZYSKU SKUMULOWANEGO (bigSum)
csvwrite(nazwa,sumRa);