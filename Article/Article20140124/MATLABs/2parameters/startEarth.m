clc
close
clear

global name;

fid = fopen('EURUSD60.csv','r');
Data = textscan(fid, '%f %f %f %f %f %s', 'delimiter',',', 'CollectOutput',true);
C = Data{1}; % Dane
Daty = Data{2}; % Daty
fclose(fid);

name = 'EURUSDbySum';
m=size(C);


% spread = 0.0001*2.8;

spread=0.0002;
p1=20;%10:80;%18; %liczba króków do badania trendu (d³ugoœæ robaka) - parametr strategii
p2=1;%1:40;%3; %parametr wp³ywajacy na neutralnoœæ "dzdzownicy", im wiekszy tym czêœciej robak nie podejmuje decyzji
pocz = 1;
kon = m(1)-1;%m(1)-30000;
sumBest = -Inf;
calBest = -Inf;
p1Best = [];
p2Best = [];
longBest = [];
shortBest = [];
liczbaIt = length(p1)*length(p2);
licznik = 1;

for pOne = 1:length(p1)
    for pTwo = 1:length(p2)
        fprintf('%.2f procent\n',licznik*100/liczbaIt);
        [ sumReturn, Calmar, l_long, l_short ] = earthwormFun( C, spread, pocz, kon, p1(pOne), p2(pTwo), Daty,1 );
        if sumReturn>sumBest && l_long+l_short > 20
            sumBest = sumReturn
            calBest = Calmar;
            p1Best = p1(pOne);
            p2Best = p2(pTwo);
            longBest = l_long;
            shortBest = l_short;
        end
        licznik = licznik+1;
    end
end

fileID = fopen(['wyniki' name '.txt'],'w');
fprintf(fileID,'Suma skumulowana: %.4f\n Calmar: %.4f\n p1: %d, p2: %d\n long: %d, short: %d', ...
    sumBest, calBest, p1Best, p2Best, longBest,shortBest);
fclose(fileID);