function [ testReturn, lastPosState, lastPosLearnState, lastOpenPrice, lastOpenPriceTest ] = startAdx( C, Daty, kk, firstPosState, firstPosLearnState, lastOpenPrice, lastOpenPriceTest)

% eurusd_1h_220409;
% fid = fopen('EURUSD60.csv','r');
% Data = textscan(fid, '%f %f %f %f %f %s', 'delimiter',',', 'CollectOutput',true);
% C = Data{1};
% Daty = Data{2};
% fclose(fid);

spread=0.00016;


incr=500; %dlugosc okresu uczacego
incrt=100; %dlugosc okresu testowego

% zakresy parametr�w
P1 = 3:1:80;
P2 = 1; % 1 oznacza �e p�tla przeszukuj�ca b�dzie zaczynac od 1 (1:p1/2)
P3 = 4:50;
P4  =-0.0005:-0.0005:-0.0150;

Params = [3 80; 1 40; 4 50; -0.0150 -0.0015; spread*7 spread*60 ; 3 80 ; -30 30];

if kk==1
    pocz=max([P1(end), P3(end)])+1;
    kon=incr;
else
    pocz=(kk-1)*incrt;
    kon=pocz+incr;
end
% kon=pocz+incr;
poczt=kon;
kont = kon+incrt;

% uczenie
opcje = PSODefaultOptions(spread, Params);
timeout = 1;
% definicje funkcji
if(timeout)
    opcje.best_position_timeout = 100;
end
% PSO
[ swarm, iterNum, best_l_op,best_zysk, best_calmar, lastPosLearnState, lastOpenPrice] = PSO(opcje,C,pocz,kon,spread, firstPosLearnState, lastOpenPrice);
bestParticles = getBestQuarterParticles(swarm);
ldopt = best_l_op;
zyskU = best_zysk;
calmarU = best_calmar;

%testowanie
for iParticle = 1:length(bestParticles)
    paropt = bestParticles(iParticle).best_position;

    [ zyskT, CalmarT, sumzT, LongShortT, lastPosState, lastOpenPriceTest] = Adx10fun( C, spread, poczt, kont, paropt(1), paropt(2), paropt(3), paropt(4), paropt(5), firstPosState, lastOpenPriceTest );%, paropt(6), paropt(7));
    
    name = ['EURUSD4_bySum_' num2str(kk) '_particle_' num2str(iParticle)];
    fileID = fopen([name '.txt'], 'a');
    %fprintf(fileID, 'PoczU\t DataPocz\t KonU\t DataKon\t KonT\t DataKonT\t ZsykU\t CalmarU\t P1\t P2\t P3\t P4\t P5\t Long\t Short\t ZyskT\n');% fprintf(fileID, 'PoczU\t KonU\t KonT\t ZsykU\t CalmarU\t P1\t P2\t P3\t P4\t Long\t Short\t ZyskT\n');
    fprintf(fileID, '%d;%s;%d;%s;%d;%s;%.4f;%.4f;%d;%d;%d;%.4f;%.4f;%d;%d;%.4f\n\n', ...
        pocz, Daty{pocz}, kon, Daty{kon}, kont, Daty{kont}, zyskU, calmarU, ...
        paropt(1), paropt(2), paropt(3), paropt(4), paropt(5), ldopt(1), ldopt(2), zyskT );
    fclose(fileID);
end
testReturn = zyskT;
end

function [ particles ] = getBestQuarterParticles( swarm )
allParticles = nestedSortStruct(swarm.particles, 'best_position_value', 1);
particles = allParticles(1:20);
end

