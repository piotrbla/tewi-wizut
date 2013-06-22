%(C) Antoni Wiliński 2013
%skrypt strategii S4 w projekcie TEWI
% Zadanie 5 - testowanie długości zbiorów uczących
clc
clear all
close all
tStart=tic;

%%%%%%%%%%%%%%%%%%%%%%
% Ustawienia:
load ('bossapln60');
pip = 0.01; % wielkosc pipsa na danym rynku
spread = 10 * pip; % spread dla rynku

% Parametry podstawowe
VparamALength = [5:2:30]; % liczba swiec dla obliczenia sredniej
VparamAVolLength = [5:2:30]; % liczba sweic wstecz dla obliczenia sredniego wolumenu
VparamADuration = [5:2:30]; % dlugosc trwania otwartej pozycji
VparamAVolThreshold = [10:-5:-10]; % prog dla volumenu
VparamABuffer =  [-2*pip:-2*pip:-20*pip]; % wielkosc bufora
VparamASL = [8*spread:2*spread:20*spread]; % wartosc stop loss

% Parametry dla zadania 5
VparamASectionLearn = [100 500 1000 2000]; % dlugosc
paramASectionTest = 250; % dlugosc

%%%%%%%%%%%%%%%%%%%%%%
 
% Przygotowanie pliku do zapisu
fileID =fopen([mfilename '.txt'],'w');
formatSpec = 'bigPoint\tReturn\tCalmar\tparamALength\tparamAVolLength\tparamADuration\tparamAVolThreshold\tparamABuffer\tparamASL\n';
fprintf(fileID,formatSpec);  

bestReturn=-10000;
cSizes = size(C);
candlesCount = cSizes(1);
bestCalmar = 0;
bestMa = 0;
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

for vr = 1:length(VparamASectionLearn)
	paramASectionLearn = VparamASectionLearn(vr);
	vvo = floor((candlesCount - paramASectionLearn) / paramASectionTest) - 2;
	%disp(['# Postep: ', num2str(round(iterCounter/iterTotal*100)), '% - nowy okres uczacy Czas: ', num2str(toc(tStart))]);
	disp(['# Postep - nowy okres uczacy: ', num2str(paramASectionLearn)]);
for vo = 0:vvo
	
	bigPoint = (vo*paramASectionTest) + 1;%% poczatek naszego duzego okna uczacego
	disp(['# Postep - przesuniecie okna na ', num2str(bigPoint), ' swiece dla okresu ', num2str(paramASectionLearn), ' Czas: ', num2str(toc(tStart))]);
	bestReturn=-10000;
	sectionLearnStart = bigPoint+2;
	
	for vi = 1:length(VparamALength)
		paramALength = VparamALength(vi);
	
		maxes=zeros(1, paramASectionLearn);
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
							[ sumReturn,Calmar ] = Sa (C(bigPoint:bigPoint+paramASectionLearn+paramADuration,:),spread,paramALength, paramAVolLength, paramADuration, paramAVolThreshold, paramABuffer, paramASL, maxes, volAverages,1, paramASectionLearn);
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
    
    paramy=[bigPoint; bestReturn; bestCalmar; bestparamALength; bestparamAVolLength; ...
        bestparamADuration;  bestparamAVolThreshold; bestparamABuffer; bestparamASL];
    param_str = '%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\n';
    fprintf(fileID, param_str, paramy);
    
	maxes=zeros(1, paramASectionTest+max(bestparamALength,bestparamAVolLength) + bestparamADuration);
	volAverages=zeros(1, paramASectionTest+max(bestparamALength,bestparamAVolLength) + bestparamADuration);
	poczDanychTest = bigPoint+paramASectionLearn-max(bestparamALength,bestparamAVolLength);
	kon=bigPoint+paramASectionLearn + paramASectionTest+ bestparamADuration-1;
	ii=1;
	for i=poczDanychTest:kon
		maxes(ii) = max(C(i-min(i-1,bestparamALength):i,4));
		volAverages(ii) = mean(C(i-min(i-1,bestparamAVolLength):i,5))-C(i,5);
		ii=ii+1;
	end
	
	[ sumReturn,Calmar ] = Sa (C(poczDanychTest:kon,:),spread,bestparamALength, bestparamAVolLength, bestparamADuration, bestparamAVolThreshold, bestparamABuffer, bestparamASL, maxes, volAverages,max(bestparamALength,bestparamAVolLength),paramASectionTest);
	sectionResult(vr) = sectionResult(vr) + sumReturn;

end
end
sectionResult;
nazwa=[mfilename,'.','csv'];
csvwrite(nazwa,sectionResult);
fprintf(fileID, '\n\nWynik koncowy\n');
for i=1:length(sectionResult)
	fprintf(fileID, '%i\t%2.5\n');
end
fclose(fileID);