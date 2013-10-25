%(C) Micha³ Zab³ocki 2013
%skrypt strategii S4 w projekcie TEWI
%S4L - sygna³ kupna - przeciêcia linii, %K ponad %D

%Dane:
tStart=tic;

true_positive = 0;
false_positive = 0;
false_negative = 0;
true_negative = 0;

cSizes = size(C);
candlesCount = cSizes(1);
bestiL = 0;
bestiS = 0;
HL = C(:,2) - C(:,3);

kon=candlesCount-1;
MI = zeros(candlesCount,1);
HLaverage = ema(HL,9);
EMA2 = HLaverage(9:end) ./ ema(HLaverage(9:end),9);
for i = 41:kon-16
    MI(i) = sum(EMA2(i-24:i));
end
Caverages = ema(C(:,4),9);

sumR=zeros(1,candlesCount);
R=zeros(1,candlesCount);
pocz=50;
iL=0; %liczba otwieranych pozycji kupna
iS=0; %liczba otwieranych pozycji sprzedarzy
lastCandle = kon-16;
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
LastPos = 0;
pic1 = false;

for i=pocz:lastCandle
    
    if pic1 == false && MI(i) > 27
        pic1 = true;
    end
    if pic1 == true && MI(i) < 26.5
        if C(i,4) > Caverages(i) % warunek kupna
            R(i)= -C(i+1,4)-LastPos-spread; % zamkniêcie S
            LastPos = C(i+1,1); % otwarcie L
            iL=iL+1;
        elseif C(i,4) < Caverages(i) % warunek sprzeda¿y
            R(i)=C(i+1,4)-LastPos-spread; % zamkniêcie L
            LastPos = C(i+1,1); % otwarcie S
            iS=iS+1;
        end
        pic1 = false;
    end
    sumR(i)= sum(R(pocz:i));  %krzywa narastania kapita³u
    
    if sumR(i)>recordReturn
        recordReturn=sumR(i);
    end
    
    if sumR(i)-recordReturn<recordDrawdown
        recordDrawdown=sumR(i)-recordReturn;  %obsuniecie maksymalne
    end
end

%wyniki koñcowe
sumReturn=sumR(lastCandle);
Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara
disp(['zysk: ', num2str(sumReturn), ...
    ' Calmar: ', num2str(Calmar) ...
    ]);
disp(['la = ', num2str(iL+iS)]); %liczba otwartych pozycji


% ZAPIS

fileID =fopen(['MI_' file_name '_S4LS.txt'],'w');
fprintf(fileID,'OKRES WALIDUJ¥CY\n');
fprintf(fileID,['Zysk skumulowany:     ', num2str(sumR(lastCandle)), '\n']);
fprintf(fileID,['Calmar:     ', num2str(Calmar), '\n']);
fprintf(fileID,['Liczba otwartych pozycji d³ugich:     ', num2str(iL), '\n']);
fprintf(fileID,['Liczba otwartych pozycji krótkich:     ', num2str(iS), '\n']);
fclose(fileID);

hFig = figure(1);
set(hFig, 'Position', [200 200 640 480]);
sumR = sumR(sumR~=0);
plot(sumR);
title(['Zysk skumulowany: ', num2str(sumR(end)), ' - ', file_name]);
xlabel('numer œwiecy');
ylabel('zysk');
set(hFig, 'PaperPositionMode','auto')
print(hFig,'-dpng', '-r0',['MI_', file_name, '_S4LS'])


disp(['tElapsed ', num2str(toc(tStart))]);