%(C) Antoni Wiliñski 2013
%skrypt strategii S1 w projekcie TEWI
%S1a - pierwszy kwadrant - oznaczajacy za³o¿enie, ze trend jest rosnacy i
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
%eurusd1h020313SILVER60;
eurusd1h020313PB;
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


for paramALength=28%10:6:40%liczba swiec wstecz do obliczenia maksimum
    maxes=zeros(1, candlesCount);
    for i=2:kon
        maxes(i) = max(C(i-min(i-1,paramALength):i-1,4));
    end
    for paramAVolLength=14%10:1:20;; %liczba swiec wstecz do obliczenia sredniego wolumenu
        disp(['paramALength ', num2str(paramALength), '  paramAVolLength ', num2str(paramAVolLength)]);
        volAverages=zeros(1, candlesCount);
        for i=2:kon
            volAverages(i) = mean(C(i-min(i-1,paramAVolLength):i,5))-C(i,5);
        end
        for paramADuration=15%8:1:20; %liczba kroków wprzód do zamkniecia pozycji
            for paramAVolThreshold=80%-100:20:100; %próg dla sredniego wolumenu
                for paramABuffer=0.0032%spread*10:spread*2:spread*30;%0.0007;
                    for paramASL=0.00352%spread*14:spread*4:spread*30;  %Stop Loss
                        
                        sumRa=zeros(1,candlesCount);
                        Ra=zeros(1,candlesCount);
                        dZ=zeros(1,candlesCount);
                        pocz=max(paramAVolLength, paramALength)+2;
                        kon=candlesCount-1;
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
                        
                        for j=1:kon
                            if sumRa(j)>recordReturn
                                recordReturn=sumRa(j);
                            end
                            
                            dZ(j)=sumRa(j)-recordReturn; %róznica pomiedzy bie¿¹c¹ wartoscia kapita³u skumulowanego a dotychczasowym rekordem
                            
                            if dZ(j)<recordDrawdown
                                recordDrawdown=dZ(j);  %obsuniecie maksymalne
                            end
                            
                        end
                        
                        %wyniki koñcowe
                        
                        Calmar=-sumRa(lastCandle)/recordDrawdown;  %wskaznik Calmara
                        if bestCalmar<Calmar
                            bestCalmar=Calmar;
                            bestMa = paramALength;
                            bestparamAVolLength = paramAVolLength ;
                            bestparamADuration = paramADuration;
                            bestparamABuffer = paramABuffer;
                            bestparamAVolThreshold = paramAVolThreshold;
                            bestparamASL = paramASL;
                        end
                        disp(['zysk koñcowy: ', num2str(sumRa(lastCandle)), ...
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
disp(['sumReturn', num2str(sumRa(lastCandle))]);
disp(['bestCalmar', num2str(bestCalmar)]);
disp(['la', num2str(la)]); %liczba otwartych pozycji
disp(['bestMa', num2str(bestMa)]);
disp(['sharpeRatio', num2str(sharpe(sumRa, 0))]);
disp(['bestparamAVolLength', num2str(bestparamAVolLength)]);
disp(['bestparamADuration', num2str(bestparamADuration)]);
disp(['bestparamABuffer', num2str(bestparamABuffer)]);
disp(['bestparamAVolThreshold', num2str(bestparamAVolThreshold)]);
disp(['bestparamASL', num2str(bestparamASL)]);
% lap=la/(kon-pocz)
%
sumRa = sumRa(sumRa~=0);
figure(1)
plot(sumRa)

%figure(2)
%plot(C(pocz:kon,4))
disp(['tElapsed', num2str(toc(tStart))]);