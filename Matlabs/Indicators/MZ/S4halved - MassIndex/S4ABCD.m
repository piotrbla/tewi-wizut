%(C) Micha³ Zab³ocki 2013
%skrypt strategii S4 w projekcie TEWI
%S4L - sygna³ kupna - przeciêcia linii, %K ponad %D

%parametry:
% paramAVolLength -
% paramADuration - liczba kroków wprzód do zamkniecia pozycji
% paramASL - Stop Loss

%Dane:
tStart=tic;
verificationC=C(5400:end,:); learningC=C(1:5399,:);

confusionMatrix.TP=zeros(1,4);
confusionMatrix.FP=zeros(1,4);
confusionMatrix.FN=zeros(1,4);
confusionMatrix.TN=zeros(1,4);

% bests(1:11) - najlepsze parametry pêtli, bests(12) - bestSumR,
%                      bests(13) - bestCalmar, bests(14) - bestLa
bests = cell(4,14);
bests(1:4,12) = {-1000};

paramAVolLength_min = 5;
paramAVolLength_step = 5;
paramAVolLength_max = 30;

hlAverageLength1_min = 2;
hlAverageLength1_step = 1;
hlAverageLength1_max = 50;

ema2Length_min = 2;
ema2Length_step = 1;
ema2Length_max = 50;

hlAverageLength2_min = 2;
hlAverageLength2_step = 1;
hlAverageLength2_max = 50;

sumLength_min = 2;
sumLength_step = 2;
sumLength_max = 50;

cAveragesLength_min = 2;
cAveragesLength_step = 2;
cAveragesLength_max = 50;

openBorder_min = 0;
openBorder_step = 0.1;
% openBorder_max = 50;

closeBorder_min = 0;
closeBorder_step = 0.1;
% closeBorder_max = 50;

paramADuration_min = 2;
paramADuration_step = 1;
paramADuration_max = 50;

paramAVolThreshold_min = 100;
paramAVolThreshold_step = -10;
paramAVolThreshold_max = 10;

paramASL_min = 8*spread;
paramASL_step = 3*spread;
paramASL_max = 30*spread;

paramAVolLength_Vector = paramAVolLength_min : paramAVolLength_step : paramAVolLength_max;
hlAverageLength1_Vector = hlAverageLength1_min : hlAverageLength1_step : hlAverageLength1_max;
ema2Length_Vector = ema2Length_min : ema2Length_step : ema2Length_max;
hlAverageLength2_Vector = hlAverageLength2_min : hlAverageLength2_step : hlAverageLength2_max;
sumLength_Vector = sumLength_min : sumLength_step : sumLength_max;
cAveragesLength_Vector = cAveragesLength_min : cAveragesLength_step : cAveragesLength_max;
paramADuration_Vector = paramADuration_min : paramADuration_step : paramADuration_max;
paramAVolThreshold_Vector = paramAVolThreshold_min : paramAVolThreshold_step : paramAVolThreshold_max;
paramASL_Vector = paramASL_min : paramASL_step : paramASL_max;

cSizes = size(learningC);
candlesCount = cSizes(1);
HL = learningC(:,2) - learningC(:,3);
sumReturn = 0;
Calmar = 0;

