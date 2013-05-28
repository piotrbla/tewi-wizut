%(C) Antoni Wiliñski 2013
%skrypt strategii S1 w projekcie TEWI
%S4a - pierwszy kwadrant - oznaczajacy za³o¿enie, ze trend jest rosnacy i
%nale¿y otwierac pozycje d³ugie wg zasady Buy Limit

%parametry:
% paramALength= 5;%2;
% paramAVolLength=4;%10; %liczba swiec wstecz do obliczenia sredniego wolumenu
% paramABuffer=0.00021;%0.0007;
% paramAVolThreshold=110;%950; %próg dla sredniego wolumenu
% paramADuration=8; %liczba kroków wprzód do zamkniecia pozycji
% paramASL=0.0023;  %Stop Loss

%Dane:
tStart=tic;
eurusd1h020313PB;
bestReturn=0;
cSizes = size(C);
candlesCount = cSizes(1);
bestCalmar = 0;
bestMa = 0;
bestparamAVolLength = 0;
bestparamADuration = 0;
bestparamABuffer = 0;
bestparamAVolThreshold = 0;
bestparamASL = 0;
spread = 0.00016;
lastCandle = 0 ;

% sumReturn = 2.2356
% bestCalmar = 5.2365
% la = 14200
% bestMa = 9
% sharpeRatio = 1.2795
% bestparamAVolLength = 18
% bestparamADuration = 16
% bestparamABuffer = -0.0032
% bestparamAVolThreshold = 100
% bestparamASL = 0.00576
%zysk: 8.9633 paramALength: 9 paramAVolLength: 26 paramABuffer: -0.00416 paramAVolThreshold: 100 paramADuration: 16 paramASL: 0.00592 Calmar: 5.3362
for paramALength=9%:10:69%liczba swiec wstecz do obliczenia maksimum
    maxes=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        maxes(i) = max(C(i-min(i-1,paramALength):i,4));
    end
    for paramAVolLength=26%:1:38;%liczba swiec wstecz do obliczenia sredniego wolumenu
        disp(['paramALength ', num2str(paramALength), '  paramAVolLength ', num2str(paramAVolLength)]);
        volAverages=zeros(1, candlesCount);
        for i=2:kon
            volAverages(i) = mean(C(i-min(i-1,paramAVolLength):i,5))-C(i,5);
        end
        for paramADuration=16%6:1:16; %liczba kroków wprzód do zamkniecia pozycji
            for paramAVolThreshold=100%-100:100:100; %próg dla sredniego wolumenu
                for paramABuffer=-spread*28:spread:spread%-0.0032%-0.0032:0.0032:0.0032%dla kwadrantu a i b szukamy ujemnych wartoœci, dla kwadrantów c i d dodatnich wartoœci bufora
                    for paramASL=spread*35:spread*1:spread*48;  %Stop Loss minimalnie mo¿e byæ równy 8*spread 0.00384%
                        
                        sumRa=zeros(1,candlesCount);
                        Ra=zeros(1,candlesCount);
                        dZ=zeros(1,candlesCount);
                        pocz=max(paramAVolLength, paramALength)+2;
                        la=0; %liczba otwieranych pozycji
                        kas=0;
                        lastCandle = kon-max(paramALength, paramAVolLength) - paramADuration;
                        for i=pocz:lastCandle
                            
                            if maxes(i) + paramABuffer <C(i,4) && volAverages(i)<paramAVolThreshold
                                Ra(i)=C(i+paramADuration,4)-C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                                L=min(C(i+1:i+paramADuration,3));
                                
                                if (-C(i+1,1)+L)<-paramASL
                                    Ra(i)=-paramASL;
                                    ls=ls+1;
                                end
                                
                                la=la+1;
                                kas=1;
                            end
                            sumRa(i)=sumRa(i-1) + Ra(i);  %krzywa narastania kapita³u
                        end
                        
                        
                        recordReturn=0;  %rekord zysku
                        recordDrawdown=0;  %rekord obsuniecia
                        
                        for j=1:lastCandle
                            if sumRa(j)>recordReturn
                                recordReturn=sumRa(j);
                            end
                            
                            dZ(j)=sumRa(j)-recordReturn; %róznica pomiedzy bie¿¹c¹ wartoscia kapita³u skumulowanego a dotychczasowym rekordem
                            
                            if dZ(j)<recordDrawdown
                                recordDrawdown=dZ(j);  %obsuniecie maksymalne
                            end
                            
                        end
                        
                        %wyniki koñcowe
                        sumReturn=sumRa(lastCandle);
                        Calmar=-sumReturn/recordDrawdown;  %wskaznik Calmara
                        if bestReturn<sumReturn
                            bestReturn=sumReturn;bestCalmar=Calmar;
                            bestMa = paramALength;
                            bestparamAVolLength = paramAVolLength ;
                            bestparamADuration = paramADuration;
                            bestparamABuffer = paramABuffer;
                            bestparamAVolThreshold = paramAVolThreshold;
                            bestparamASL = paramASL;
                            disp(['zysk: ', num2str(sumReturn), ...
                                ' paramALength: ', num2str(paramALength), ...
                                ' paramAVolLength: ', num2str(paramAVolLength), ...
                                ' paramABuffer: ', num2str(paramABuffer), ...
                                ' paramAVolThreshold: ', num2str(paramAVolThreshold), ...
                                ' paramADuration: ', num2str(paramADuration), ...
                                ' paramASL: ', num2str(paramASL), ...
                                ' Calmar: ', num2str(Calmar) ...
                                ]);
                        end
                        
                        
                    end
                end
            end
        end
    end
end
disp(['sumReturn = ', num2str(sumRa(lastCandle))]);
disp(['bestCalmar = ', num2str(bestCalmar)]);
disp(['la = ', num2str(la)]); %liczba otwartych pozycji
disp(['bestMa = ', num2str(bestMa)]);
disp(['sharpeRatio = ', num2str(sharpe(sumRa, 0))]);
disp(['bestparamAVolLength = ', num2str(bestparamAVolLength)]);
disp(['bestparamADuration = ', num2str(bestparamADuration)]);
disp(['bestparamABuffer = ', num2str(bestparamABuffer)]);
disp(['bestparamAVolThreshold = ', num2str(bestparamAVolThreshold)]);
disp(['bestparamASL = ', num2str(bestparamASL)]);
sumRa = sumRa(sumRa~=0);
hFig = figure(1);
set(hFig, 'Position', [200 200 640 480])
plot(sumRa)
title(['Zysk skumulowany - strategia: ', mfilename]);
xlabel('Liczba œwiec');
ylabel('Zysk');
set(hFig, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig,'-dpng', '-r0',mfilename)
disp(['tElapsed', num2str(toc(tStart))]);
