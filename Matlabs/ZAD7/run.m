% Ustawienia:
warning('off');
load ('bossapln60');
rynek = 'bossapln';

% Wykres rynku
hFig = figure(1);
set(hFig, 'Position', [200 200 640 480])
plot(C(:,4));
title('Trend rynku');
xlabel('Liczba Swiec');
ylabel('Zamkniecia');
set(hFig, 'PaperPositionMode','auto')
print(hFig,'-dpng', '-r0',rynek)

pip = 0.01; % wielkosc pipsa na danym rynku
spread = 10 * pip; % spread dla rynku

VparamALength = [5:10:30]; % liczba swiec dla obliczenia sredniej
VparamAVolLength = [5:10:30]; % liczba sweic wstecz dla obliczenia sredniego wolumenu
VparamADuration = [5:10:30]; % dlugosc trwania otwartej pozycji
VparamAVolThreshold = [10:-10:-10]; % prog dla volumenu
VparamABuffer =  [-2*pip:-3*pip:-20*pip]; % wielkosc bufora
VparamASL = [8*spread:3*spread:20*spread]; % wartosc stop loss

paramASectionLearn = 725; % Tutaj ustawiamy nasz wynik z poprzedniego zadania (znaleziona optymalna d³ugoœc okresu ucz¹cego)

maxLose = [5 6 7 8 9];%[5:2:15]; % Nie zmieniajcie tego parametru na ta chwile 

%% Wywolanie odpowiedniej wersji strategie przy pomocy uchwytow
file_name = 'bossapln_a';
zad7(C,pip,spread,file_name, @Sa, @Sa2, VparamALength,VparamAVolLength,...
    VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL,paramASectionLearn,maxLose);

file_name = 'bossapln_b';
zad7(C,pip,spread,file_name, @Sb, @Sb2, VparamALength,VparamAVolLength,...
    VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL,paramASectionLearn,maxLose);

% !!! Zmiana znaku bufora
VparamABuffer =  [2*pip:3*pip:20*pip]; % wielkosc bufora

file_name = 'bossapln_c';
zad7(C,pip,spread,file_name, @Sc, @Sc2, VparamALength,VparamAVolLength,...
    VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL,paramASectionLearn,maxLose);

file_name = 'bossapln_d';
zad7(C,pip,spread,file_name, @Sd, @Sd2, VparamALength,VparamAVolLength,...
    VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL,paramASectionLearn,maxLose);