%g³ówne pêtle - parametry strategii
for mainLoopIter = 1:loopEnd
    
    m = size(paramAVolLength_Vector,2);
    paramAVolLength = paramAVolLength_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(hlAverageLength1_Vector,2);
    hlAverageLength1 = hlAverageLength1_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(ema2Length_Vector,2);
    ema2Length = ema2Length_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(hlAverageLength2_Vector,2);
    hlAverageLength2 = hlAverageLength2_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(sumLength_Vector,2);
    sumLength = sumLength_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(cAveragesLength_Vector,2);
    cAveragesLength = cAveragesLength_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(paramADuration_Vector,2);
    paramADuration = paramADuration_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(paramAVolThreshold_Vector,2);
    paramAVolThreshold = paramAVolThreshold_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(paramASL_Vector,2);
    paramASL = paramASL_Vector(round(1 + (m-1)*rand(1,1)));
    
    MI = zeros(candlesCount,1);
    volAverages=zeros(1, candlesCount);
    kon=candlesCount-1-hlAverageLength2;
    pocz = max([paramAVolLength min([hlAverageLength1 hlAverageLength2])+ema2Length+sumLength cAveragesLength]);
    HLaverage1 = ema(HL,hlAverageLength1);
    HLaverage2 = ema(HL,hlAverageLength2);
    EMA1 = ema(HLaverage2(hlAverageLength2:end),ema2Length);
    p = min([size(EMA1,1) size(HLaverage1,1)]) - 1;
    EMA2 = HLaverage1(end-p:end) ./ EMA1(end-p:end);
    for i=pocz:kon
        volAverages(i) = mean(learningC(i-min(i-1,paramAVolLength):i,5))-learningC(i,5);
        MI(i) = sum(EMA2(i-sumLength:i));
    end
    Caverages = ema(C(:,4),cAveragesLength);
    
    openBorder_Vector = openBorder_min : openBorder_step : max(MI);
    m = size(openBorder_Vector,2);
    openBorder = openBorder_Vector(round(1 + (m-1)*rand(1,1)));
    
    closeBorder_Vector = closeBorder_min : closeBorder_step : openBorder;
    m = size(closeBorder_Vector,2);
    closeBorder = closeBorder_Vector(round(1 + (m-1)*rand(1,1)));
    
    sumRa=zeros(4,candlesCount);
    la=zeros(1,4); %liczba otwieranych pozycji
    
    lastCandle = kon - paramADuration;
    recordReturn=zeros(1,4);  %rekord zysku
    recordDrawdown=zeros(1,4);  %rekord obsuniecia
    pic = false;
    
    for i=pocz:lastCandle
        
        Ra=zeros(1,4);
        
        if pic == false && MI(i) > openBorder
            pic = true;
        end
        
        if pic == true && MI(i) < closeBorder
            %A
            if C(i,4) > Caverages(i) && volAverages(i)<paramAVolThreshold
                Ra(1)=learningC(i+paramADuration,4)-learningC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                L=min(learningC(i+1:i+paramADuration,3));
                
                if (-learningC(i+1,1)+L)<-paramASL
                    Ra(1)=-paramASL;
                end
                
                la(1)=la(1)+1;
            end
            
            %B
            if C(i,4) > Caverages(i) && volAverages(i)<paramAVolThreshold
                Ra(2)=-learningC(i+paramADuration,4)-learningC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                H=max(learningC(i+1:i+paramADuration,2));
                
                if (learningC(i+1,1)-H)<-paramASL
                    Ra(2)=-paramASL;
                end
                
                la(2)=la(2)+1;
            end
            
            %C
            if C(i,4) < Caverages(i) && volAverages(i)<paramAVolThreshold
                Ra(3)=learningC(i+paramADuration,4)-learningC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                L=min(learningC(i+1:i+paramADuration,3));
                
                if (-learningC(i+1,1)+L)<-paramASL
                    Ra(3)=-paramASL;
                end
                
                la(3)=la(3)+1;
            end
            
            %D
            if C(i,4) < Caverages(i) && volAverages(i)<paramAVolThreshold
                Ra(4)=-learningC(i+paramADuration,4)+learningC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                H=max(learningC(i+1:i+paramADuration,2));
                
                if (learningC(i+1,1)-H)<-paramASL
                    Ra(4)=-paramASL;
                end
                
                la(4)=la(4)+1;
            end
            
            pic = false;
        end
        
        for iT = 1:4
            
            sumRa(iT,i)=sumRa(iT,i-1) + Ra(iT);  %krzywa narastania kapita³u
            
            if sumRa(iT,i)>recordReturn(iT)
                recordReturn(iT)=sumRa(iT,i);
            end
            
            if sumRa(iT,i)-recordReturn(iT)<recordDrawdown(iT)
                recordDrawdown(iT)=sumRa(iT,i)-recordReturn(iT);  %obsuniecie maksymalne
            end
        end
        
    end
    for iT = 1:4
        %wyniki koñcowe
        sumReturn=sumRa(iT,lastCandle);
        Calmar=-sumReturn/recordDrawdown(iT);  %wskaznik Calmara
        if bests{iT,12}<sumReturn
            bests(iT,1:11) = {paramAVolLength hlAverageLength1 ema2Length hlAverageLength2 sumLength cAveragesLength openBorder closeBorder paramADuration paramAVolThreshold paramASL};
            bests(iT,13) = {Calmar};
            bests(iT,14) = {la(iT)};
            bests(iT,12) = {sumReturn};
            disp('');
            disp(['-> ' num2str(iT)]);
            disp(['>> zysk koncowy: ', num2str(bests{iT,12})]);
            disp(['Calmar: ', num2str(bests{iT,13})]);
            disp(['liczba otwarc: ', num2str(la(iT))]);
            disp(['mainLoopIter: ', num2str(mainLoopIter)]);
            disp(['parametry: ', num2str(cell2mat(bests(iT,1:11)))]);
        end
        clear sumReturn Calmar
    end
    clear sumRa la volLa recordDrawdown
end

