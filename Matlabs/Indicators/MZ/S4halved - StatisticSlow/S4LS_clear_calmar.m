%(C) Micha³ Zab³ocki 2013
%skrypt strategii S4 w projekcie TEWI
%S4L - sygna³ kupna - przeciêcia linii, %K ponad %D

%parametry:
% paramMALength - MA length

%Dane:
tStart=tic;
verificationC=C(5400:end,:); C=C(1:5399,:);

cSizes = size(C);
candlesCount = cSizes(1);
bestCalmar = -1000;
bestMa = 0;
bestReturn = -1000;
bestiL = 0;
bestiS = 0;
lastCandle = 0 ;

for paramMALength=1000:-20:2 %MA length
    disp(['# Postep: ', 'paramMALength ', num2str(paramMALength), '   Czas: ', num2str(toc(tStart))]);
    maxes=zeros(candlesCount,1);
    mins=zeros(candlesCount,1);
    K=zeros(candlesCount,1);
    D=zeros(candlesCount,1);
    kon=candlesCount-1;
    for i=4:kon
        maxes(i) = max(C(i-min(i-1,paramMALength):i-1,2));
        mins(i) = min(C(i-min(i-1,paramMALength):i-1,3));
        K(i) = 100 * (sum(C(i-min(i-1,3):i-1,4)-mins(i-min(i-1,2):i)) / sum(maxes(i-min(i-1,2):i)-mins(i-min(i-1,2):i)));
        D(i) = sum(K(i-min(i-1,2):i)) / min(i-1,3);
    end
    
    sumR=zeros(1,candlesCount);
    R=zeros(1,candlesCount);
    pocz=max(paramMALength, 10)+3;
    iL=0; %liczba otwieranych pozycji kupna
    iS=0; %liczba otwieranych pozycji sprzedarzy
    lastCandle = kon-paramMALength;
    recordReturn=0;  %rekord zysku
    recordDrawdown=0;  %rekord obsuniecia
    LastPos = 0;
    for i=pocz:lastCandle
        
        if K(i-1) < D(i-1) && K(i) >= D(i)
            R(i)= - C(i+1,4)+LastPos-spread; % zamkniêcie S
            LastPos = C(i+1,1); % otwarcie L
            iL=iL+1;
        elseif K(i-1) > D(i-1) && K(i) <= D(i)
            R(i)=C(i+1,4)-LastPos-spread; % zamkniêcie L
            LastPos = C(i+1,1); % otwarcie S
            iS=iS+1;
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
    if bestCalmar<Calmar
        bestReturn=sumReturn;
        bestSumRa = sumR;
        disp(['zysk koñcowy: ', num2str(bestReturn), ...
            ' paramMALength: ', num2str(paramMALength), ...
            ' Calmar: ', num2str(Calmar) ...
            ]);
        bestCalmar=Calmar;
        bestMa = paramMALength;
        bestiL = iL;
        bestiS = iS;
    end
end
disp(['1stHalfSumReturn = ', num2str(bestReturn)]);
cSizes = size(verificationC);
candlesCount = cSizes(1);

paramMALength=bestMa;
maxes=zeros(candlesCount,1);
mins=zeros(candlesCount,1);
K=zeros(candlesCount,1);
D=zeros(candlesCount,1);
kon=candlesCount-1;
for i=4:kon
    maxes(i) = max(verificationC(i-min(i-1,paramMALength):i-1,2));
    mins(i) = min(verificationC(i-min(i-1,paramMALength):i-1,3));
    K(i) = 100 * (sum(verificationC(i-min(i-1,3):i-1,4)-mins(i-min(i-1,2):i)) / sum(maxes(i-min(i-1,2):i)-mins(i-min(i-1,2):i)));
    D(i) = sum(K(i-min(i-1,2):i)) / min(i-1,3);
end

sumR=zeros(1,candlesCount);
R=zeros(1,candlesCount);
pocz=max(paramMALength, 10)+3;
iL=0; %liczba otwieranych pozycji kupna
iS=0; %liczba otwieranych pozycji sprzedarzy
lastCandle = kon-paramMALength;
recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
LastPos = 0;
for i=pocz:lastCandle
    
    if K(i-1) < D(i-1) && K(i) >= D(i)
        R(i)= - verificationC(i+1,4)+LastPos-spread; % zamkniêcie S
        LastPos = verificationC(i+1,1); % otwarcie L
        iL=iL+1;
    elseif K(i-1) > D(i-1) && K(i) <= D(i)
        R(i)= verificationC(i+1,4)-LastPos-spread; % zamkniêcie L
        LastPos = verificationC(i+1,1); % otwarcie S
        iS=iS+1;
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
%     disp(['zysk: ', num2str(sumReturn), ...
%         ' paramMALength: ', num2str(paramMALength), ...
%         ' Calmar: ', num2str(Calmar) ...
%         ]);

disp(['2ndHalfSumReturn = ', num2str(sumR(lastCandle))]);
disp(['bestCalmar = ', num2str(bestCalmar)]);
disp(['2ndHalfCalmar = ', num2str(Calmar)]);
disp(['la = ', num2str(iL+iS)]); %liczba otwartych pozycji
disp(['bestMa = ', num2str(bestMa)]);

% ZAPIS

fileID =fopen(['SS_' file_name '_S4LS_calmar.txt'],'w');
fprintf(fileID,'OKRES UCZ¥CY\n');
fprintf(fileID,['Zysk skumulowany:     ', num2str(bestReturn), '\n']);
fprintf(fileID,['Calmar:     ', num2str(bestCalmar), '\n']);
fprintf(fileID,['Liczba otwartych pozycji d³ugich:     ', num2str(bestiL), '\n']);
fprintf(fileID,['Liczba otwartych pozycji krótkich:     ', num2str(bestiS), '\n\n']);

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
xlabel('Liczba Swiec');
ylabel('Zysk');
set(hFig, 'PaperPositionMode','auto')
print(hFig,'-dpng', '-r0',['SS_', file_name, '_S4LS_calmar'])


disp(['tElapsed ', num2str(toc(tStart))]);