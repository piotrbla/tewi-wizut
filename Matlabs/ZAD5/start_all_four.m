

% Ustawienia:
EURJPY;
pip = 0.01; % wielkosc pipsa na danym rynku
spread = 3 * pip; % spread dla rynku

VparamALength = [5:4:30]; % liczba swiec dla obliczenia sredniej
VparamAVolLength = [5:4:30]; % liczba sweic wstecz dla obliczenia sredniego wolumenu
VparamADuration = [5:4:30]; % dlugosc trwania otwartej pozycji
VparamAVolThreshold = [10:-10:-10]; % prog dla volumenu
VparamABuffer =  [-2*pip:-3*pip:-20*pip]; % wielkosc bufora
VparamASL = [8*spread:3*spread:20*spread]; % wartosc stop loss

%% Wywołanie odpowiedniej wersji strategie przy pomocy uchwytów
file_name = 'bossapln_a';
zad5(C,pip,spread,file_name, @Sa,VparamALength,VparamAVolLength,VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL);
file_name = 'bossapln_b';
zad5(C,pip,spread,file_name, @Sb,VparamALength,VparamAVolLength,VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL);
% !!! Zmiana znaku bufora
VparamABuffer =  [2*pip:3*pip:20*pip]; % wielkosc bufora
file_name = 'bossapln_c';
zad5(C,pip,spread,file_name, @Sc,VparamALength,VparamAVolLength,VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL);
file_name = 'bossapln_d';
zad5(C,pip,spread,file_name, @Sd,VparamALength,VparamAVolLength,VparamADuration,VparamAVolThreshold,VparamABuffer,VparamASL);