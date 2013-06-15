%(C) Antoni Wiliński 2013
%skrypt strategii S4 w projekcie TEWI
% Zadanie 4 - testowanie długości zbiorów uczących i testujących
% Wersja by WNowicki, ABera, KBuda
clc
clear all
close all
tStart=tic;

%%%%%%%%%%%%%%%%%%%%%%
% Ustawienia:
load ('gbpusd60');
pip = 0.0001; % wielkosc pipsa na danym rynku
spread = 2.8 * pip; % spread dla rynku

% Parametry podstawowe
VparamALength = [5:4:30]; % liczba swiec dla obliczenia sredniej
VparamAVolLength = [5:4:30]; % liczba sweic wstecz dla obliczenia sredniego wolumenu
VparamADuration = [5:2:30]; % dlugosc trwania otwartej pozycji
VparamAVolThreshold = 0;%[10:-10:-10]; % prog dla volumenu
VparamABuffer =  [-2*pip:-4*pip:-10*pip]; % wielkosc bufora
VparamASL = 8*spread;%[8*spread:3*spread:20*spread]; % wartosc stop loss

% Parametry dla zadania 4
VparamASectionLearn = [100 500 1000 2000]; % dlugosc
VparamASectionTest = [50 100 200 400]; % dlugosc
 
%%%%%%%%%%%%%%%%%%%%%%

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
vvo = floor(candlesCount / 500) - 3;
iterTotal = length(VparamALength)*length(VparamAVolLength)*length(VparamADuration)*length(VparamAVolThreshold)*length(VparamABuffer)*length(VparamASL)*(vvo+1);
iterCounter = 0;
disp(['# Rozmiar badania: ', num2str(iterTotal), ' iteracji.']);

% ZAD4
sectionResult = zeros(1,length(VparamASectionTest));

for vo = 0:vvo
	paramASectionLearn = 1000;
	bigPoint = (vo*500) + 1;%% poczatek naszego duzego okna (1000bar) uczacego

	bestReturn=-10000;
	sectionLearnStart = bigPoint+2;
	disp(['# Postep: ', num2str(round(iterCounter/iterTotal*100)), '% - nowy przedzial czasowy']);
	for vi = 1:length(VparamALength)
		paramALength = VparamALength(vi);
	
		maxes=zeros(1, paramASectionLearn);
		kon=(sectionLearnStart+paramASectionLearn)-1;
		for i=2:kon
			maxes(i) = max(C(i-min(i-1,paramALength):i,4));
		end
	
		for vj = 1:length(VparamAVolLength)
			paramAVolLength = VparamAVolLength(vj);
		
		disp(['# Postep: ', num2str(round(iterCounter/iterTotal*100)), '%   Czas: ', num2str(toc(tStart))]);

			volAverages=zeros(1, paramASectionLearn);
			for i=2:kon
				volAverages(i) = mean(C(i-min(i-1,paramAVolLength):i,5))-C(i,5);
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
								%bestCalmar=Calmar;
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
	maxes=zeros(1, max(VparamASectionTest)+max(bestparamALength,bestparamAVolLength) + bestparamADuration);
	poczDanychTest = bigPoint+paramASectionLearn-max(bestparamALength,bestparamAVolLength);
	kon=bigPoint+paramASectionLearn + max(VparamASectionTest)+ bestparamADuration-1;
	for i=poczDanychTest:kon
		maxes(i) = max(C(i-min(i-1,bestparamALength):i,4));
	end
	volAverages=zeros(1, max(VparamASectionTest)+max(bestparamALength,bestparamAVolLength) + bestparamADuration);
	for i=poczDanychTest:kon
		volAverages(i) = mean(C(i-min(i-1,bestparamAVolLength):i,5))-C(i,5);
	end
	
	for vp = 1:length(VparamASectionTest)
		paramASectionTest = VparamASectionTest(vp);
		[ sumReturn,Calmar ] = Sa (C(poczDanychTest:kon,:),spread,bestparamALength, bestparamAVolLength, bestparamADuration, bestparamAVolThreshold, bestparamABuffer, bestparamASL, maxes, volAverages,max(bestparamALength,bestparamAVolLength),paramASectionTest);
		sectionResult(vp) = sectionResult(vp) + sumReturn;
	end
end
sectionResult
nazwa=[mfilename,'.','csv'];
csvwrite(nazwa,sectionResult);