for iT = 1:4
    disp('');
    disp(['-> ' num2str(iT)]);
    disp(['1stHalfSumReturn = ', num2str(bests{iT,12})]);
    disp(['Calmar: ', num2str(bests{iT,13})]);
    disp(['liczba otwarc: ', num2str(bests{iT,14})]);
end

cSizes = size(verificationC);
candlesCount = cSizes(1);
HL = verificationC(:,2) - verificationC(:,3);
sumReturn = zeros(1,4);
la=zeros(1,4); %liczba otwieranych pozycji
recordReturn=zeros(1,4);  %rekord zysku
recordDrawdown=zeros(1,4);  %rekord obsuniecia
pic = false;
sumRa=zeros(4,candlesCount);
Calmar = zeros(1,4);

for iT = 1:4
    [paramAVolLength hlAverageLength1 ema2Length hlAverageLength2 sumLength cAveragesLength openBorder closeBorder paramADuration paramAVolThreshold paramASL] = deal(bests{iT,1:11});
    MI = zeros(candlesCount,1);
    volAverages=zeros(1, candlesCount);
    kon=candlesCount-1-hlAverageLength2;
    pocz = max([paramAVolLength max([hlAverageLength1 hlAverageLength2])+ema2Length+sumLength cAveragesLength]);
    HLaverage1 = ema(HL,hlAverageLength1);
    HLaverage2 = ema(HL,hlAverageLength2);
    EMA1 = ema(HLaverage2(hlAverageLength2:end),ema2Length);
    p = min([size(EMA1,1) size(HLaverage1,1)]) - 1;
    EMA2 = HLaverage1(end-p:end) ./ EMA1(end-p:end);
    for i=pocz:kon
        volAverages(i) = mean(learningC(i-min(i-1,paramAVolLength):i,5))-learningC(i,5);
        MI(i) = sum(EMA2(i-sumLength:i));
    end
    Caverages = ema(C(:,4),cAveragesLength);
    
    lastCandle = kon - paramADuration;
    
    for i=pocz:lastCandle
        
        Ra=zeros(1,4);
        
        if pic == false && MI(i) > openBorder
            pic = true;
        end
        
        if pic == true && MI(i) < closeBorder
            switch(iT)
                case 1 %A
                    if C(i,4) > Caverages(i) && volAverages(i)<paramAVolThreshold
                        Ra(1)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                        L=min(verificationC(i+1:i+paramADuration,3));
                        
                        if (-verificationC(i+1,1)+L)<-paramASL
                            Ra(1)=-paramASL;
                        end
                        % MCC
                        if Ra(1)>0
                            confusionMatrix.TP(1) = confusionMatrix.TP(1) + 1;
                        else
                            confusionMatrix.FP(1) = confusionMatrix.FP(1) + 1;
                        end
                        la(1)=la(1)+1;
                    else
                        Ra(1)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                        L=min(verificationC(i+1:i+paramADuration,3));
                        
                        if (-verificationC(i+1,1)+L)<-paramASL
                            Ra(1)=-paramASL;
                        end
                        % MCC
                        if Ra(1)>0
                            confusionMatrix.FN(1) = confusionMatrix.FN(1) + 1;
                        else
                            confusionMatrix.TN(1) = confusionMatrix.TN(1) + 1;
                        end
                    end                    
                case 2 %B
                    if C(i,4) > Caverages(i) && volAverages(i)<paramAVolThreshold
                        Ra(2)=-verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                        H=max(verificationC(i+1:i+paramADuration,2));
                        
                        if (verificationC(i+1,1)-H)<-paramASL
                            Ra(2)=-paramASL;
                        end
                        % MCC
                        if Ra(2)>0
                            confusionMatrix.TP(2) = confusionMatrix.TP(2) + 1;
                        else
                            confusionMatrix.FP(2) = confusionMatrix.FP(2) + 1;
                        end
                        la(2)=la(2)+1;
                    else
                        Ra(2)=-verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                        H=max(verificationC(i+1:i+paramADuration,2));
                        
                        if (verificationC(i+1,1)-H)<-paramASL
                            Ra(2)=-paramASL;
                        end
                        % MCC
                        if Ra(2)>0
                            confusionMatrix.FN(2) = confusionMatrix.FN(2) + 1;
                        else
                            confusionMatrix.TN(2) = confusionMatrix.TN(2) + 1;
                        end
                    end                    
                case 3 %C
                    if C(i,4) < Caverages(i) && volAverages(i)<paramAVolThreshold
                        Ra(3)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                        L=min(verificationC(i+1:i+paramADuration,3));
                        
                        if (-verificationC(i+1,1)+L)<-paramASL
                            Ra(3)=-paramASL;
                        end
                        % MCC
                        if Ra(3)>0
                            confusionMatrix.TP(3) = confusionMatrix.TP(3) + 1;
                        else
                            confusionMatrix.FP(3) = confusionMatrix.FP(3) + 1;
                        end
                        la(3)=la(3)+1;
                    else
                        Ra(3)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                        L=min(verificationC(i+1:i+paramADuration,3));
                        
                        if (-verificationC(i+1,1)+L)<-paramASL
                            Ra(3)=-paramASL;
                        end
                        % MCC
                        if Ra(3)>0
                            confusionMatrix.FN(3) = confusionMatrix.FN(3) + 1;
                        else
                            confusionMatrix.TN(3) = confusionMatrix.TN(3) + 1;
                        end
                    end                    
                case 4 %D
                    if C(i,4) < Caverages(i) && volAverages(i)<paramAVolThreshold
                        Ra(4)=-verificationC(i+paramADuration,4)+verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                        H=max(verificationC(i+1:i+paramADuration,2));
                        
                        if (verificationC(i+1,1)-H)<-paramASL
                            Ra(4)=-paramASL;
                        end
                        % MCC
                        if Ra(4)>0
                            confusionMatrix.TP(4) = confusionMatrix.TP(4) + 1;
                        else
                            confusionMatrix.FP(4) = confusionMatrix.FP(4) + 1;
                        end
                        la(4)=la(4)+1;
                    else
                        Ra(4)=-verificationC(i+paramADuration,4)+verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                        H=max(verificationC(i+1:i+paramADuration,2));
                        
                        if (verificationC(i+1,1)-H)<-paramASL
                            Ra(4)=-paramASL;
                        end
                        % MCC
                        if Ra(4)>0
                            confusionMatrix.FN(4) = confusionMatrix.FN(4) + 1;
                        else
                            confusionMatrix.TN(4) = confusionMatrix.TN(4) + 1;
                        end
                    end
            end            
            pic = false;
        end
        
        sumRa(iT,i)=sumRa(iT,i-1) + Ra(iT);  %krzywa narastania kapita³u
        
        if sumRa(iT,i)>recordReturn(iT)
            recordReturn(iT)=sumRa(iT,i);
        end
        
        if sumRa(iT,i)-recordReturn(iT)<recordDrawdown(iT)
            recordDrawdown(iT)=sumRa(iT,i)-recordReturn(iT);  %obsuniecie maksymalne
        end
        
    end
    
    %wyniki koñcowe
    
    sumReturn(iT)=sumRa(iT,lastCandle);
    Calmar(iT)=-sumReturn(iT)/recordDrawdown(iT);  %wskaznik Calmara
    disp('');
    disp(['-> ' num2str(iT)]);
    disp(['2ndHalfSumReturn = ', num2str(sumReturn(iT))]);
    disp(['2ndHalfCalmar = ', num2str(Calmar(iT))]);
    disp(['2ndHalfLa: ', num2str(la(iT))]);
