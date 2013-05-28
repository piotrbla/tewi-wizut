%(C) Antoni Wiliñski 2013
%skrypt strategii S4 w projekcie TEWI - z dopasowaniem parametrów dla po³owy danych
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
eurusd1h5k;
bestReturn=-100;verificationC=C(2500:end,:); %C=C(1:2500,:);
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


for paramALength=9:9:91%liczba swiec wstecz do obliczenia maksimum
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
disp(['1stHalfSumReturn = ', num2str(bestReturn)]);
cSizes = size(verificationC);
candlesCount = cSizes(1);

for paramALength=bestMa
    maxes=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        maxes(i) = max(verificationC(i-min(i-1,paramALength):i,4));
    end
    for paramAVolLength=bestparamAVolLength%liczba swiec wstecz do obliczenia sredniego wolumenu
        disp(['paramALength ', num2str(paramALength), '  paramAVolLength ', num2str(paramAVolLength)]);
        volAverages=zeros(1, candlesCount);
        for i=2:kon
            volAverages(i) = mean(verificationC(i-min(i-1,paramAVolLength):i,5))-verificationC(i,5);
        end
        for paramADuration=bestparamADuration %liczba kroków wprzód do zamkniecia pozycji
            for paramAVolThreshold=bestparamAVolThreshold%próg dla sredniego wolumenu
                for paramABuffer=bestparamABuffer%dla kwadrantu a i b szukamy ujemnych wartoœci, dla kwadrantów c i d dodatnich wartoœci bufora
                    for paramASL=bestparamASL  %Stop Loss minimalnie mo¿e byæ równy 8*spread 0.00384%
                        
                        sumRa=zeros(1,candlesCount);
                        Ra=zeros(1,candlesCount);
                        dZ=zeros(1,candlesCount);
                        pocz=max(paramAVolLength, paramALength)+2;
                        la=0; %liczba otwieranych pozycji
                        kas=0;
                        lastCandle = kon-max(paramALength, paramAVolLength) - paramADuration;
                        for i=pocz:lastCandle
                            
                            if maxes(i) + paramABuffer <verificationC(i,4) && volAverages(i)<paramAVolThreshold
                                Ra(i)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                                L=min(verificationC(i+1:i+paramADuration,3));
                                
                                if (-verificationC(i+1,1)+L)<-paramASL
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

disp(['2ndHalfSumReturn = ', num2str(sumRa(lastCandle))]);
disp(['bestCalmar = ', num2str(bestCalmar)]);
disp(['2ndHalfCalmar = ', num2str(Calmar)]);
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
