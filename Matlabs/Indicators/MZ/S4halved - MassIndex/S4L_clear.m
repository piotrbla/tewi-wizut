%(C) Micha³ Zab³ocki 2013
%skrypt strategii S4 w projekcie TEWI
%S4L - sygna³ kupna - przeciêcia linii, %K ponad %D

%Dane:
tStart=tic;

cSizes = size(C);
candlesCount = cSizes(1);

HL = C(:,2) - C(:,3);

kon=candlesCount-1;
MI = zeros(candlesCount,1);
HLaverage = ema(HL,9);
EMA2 = HLaverage(9:end) ./ ema(HLaverage(9:end),9);
for i = 41:kon-16
    MI(i) = sum(EMA2(i-24:i));
end
Caverages = ema(C(:,4),9);

sumRa=zeros(1,candlesCount);
Ra=zeros(1,candlesCount);
pocz=50;
la=0; %liczba otwieranych pozycji
lastCandle = kon-16;
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
pic1 = false;

for i=pocz:lastCandle
    
    if pic1 == false && MI(i) > 27
        pic1 = true;
    end
    if pic1 == true && MI(i) < 26.5
        if C(i,4) > Caverages(i)
            Ra(i)=C(i+2,4)-C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                        
            la=la+1;
        end
        pic1 = false;
    end
    sumRa(i)=sumRa(i-1) + Ra(i);  %krzywa narastania kapita³u
    
    if sumRa(i)>recordReturn
        recordReturn=sumRa(i);
    end
    
    if sumRa(i)-recordReturn<recordDrawdown
        recordDrawdown=sumRa(i)-recordReturn;  %obsuniecie maksymalne
    end
end

%wyniki koñcowe
sumReturn=sumRa(lastCandle);
Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara
disp(['zysk: ', num2str(sumReturn), ...
    ' Calmar: ', num2str(Calmar) ...
    ]);
disp(['la = ', num2str(la)]); %liczba otwartych pozycji


% ZAPIS

fileID =fopen([file_name '_S4L.txt'],'w');
fprintf(fileID,['S4L', '\n']);
fprintf(fileID,['sumReturn = ', num2str(sumRa(lastCandle)), '\n']);
fprintf(fileID,['Calmar = ', num2str(Calmar), '\n']);
fprintf(fileID,['la = ', num2str(la), '\n']);
fclose(fileID);

hFig = figure(1);
set(hFig, 'Position', [200 200 640 480]);
sumRa = sumRa(sumRa~=0);
plot(sumRa);
title(['Zysk skumulowany - strategia: ', file_name, '_L']);
xlabel('Liczba Swiec');
ylabel('Zysk');
set(hFig, 'PaperPositionMode','auto')
print(hFig,'-dpng', '-r0',[file_name, '-test_S4L'])


disp(['tElapsed ', num2str(toc(tStart))]);