end
% MCC
[ CM, MCC ] = calculateMCC( confusionMatrix , 4)
% ZAPIS
fileID =fopen([file_name '_S4abcd.txt'],'w');
for iT = 1:4
    fprintf(fileID,['S4_' num2str(iT), '\n']);
    fprintf(fileID,['lerningBestReturn = ', num2str(bests{iT,11}), '\n']);
    fprintf(fileID,['lerningBestCalmar = ', num2str(bests{iT,12}), '\n']);
    fprintf(fileID,['lerningBestLa = ', num2str(bests{iT,13}), '\n']);
    fprintf(fileID,['testBestReturn = ', num2str(sumReturn(iT)), '\n']);
    fprintf(fileID,['testBestCalmar = ', num2str(Calmar(iT)), '\n']);
    fprintf(fileID,['testBestLa = ', num2str(la(iT)), '\n']);
    fprintf(fileID,['parametry = {', num2str(cell2mat(bests(iT,1:10))), '}\n']);
    fprintf(fileID,'\n\n');
end
fclose(fileID);
strat = {'_A','_B','_C','_D'};
for iT = 1:4
    hFig = figure(iT);
    set(hFig, 'Position', [200 200 640 480]);
    plot(sumRa(iT,sumRa(iT,:)~=0));
    title(['Zysk skumulowany - strategia: ', file_name, strat{iT}]);
    xlabel('Liczba Swiec');
    ylabel('Zysk');
    set(hFig, 'PaperPositionMode','auto')
    print(hFig,'-dpng', '-r0',[file_name strat{iT}])
end
% MCC
[ CM, MCC, P, R ] = calculateMCC( confusionMatrix, 4)
disp(['tElapsed ', num2str(toc(tStart))]);