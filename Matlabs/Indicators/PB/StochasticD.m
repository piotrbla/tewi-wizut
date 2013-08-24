%(C) Piotr B³aszyñski 2013
%skrypt strategii Stochastic Fast w projekcie TEWI - z dopasowaniem parametrów dla po³owy danych

%parametry:
% paramALength= 5;%2;
% paramAEmaLength=4;%10; %liczba swiec wstecz do obliczenia sredniego wolumenu
% paramABuffer=0.00021;%0.0007;
% paramAVolThreshold=110;%950; %próg dla sredniego wolumenu
% paramADuration=8; %liczba kroków wprzód do zamkniecia pozycji
% paramASL=0.0023;  %Stop Loss

%Dane:
tStart=tic;
eurusd;
bestReturn=-100;verificationC=C(5400:end,:); C=C(1:5400,:);
cSizes = size(C);
candlesCount = cSizes(1);
bestCalmar = 0;
bestMa = 0;
bestparamAEmaLength = 0;
bestparamADuration = 0;
bestparamABuffer = 0;
bestparamAVolThreshold = 0;
bestparamASL = 0;

spread = 0.00016;
lastCandle = 0 ;


for paramALength=120:1:130 %liczba swiec wstecz do obliczenia maksimum
    kValues=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon %O-1, H-2, L-3, C-4
        maxValue = max(C(i-min(i-1,paramALength)+1:i,2));
        minValue = min(C(i-min(i-1,paramALength)+1:i,3));
        kValues(i)= 100*((C(i,4)-minValue)/(maxValue-minValue));
    end
    for paramAEmaLength=15:1:25%liczba swiec do wyg³adzania œredniej
        dValues = ema(kValues, paramAEmaLength);
        disp(['paramALength ', num2str(paramALength), '  paramAEmaLength ', num2str(paramAEmaLength)]);
        for paramADuration=6:2:30; %liczba kroków wprzód do zamkniecia pozycji
            for paramAVolThreshold=100%-100:100:100; %próg dla sredniego wolumenu
                for paramABuffer=0%-spread*28:spread:spread%-0.0032%-0.0032:0.0032:0.0032%dla kwadrantu a i b szukamy ujemnych wartoœci, dla kwadrantów c i d dodatnich wartoœci bufora
                    for paramASL=spread*35:spread*2:spread*98;  %Stop Loss minimalnie mo¿e byæ równy 8*spread 0.00384%
                        
                        sumRa=zeros(1,candlesCount);
                        Ra=zeros(1,candlesCount);
                        dZ=zeros(1,candlesCount);
                        pocz=max(paramAEmaLength, paramALength)+2;
                        la=0; %liczba otwieranych pozycji
                        kas=0;
                        lastCandle = kon-max(paramALength, paramAEmaLength) - paramADuration;
                        for i=pocz:lastCandle
                            
                            if kValues(i)<dValues(i) && kValues(i-1)>=dValues(i-1) 
                                Ra(i)=-C(i+paramADuration,4)+C(i+1,1)-spread; %zysk z i-tej pozycji short zamykanej na zamkniêciu po paramCDuration kroku
                                H=max(C(i+1:i+paramADuration,3));
                                if (C(i+1,1)-H)<-paramASL
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
                            bestparamAEmaLength = paramAEmaLength ;
                            bestparamADuration = paramADuration;
                            bestparamABuffer = paramABuffer;
                            bestparamAVolThreshold = paramAVolThreshold;
                            bestparamASL = paramASL;
                            disp(['zysk: ', num2str(sumReturn), ...
                                ' paramALength: ', num2str(paramALength), ...
                                ' paramAEmaLength: ', num2str(paramAEmaLength), ...
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
    kValues=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        maxValue = max(verificationC(i-min(i-1,paramALength)+1:i,2));
        minValue = min(verificationC(i-min(i-1,paramALength)+1:i,3));
        kValues(i)= 100*((verificationC(i,4)-minValue)/(maxValue-minValue));
    end
    for paramAEmaLength=bestparamAEmaLength%liczba swiec wstecz do obliczenia sredniego wolumenu
        dValues = ema(kValues, paramAEmaLength);
        disp(['paramALength ', num2str(paramALength), '  paramAEmaLength ', num2str(paramAEmaLength)]);
        for paramADuration=bestparamADuration %liczba kroków wprzód do zamkniecia pozycji
            for paramAVolThreshold=bestparamAVolThreshold%próg dla sredniego wolumenu
                for paramABuffer=bestparamABuffer%dla kwadrantu a i b szukamy ujemnych wartoœci, dla kwadrantów c i d dodatnich wartoœci bufora
                    for paramASL=bestparamASL  %Stop Loss minimalnie mo¿e byæ równy 8*spread 0.00384%
                        
                        sumRa=zeros(1,candlesCount);
                        Ra=zeros(1,candlesCount);
                        dZ=zeros(1,candlesCount);
                        pocz=max(paramAEmaLength, paramALength)+2;
                        la=0; %liczba otwieranych pozycji
                        kas=0;
                        lastCandle = kon-max(paramALength, paramAEmaLength) - paramADuration;
                        for i=pocz:lastCandle
                            
                            if kValues(i)<dValues(i) && kValues(i-1)>=dValues(i-1) 
                                Ra(i)=-verificationC(i+paramADuration,4)+verificationC(i+1,1)-spread; %zysk z i-tej pozycji short zamykanej na zamkniêciu po paramDDuration kroku
                                H=max(verificationC(i+1:i+paramADuration,3));
                                if (verificationC(i+1,1)-H)<-paramASL
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
                            ' paramAEmaLength: ', num2str(paramAEmaLength), ...
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
disp(['bestparamAEmaLength = ', num2str(bestparamAEmaLength)]);
disp(['bestparamADuration = ', num2str(bestparamADuration)]);
disp(['bestparamABuffer = ', num2str(bestparamABuffer)]);
disp(['bestparamAVolThreshold = ', num2str(bestparamAVolThreshold)]);
disp(['bestparamASL = ', num2str(bestparamASL)]);
disp(['returnPipsPerCandle = ', num2str(sumRa(lastCandle)/candlesCount*10000)]);
sumRa = sumRa(sumRa~=0);

hFig1 = figure(1);
set(hFig1, 'Position', [200 200 640 480]);
plot(sumRa);
title(['Return: ', mfilename]);
xlabel('Candles count');
ylabel('Zysk');
set(hFig1, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig1,'-dpng', '-r0',mfilename)

oscFileName = strcat(mfilename, 'osc');
hFig2 = figure(2);
set(hFig2, 'Position', [200 200 640 480]);
plot(kValues(3:300));
hold on;
plot(dValues(3:300));
title(['Stochastic Fast - strategia: ', mfilename]);
xlabel('Candles count');
ylabel('Oscillator');
set(hFig2, 'PaperPositionMode','auto')   %# WYSIWYG
print(hFig2,'-dpng', '-r0', oscFileName)

disp(['tElapsed', num2str(toc(tStart))]);
