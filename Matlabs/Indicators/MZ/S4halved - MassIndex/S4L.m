%(C) Micha³ Zab³ocki 2013
%skrypt strategii S4 w projekcie TEWI
%S4L - sygna³ kupna - przeciêcia linii, %K ponad %D

%parametry:
% paramMALength - MA length
% paramADuration - liczba kroków wprzód do zamkniecia pozycji
% paramASL - Stop Loss

%Dane:
tStart=tic;
verificationC=C(5400:end,:); C=C(1:5399,:);

cSizes = size(C);
candlesCount = cSizes(1);
bestCalmar = 0;
bestMa = 0;
bestparamADuration = 0;
bestparamASL = 0;
bestReturn = -1000;
bestLa = 0;
bestBorder = 0;
lastCandle = 0 ;

HL = C(:,2) - C(:,3);

for paramMALength=1000:-20:2 %MA length
    disp(['# Postep: ', 'paramMALength ', num2str(paramMALength), '   Czas: ', num2str(toc(tStart))]);
    MAverages=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        MAverages(i) = mean(C(i-min(i-1,paramMALength):i,4));
    end
    MI = zeros(candlesCount,1);
    HLaverage = ema(HL,9);
    EMA2 = HLaverage(9:end) ./ ema(HLaverage(9:end),9);
    for i = 41:kon-16
        MI(i) = sum(EMA2(i-24:i));
    end
    
    for paramADuration=2:10:100; %liczba kroków wprzód do zamkniecia pozycji
        for paramASL=spread*8:spread*4:spread*20;  %Stop Loss
            for border=25:0.1:27  % border
                sumRa=zeros(1,candlesCount);
                Ra=zeros(1,candlesCount);
                pocz=max(paramMALength, 10)+40;
                la=0; %liczba otwieranych pozycji
                kas=0;
                lastCandle = kon-max(paramADuration, 16);
                recordReturn=0;  %rekord zysku
                recordDrawdown=0;  %rekord obsuniecia
                pic1 = false;
                
                for i=pocz:lastCandle
                    
                    if pic1 == false && MI(i) > 27
                        pic1 = true;
                    end
                    if pic1 == true && MI(i) < 26.5
                        if C(i,4) > MAverages(i)
                            Ra(i)=C(i+paramADuration,4)-C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                            H=max(C(i+1:i+paramADuration,2));
                            
                            if (C(i+1,1)-H)<-paramASL
                                Ra(i)=-paramASL;
                                ls=ls+1;
                            end
                            
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
                if bestReturn<sumReturn
                    bestReturn=sumReturn;
                    bestSumRa = sumRa;
                    disp(['zysk koñcowy: ', num2str(bestReturn), ...
                        ' paramMALength: ', num2str(paramMALength), ...
                        ' paramADuration: ', num2str(paramADuration), ...
                        ' border: ', num2str(border), ...
                        ' paramASL: ', num2str(paramASL), ...
                        ' Calmar: ', num2str(Calmar) ...
                        ]);
                    bestCalmar=Calmar;
                    bestMa = paramMALength;
                    bestBorder = border;
                    bestparamADuration = paramADuration;
                    bestparamASL = paramASL;
                    bestLa = la;
                end
            end
        end
    end
end
disp(['1stHalfSumReturn = ', num2str(bestReturn)]);
cSizes = size(verificationC);
candlesCount = cSizes(1);

HL = verificationC(:,2) - verificationC(:,3);

for paramALength=bestMa
    kon=candlesCount-1;
    for i=2:kon
        MAverages(i) = mean(verificationC(i-min(i-1,paramMALength):i,4));
    end
    MI = zeros(candlesCount,1);
    HLaverage = ema(HL,9);
    EMA2 = HLaverage(9:end) ./ ema(HLaverage(9:end),9);
    for i = 41:kon-16
        MI(i) = sum(EMA2(i-24:i));
    end
    
    for paramADuration=bestparamADuration %liczba kroków wprzód do zamkniecia pozycji
        for paramASL=bestparamASL  %Stop Loss minimalnie mo¿e byæ równy 8*spread 0.00384%
            for border=bestBorder  % border
                sumRa=zeros(1,candlesCount);
                Ra=zeros(1,candlesCount);
                pocz=max(paramMALength, 10)+40;
                la=0; %liczba otwieranych pozycji
                kas=0;
                lastCandle = kon-max(paramADuration, 16);
                recordReturn=0;  %rekord zysku
                recordDrawdown=0;  %rekord obsuniecia
                pic1 = false;
                
                for i=pocz:lastCandle
                    
                    if pic1 == false && MI(i) > 27
                        pic1 = true;
                    end
                    if pic1 == true && MI(i) < 26.5
                        if verificationC(i,4) > MAverages(i)
                            Ra(i)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                            H=max(verificationC(i+1:i+paramADuration,2));
                            
                            if (verificationC(i+1,1)-H)<-paramASL
                                Ra(i)=-paramASL;
                                ls=ls+1;
                            end
                            
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
                    ' paramMALength: ', num2str(paramALength), ...
                    ' paramADuration: ', num2str(paramADuration), ...
                    ' border: ', num2str(border), ...
                    ' paramASL: ', num2str(paramASL), ...
                    ' Calmar: ', num2str(Calmar) ...
                    ]);
            end
        end
    end
end
disp(['2ndHalfSumReturn = ', num2str(sumRa(lastCandle))]);
disp(['bestCalmar = ', num2str(bestCalmar)]);
disp(['2ndHalfCalmar = ', num2str(Calmar)]);
disp(['la = ', num2str(la)]); %liczba otwartych pozycji
disp(['bestMa = ', num2str(bestMa)]);
disp(['bestBorder = ', num2str(bestBorder)]);
disp(['bestparamADuration = ', num2str(bestparamADuration)]);
disp(['bestparamASL = ', num2str(bestparamASL)]);

% ZAPIS

fileID =fopen([file_name '_S4L.txt'],'w');
fprintf(fileID,['S4L', '\n']);
fprintf(fileID,['lerningBestReturn = ', num2str(bestReturn), '\n']);
fprintf(fileID,['lerningBestCalmar = ', num2str(bestCalmar), '\n']);
fprintf(fileID,['testBestReturn = ', num2str(sumRa(lastCandle)), '\n']);
fprintf(fileID,['testBestCalmar = ', num2str(Calmar), '\n']);
fprintf(fileID,['bestMa = ', num2str(bestMa), '\n']);
fprintf(fileID,['bestBorder = ', num2str(bestBorder), '\n']);
fprintf(fileID,['bestparamADuration = ', num2str(bestparamADuration), '\n']);
fprintf(fileID,['lerningBestLa = ', num2str(la), '\n']);
fprintf(fileID,['testBestLa = ', num2str(bestLa), '\n']);
fprintf(fileID,['bestparamASL = ', num2str(bestparamASL), '\n']);
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