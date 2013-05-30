%(C) Antoni Wiliñski 2013
%skrypt strategii S4 w projekcie TEWI - z dopasowaniem parametrów dla po³owy danych
%S4d - czwarty kwadrant - oznaczajacy za³o¿enie, ze trend jest spadkowy i
%nale¿y otwierac pozycje krótkie

%parametry:
% paramDLength= 5;%2;
% paramDVolLength=4;%10; %liczba swiec wstecz do obliczenia sredniego wolumenu
% paramDBuffer=0.00021;%0.0007;
% paramDVolThreshold=110;%950; %próg dla sredniego wolumenu
% paramDDuration=8; %liczba kroków wprzód do zamkniecia pozycji
% paramDSL=0.0023;  %Stop Loss

%Dane:
tStart=tic;
eurusd1h5k;
bestReturn=-100;verificationC=C(2500:end,:); C=C(1:2500,:);
cSizes = size(C);
candlesCount = cSizes(1);
bestCalmar = 0;
bestMa = 0;
bestparamDVolLength = 0;
bestparamDDuration = 0;
bestparamDBuffer = 0;
bestparamDVolThreshold = 0;
bestparamDSL = 0;
spread = 0.00016;
lastCandle = 0 ;


for paramDLength=9:9:91%liczba swiec wstecz do obliczenia maksimum
    maxes=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        maxes(i) = max(C(i-min(i-1,paramDLength):i,4));
    end
    for paramDVolLength=26%:1:38;%liczba swiec wstecz do obliczenia sredniego wolumenu
        disp(['paramDLength ', num2str(paramDLength), '  paramDVolLength ', num2str(paramDVolLength)]);
        volDverages=zeros(1, candlesCount);
        for i=2:kon
            volDverages(i) = mean(C(i-min(i-1,paramDVolLength):i,5))-C(i,5);
        end
        for paramDDuration=16%6:1:16; %liczba kroków wprzód do zamkniecia pozycji
            for paramDVolThreshold=100%-100:100:100; %próg dla sredniego wolumenu
                for paramDBuffer=-spread*28:spread:spread%-0.0032%-0.0032:0.0032:0.0032%dla kwadrantu a i b szukamy ujemnych wartoœci, dla kwadrantów c i d dodatnich wartoœci bufora
                    for paramDSL=spread*35:spread*1:spread*48;  %Stop Loss minimalnie mo¿e byæ równy 8*spread 0.00384%
                        
                        sumRa=zeros(1,candlesCount);
                        Ra=zeros(1,candlesCount);
                        dZ=zeros(1,candlesCount);
                        pocz=max(paramDVolLength, paramDLength)+2;
                        la=0; %liczba otwieranych pozycji
                        kas=0;
                        lastCandle = kon-max(paramDLength, paramDVolLength) - paramDDuration;
                        for i=pocz:lastCandle
                            
                            if maxes(i) - paramDBuffer >C(i,4) && volDverages(i)<paramDVolThreshold
                                Ra(i)=-C(i+paramDDuration,4)+C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramDDuration kroku
                                H=max(C(i+1:i+paramDDuration,2));
                                
                                if (C(i+1,1)-H)<-paramDSL
                                    Ra(i)=-paramDSL;
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
                            bestMa = paramDLength;
                            bestparamDVolLength = paramDVolLength ;
                            bestparamDDuration = paramDDuration;
                            bestparamDBuffer = paramDBuffer;
                            bestparamDVolThreshold = paramDVolThreshold;
                            bestparamDSL = paramDSL;
                            disp(['zysk: ', num2str(sumReturn), ...
                                ' paramDLength: ', num2str(paramDLength), ...
                                ' paramDVolLength: ', num2str(paramDVolLength), ...
                                ' paramDBuffer: ', num2str(paramDBuffer), ...
                                ' paramDVolThreshold: ', num2str(paramDVolThreshold), ...
                                ' paramDDuration: ', num2str(paramDDuration), ...
                                ' paramDSL: ', num2str(paramDSL), ...
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

for paramDLength=bestMa
    maxes=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        maxes(i) = max(verificationC(i-min(i-1,paramDLength):i,4));
    end
    for paramDVolLength=bestparamDVolLength%liczba swiec wstecz do obliczenia sredniego wolumenu
        disp(['paramDLength ', num2str(paramDLength), '  paramDVolLength ', num2str(paramDVolLength)]);
        volDverages=zeros(1, candlesCount);
        for i=2:kon
            volDverages(i) = mean(verificationC(i-min(i-1,paramDVolLength):i,5))-verificationC(i,5);
        end
        for paramDDuration=bestparamDDuration %liczba kroków wprzód do zamkniecia pozycji
            for paramDVolThreshold=bestparamDVolThreshold%próg dla sredniego wolumenu
                for paramDBuffer=bestparamDBuffer%dla kwadrantu a i b szukamy ujemnych wartoœci, dla kwadrantów c i d dodatnich wartoœci bufora
                    for paramDSL=bestparamDSL  %Stop Loss minimalnie mo¿e byæ równy 8*spread 0.00384%
                        
                        sumRa=zeros(1,candlesCount);
                        Ra=zeros(1,candlesCount);
                        dZ=zeros(1,candlesCount);
                        pocz=max(paramDVolLength, paramDLength)+2;
                        la=0; %liczba otwieranych pozycji
                        kas=0;
                        lastCandle = kon-max(paramDLength, paramDVolLength) - paramDDuration;
                        for i=pocz:lastCandle
                            
                            if maxes(i) - paramDBuffer >verificationC(i,4) && volDverages(i)<paramDVolThreshold
                                Ra(i)=-verificationC(i+paramDDuration,4)+verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramDDuration kroku
                                H=max(verificationC(i+1:i+paramDDuration,2));
                                
                                if (verificationC(i+1,1)-H)<-paramDSL
                                    Ra(i)=-paramDSL;
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
                            ' paramDLength: ', num2str(paramDLength), ...
                            ' paramDVolLength: ', num2str(paramDVolLength), ...
                            ' paramDBuffer: ', num2str(paramDBuffer), ...
                            ' paramDVolThreshold: ', num2str(paramDVolThreshold), ...
                            ' paramDDuration: ', num2str(paramDDuration), ...
                            ' paramDSL: ', num2str(paramDSL), ...
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
disp(['bestparamDVolLength = ', num2str(bestparamDVolLength)]);
disp(['bestparamDDuration = ', num2str(bestparamDDuration)]);
disp(['bestparamDBuffer = ', num2str(bestparamDBuffer)]);
disp(['bestparamDVolThreshold = ', num2str(bestparamDVolThreshold)]);
disp(['bestparamDSL = ', num2str(bestparamDSL)]);
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
