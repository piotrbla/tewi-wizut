%(C) Antoni Wiliñski 2013
%skrypt strategii S1 w projekcie TEWI
%S4c - trzeci kwadrant - oznaczajacy za³o¿enie, ze trend jest horyzontalny i
%nale¿y otwierac pozycje d³ugie wg zasady Buy Limit

%parametry:
% paramCLength= 5;%2;
% paramCVolLength=4;%10; %liczba swiec wstecz do obliczenia sredniego wolumenu
% paramCBuffer=0.00021;%0.0007;
% paramCVolThreshold=110;%950; %próg dla sredniego wolumenu
% paramCDuration=8; %liczba kroków wprzód do zamkniecia pozycji
% paramCSL=0.0023;  %Stop Loss

%Dane:
tStart=tic;
eurusd1h020313PB;
bestReturn=0;
cSizes = size(C);
candlesCount = cSizes(1);
bestCalmar = 0;
bestMa = 0;
bestparamCVolLength = 0;
bestparamCDuration = 0;
bestparamCBuffer = 0;
bestparamCVolThreshold = 0;
bestparamCSL = 0;
spread = 0.00016;
lastCandle = 0 ;


for paramCLength=49%liczba swiec wstecz do obliczenia maksimum
    maxes=zeros(1, candlesCount);
    kon=candlesCount-1;
    for i=2:kon
        maxes(i) = max(C(i-min(i-1,paramCLength):i,4));
    end
    for paramCVolLength=16%10:1:18;%liczba swiec wstecz do obliczenia sredniego wolumenu
        disp(['paramCLength ', num2str(paramCLength), '  paramCVolLength ', num2str(paramCVolLength)]);
        volCverages=zeros(1, candlesCount);
        for i=2:kon
            volCverages(i) = mean(C(i-min(i-1,paramCVolLength):i,5))-C(i,5);
        end
        for paramCDuration=10%8:2:16; %liczba kroków wprzód do zamkniecia pozycji
            for paramCVolThreshold=-100%:100:0; %próg dla sredniego wolumenu
                for paramCBuffer=-0.0032%-0.0032:0.0032:0.0032%dla kwadrantu a i b szukamy ujemnych wartoœci, dla kwadrantów c i d dodatnich wartoœci bufora
                    for paramCSL=0.00384%spread*8:spread*4:spread*38;  %Stop Loss minimalnie mo¿e byæ równy 8*spread
                        
                        sumRa=zeros(1,candlesCount);
                        Ra=zeros(1,candlesCount);
                        dZ=zeros(1,candlesCount);
                        pocz=max(paramCVolLength, paramCLength)+2;
                        la=0; %liczba otwieranych pozycji
                        kas=0;
                        lastCandle = kon-max(paramCLength, paramCVolLength) - paramCDuration;
                        for i=pocz:lastCandle
                            
                            if maxes(i) - paramCBuffer >C(i,4) && volCverages(i)<paramCVolThreshold
                                Ra(i)=C(i+paramCDuration,4)-C(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramCDuration kroku
                                L=min(C(i+1:i+paramCDuration,3));
                                
                                if (-C(i+1,1)+L)<-paramCSL
                                    Ra(i)=-paramCSL;
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
                            bestMa = paramCLength;
                            bestparamCVolLength = paramCVolLength ;
                            bestparamCDuration = paramCDuration;
                            bestparamCBuffer = paramCBuffer;
                            bestparamCVolThreshold = paramCVolThreshold;
                            bestparamCSL = paramCSL;
                            disp(['zysk: ', num2str(sumReturn), ...
                                ' paramCLength: ', num2str(paramCLength), ...
                                ' paramCVolLength: ', num2str(paramCVolLength), ...
                                ' paramCBuffer: ', num2str(paramCBuffer), ...
                                ' paramCVolThreshold: ', num2str(paramCVolThreshold), ...
                                ' paramCDuration: ', num2str(paramCDuration), ...
                                ' paramCSL: ', num2str(paramCSL), ...
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
disp(['bestparamCVolLength = ', num2str(bestparamCVolLength)]);
disp(['bestparamCDuration = ', num2str(bestparamCDuration)]);
disp(['bestparamCBuffer = ', num2str(bestparamCBuffer)]);
disp(['bestparamCVolThreshold = ', num2str(bestparamCVolThreshold)]);
disp(['bestparamCSL = ', num2str(bestparamCSL)]);
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
