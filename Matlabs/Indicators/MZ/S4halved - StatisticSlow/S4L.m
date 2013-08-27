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
    
    for paramADuration=2:20:1000; %liczba kroków wprzód do zamkniecia pozycji
        for paramASL=spread*8:spread*4:spread*120;  %Stop Loss
            
            sumRa=zeros(1,candlesCount);
            Ra=zeros(1,candlesCount);
            pocz=max(paramMALength, 10)+3;
            la=0; %liczba otwieranych pozycji
            kas=0;
            lastCandle = kon-paramMALength - paramADuration;
            recordReturn=0;  %rekord zysku
            recordDrawdown=0;  %rekord obsuniecia
            for i=pocz:lastCandle
                
                if K(i-1) < D(i-1) && K(i) >= D(i)
                    Ra(i)=C(i+paramADuration,4)-C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                    L=min(C(i+1:i+paramADuration,3));
                    
                    if (-C(i+1,1)+L)<-paramASL
                        Ra(i)=-paramASL;
                        ls=ls+1;
                    end
                    
                    la=la+1;
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
                    ' paramASL: ', num2str(paramASL), ...
                    ' Calmar: ', num2str(Calmar) ...
                    ]);
                bestCalmar=Calmar;
                bestMa = paramMALength;
                bestparamADuration = paramADuration;
                bestparamASL = paramASL;
                bestLa = la;
            end
        end
    end
end
disp(['1stHalfSumReturn = ', num2str(bestReturn)]);
cSizes = size(verificationC);
candlesCount = cSizes(1);

for paramMALength=bestMa
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
    
    for paramADuration=bestparamADuration %liczba kroków wprzód do zamkniecia pozycji
        for paramASL=bestparamASL  %Stop Loss minimalnie mo¿e byæ równy 8*spread 0.00384%
            
            sumRa=zeros(1,candlesCount);
            Ra=zeros(1,candlesCount);
            pocz=max(paramMALength, 10)+3;
            la=0; %liczba otwieranych pozycji
            kas=0;
            lastCandle = kon-paramMALength - paramADuration;
            recordReturn=0;  %rekord zysku
            recordDrawdown=0;  %rekord obsuniecia
            for i=pocz:lastCandle
                
                if K(i-1) < D(i-1) && K(i) >= D(i)
                    Ra(i)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                    L=min(verificationC(i+1:i+paramADuration,3));
                    
                    if (-verificationC(i+1,1)+L)<-paramASL
                        Ra(i)=-paramASL;
                        ls=ls+1;
                    end
                    
                    la=la+1;
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
                ' paramMALength: ', num2str(paramMALength), ...
                ' paramADuration: ', num2str(paramADuration), ...
                ' paramASL: ', num2str(paramASL), ...
                ' Calmar: ', num2str(Calmar) ...
                ]);
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
print(hFig,'-dpng', '-r0',[file_name, '_S4L'])


disp(['tElapsed ', num2str(toc(tStart))]);