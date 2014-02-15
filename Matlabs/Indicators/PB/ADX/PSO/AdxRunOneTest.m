kk=5

fid = fopen('EURUSD60.csv','r');
Data = textscan(fid, '%f %f %f %f %f %s', 'delimiter',',', 'CollectOutput',true);
C = Data{1};
Daty = Data{2}; 
fclose(fid);
spread=0.00016;

name = ['EURUSD4_bySumTest_' num2str(kk)];

incr=500; %dlugosc okresu uczacego
incrt=100; %dlugosc okresu testowego

paropt = [11; 3; 17; -0.0090 ; 0.0039 ; 12 ; 25];

if kk==1
    pocz=max([paropt(1), paropt(3)])+1;
    kon=incr;
else
    pocz=(kk-1)*incrt;
    kon=pocz+incr;
end
% kon=pocz+incr;
poczt=kon;
kont = kon+incrt;

[ zyskT, CalmarT, sumzT, LongShortT, lastPosState, lastOpenPriceTest] = ...
    Adx10fun( C, spread, poczt, kont, paropt(1), paropt(2), paropt(3), paropt(4), paropt(5), -1, 1.33419 );%, paropt(6), paropt(7));
fprintf ('%f\n', zyskT)


fileID = fopen([name '.txt'],'w');
fprintf(fileID, 'PoczU\t DataPocz\t KonU\t DataKon\t KonT\t DataKonT\t ZsykU\t CalmarU\t P1\t P2\t P3\t P4\t P5\t Long\t Short\t ZyskT\n');% fprintf(fileID, 'PoczU\t KonU\t KonT\t ZsykU\t CalmarU\t P1\t P2\t P3\t P4\t Long\t Short\t ZyskT\n');
fprintf(fileID, '%d\t %s\t %d\t %s\t %d\t %s\t %.4f\t %.4f\t %d\t %d\t %d\t %.4f\t %.4f\t %d\t %d\t %.4f\n\n', ...
    pocz, Daty{pocz}, kon, Daty{kon}, kont, Daty{kont}, 0, 0, ...
    paropt(1), paropt(2), paropt(3), paropt(4), paropt(5), 0, 0, zyskT );
fclose(fileID);
