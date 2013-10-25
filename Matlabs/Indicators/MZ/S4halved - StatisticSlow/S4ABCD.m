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

% bests(1:10) - najlepsze parametry pêtli, bests(11) - bestSumR,
%                      bests(12) - bestCalmar, bests(13) - bestLa
bests = cell(4,13);
bests(1:4,11) = {-1000};

paramAVolLength_min = 5;
paramAVolLength_step = 10;
paramAVolLength_max = 30;

minLength1_min = 2;
minLength1_step = 2;
minLength1_max = 30;

minLength2_min = 2;
minLength2_step = 2;
minLength2_max = 30;

maxLength_min = 2;
maxLength_step = 2;
maxLength_max = 30;

sumLength1_min = 2;
sumLength1_step = 2;
sumLength1_max = 30;

sumLength2_min = 2;
sumLength2_step = 2;
sumLength2_max = 30;

dMALength_min = 2;
dMALength_step = 2;
dMALength_max = 30;

paramADuration_min = 5;
paramADuration_step = 10;
paramADuration_max = 30;

paramAVolThreshold_min = 100;
paramAVolThreshold_step = -10;
paramAVolThreshold_max = 10;

paramASL_min = 8*spread;
paramASL_step = 3*spread;
paramASL_max = 20*spread;

paramAVolLength_Vector = paramAVolLength_min : paramAVolLength_step : paramAVolLength_max;
minLength1_Vector = minLength1_min : minLength1_step : minLength1_max;
minLength2_Vector = minLength2_min : minLength2_step : minLength2_max;
maxLength_Vector = maxLength_min : maxLength_step : maxLength_max;
sumLength1_Vector = sumLength1_min : sumLength1_step : sumLength1_max;
sumLength2_Vector = sumLength2_min : sumLength2_step : sumLength2_max;
dMALength_Vector = dMALength_min : dMALength_step : dMALength_max;
paramADuration_Vector = paramADuration_min : paramADuration_step : paramADuration_max;
paramAVolThreshold_Vector = paramAVolThreshold_min : paramAVolThreshold_step : paramAVolThreshold_max;
paramASL_Vector = paramASL_min : paramASL_step : paramASL_max;

cSizes = size(learningC);
candlesCount = cSizes(1);
sumReturn = 0;
Calmar = 0;

%g³ówne pêtle - parametry strategii
for mainLoopIter = 1:loopEnd
    
    m = size(paramAVolLength_Vector,2);
    paramAVolLength = paramAVolLength_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(minLength1_Vector,2);
    minLength1 = minLength1_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(minLength2_Vector,2);
    minLength2 = minLength2_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(maxLength_Vector,2);
    maxLength = maxLength_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(sumLength1_Vector,2);
    sumLength1 = sumLength1_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(sumLength2_Vector,2);
    sumLength2 = sumLength2_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(dMALength_Vector,2);
    dMALength = dMALength_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(paramADuration_Vector,2);
    paramADuration = paramADuration_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(paramAVolThreshold_Vector,2);
    paramAVolThreshold = paramAVolThreshold_Vector(round(1 + (m-1)*rand(1,1)));
    
    m = size(paramASL_Vector,2);
    paramASL = paramASL_Vector(round(1 + (m-1)*rand(1,1)));
    
    volAverages=zeros(1, candlesCount);
    maxes=zeros(candlesCount,1);
    mins1=zeros(candlesCount,1);
    mins2=zeros(candlesCount,1);
    K=zeros(candlesCount,1);
    D=zeros(candlesCount,1);
    kon=candlesCount-1;
    pocz = max([paramAVolLength maxLength minLength1 minLength2 sumLength1 sumLength2 dMALength]);
    for i=pocz:kon
        volAverages(i) = mean(learningC(i-min(i-1,paramAVolLength):i,5))-learningC(i,5);
        maxes(i) = max(learningC(i-min(i-1,maxLength):i-1,2));
        mins1(i) = min(learningC(i-min(i-1,minLength1):i-1,3));
        mins2(i) = min(learningC(i-min(i-1,minLength2):i-1,3));
        K(i) = 100 * (sum(learningC(i-min(i-1,sumLength1):i,4)-mins1(i-min(i-1,sumLength1):i)) / sum(maxes(i-min(i-1,sumLength2):i)-mins2(i-min(i-1,sumLength2):i)));
        D(i) = sum(K(i-min(i-1,dMALength-1):i)) / min(i-1,dMALength);
    end
    sumRa=zeros(4,candlesCount);
    la=zeros(1,4); %liczba otwieranych pozycji
    
    lastCandle = kon - paramADuration;
    recordReturn=zeros(1,4);  %rekord zysku
    recordDrawdown=zeros(1,4);  %rekord obsuniecia
    volLa=zeros(1,4);
    
    for i=pocz:lastCandle
        
        Ra=zeros(1,4);
        % A
        if K(i-1) < D(i-1) && K(i) >= D(i)
            if volAverages(i)<paramAVolThreshold
                Ra(1)=learningC(i+paramADuration,4)-learningC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                L=min(learningC(i+1:i+paramADuration,3));
                
                if (-learningC(i+1,1)+L)<-paramASL
                    Ra(1)=-paramASL;
                end
                la(1)=la(1)+1;
            end
        end
        
        % B
        if K(i-1) < D(i-1) && K(i) >= D(i)
            if volAverages(i)<paramAVolThreshold
                Ra(2)= - learningC(i+paramADuration,4)+learningC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                H=max(learningC(i+1:i+paramADuration,2));
                
                if (learningC(i+1,1)-H)<-paramASL
                    Ra(2)=-paramASL;
                end
                la(2)=la(2)+1;
            end
        end
        
        % C
        if K(i-1) > D(i-1) && K(i) <= D(i)
            if volAverages(i)<paramAVolThreshold
                Ra(3)=learningC(i+paramADuration,4)-learningC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                L=min(learningC(i+1:i+paramADuration,3));
                
                if (-learningC(i+1,1)+L)<-paramASL
                    Ra(3)=-paramASL;
                end
                la(3)=la(3)+1;
            end
        end
        
        % D
        if K(i-1) > D(i-1) && K(i) <= D(i)
            if volAverages(i)<paramAVolThreshold
                Ra(4)=-learningC(i+paramADuration,4)+learningC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                H=max(learningC(i+1:i+paramADuration,2));
                
                if (learningC(i+1,1)-H)<-paramASL
                    Ra(4)=-paramASL;
                end
                la(4)=la(4)+1;
            end
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
        if bests{iT,11}<sumReturn
            bests(iT,1:10) = {paramAVolLength minLength1 minLength2 maxLength sumLength1 sumLength2 dMALength paramADuration paramAVolThreshold paramASL};
            bests(iT,12) = {Calmar};
            bests(iT,13) = {la(iT)};
            bests(iT,11) = {sumReturn};
            disp('');
            disp(['-> ' num2str(iT)]);
            disp(['>> zysk koncowy: ', num2str(bests{iT,11})]);
            disp(['Calmar: ', num2str(bests{iT,12})]);
            disp(['liczba otwarc: ', num2str(bests{iT,13})]);
            disp(['parametry: ', num2str(cell2mat(bests(iT,1:10)))]);            
            disp(['mainLoopIter: ', num2str(mainLoopIter)]);
        end
        clear sumReturn Calmar
    end
end
for iT = 1:4
    disp('');
    disp(['-> ' num2str(iT)]);
    disp(['1stHalfSumReturn = ', num2str(bests{iT,11})]);
    disp(['Calmar: ', num2str(bests{iT,12})]);
    disp(['liczba otwaræ: ', num2str(bests{iT,13})]);
end

cSizes = size(verificationC);
candlesCount = cSizes(1);
sumRa=zeros(4,candlesCount);
la=zeros(1,4); %liczba otwieranych pozycji
recordReturn=zeros(1,4);  %rekord zysku
recordDrawdown=zeros(1,4);  %rekord obsuniecia
sumReturn = zeros(1,4);
Calmar = zeros(1,4);

for iT = 1:4
    [paramAVolLength minLength1 minLength2 maxLength sumLength1 sumLength2 dMALength paramADuration paramAVolThreshold paramASL] = deal(bests{iT,1:10});
    volAverages=zeros(1, candlesCount);
    maxes=zeros(candlesCount,1);
    mins1=zeros(candlesCount,1);
    mins2=zeros(candlesCount,1);
    K=zeros(candlesCount,1);
    D=zeros(candlesCount,1);
    kon=candlesCount-1;
    pocz = max([paramAVolLength maxLength minLength1 minLength2 sumLength1 sumLength2 dMALength]);
    for i=pocz:kon
        volAverages(i) = mean(verificationC(i-min(i-1,paramAVolLength):i,5))-verificationC(i,5);
        maxes(i) = max(verificationC(i-min(i-1,maxLength):i-1,2));
        mins1(i) = min(verificationC(i-min(i-1,minLength1):i-1,3));
        mins2(i) = min(verificationC(i-min(i-1,minLength2):i-1,3));
        K(i) = 100 * (sum(verificationC(i-min(i-1,sumLength1):i,4)-mins1(i-min(i-1,sumLength1):i)) / sum(maxes(i-min(i-1,sumLength2):i)-mins2(i-min(i-1,sumLength2):i)));
        D(i) = sum(K(i-min(i-1,dMALength-1):i)) / min(i-1,dMALength);
    end
    
    lastCandle = kon - paramADuration;
    
    for i=pocz:lastCandle
        
        Ra=zeros(1,4);
        
        switch(iT)
            case 1 %A
                if K(i-1) < D(i-1) && K(i) >= D(i) && volAverages(i)<paramAVolThreshold
                    Ra(iT)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                    L=min(verificationC(i+1:i+paramADuration,3));
                    if (-verificationC(i+1,1)+L)<-paramASL
                        Ra(iT)=-paramASL;
                    end
                    % MCC
                    if Ra(iT)>0
                        confusionMatrix.TP(iT) = confusionMatrix.TP(iT) + 1;
                    else
                        confusionMatrix.FP(iT) = confusionMatrix.FP(iT) + 1;
                    end
                    la(iT)=la(iT)+1;
                else
                    Ra(iT)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                    L=min(verificationC(i+1:i+paramADuration,3));
                    if (-verificationC(i+1,1)+L)<-paramASL
                        Ra(iT)=-paramASL;
                    end
                    % MCC
                    if Ra(iT)>0
                        confusionMatrix.FN(iT) = confusionMatrix.FN(iT) + 1;
                    else
                        confusionMatrix.TN(iT) = confusionMatrix.TN(iT) + 1;
                    end
                end
            case 2 %B
                if K(i-1) < D(i-1) && K(i) >= D(i) && volAverages(i)<paramAVolThreshold
                    Ra(iT)= - verificationC(i+paramADuration,4)+verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                    L=max(verificationC(i+1:i+paramADuration,2));
                    if (verificationC(i+1,1)-H)<-paramASL
                        Ra(iT)=-paramASL;
                    end
                    % MCC
                    if Ra(iT)>0
                        confusionMatrix.TP(iT) = confusionMatrix.TP(iT) + 1;
                    else
                        confusionMatrix.FP(iT) = confusionMatrix.FP(iT) + 1;
                    end
                    la(iT)=la(iT)+1;
                else
                    Ra(iT)= - verificationC(i+paramADuration,4)+verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                    L=max(verificationC(i+1:i+paramADuration,2));
                    if (verificationC(i+1,1)-H)<-paramASL
                        Ra(iT)=-paramASL;
                    end
                    % MCC
                    if Ra(iT)>0
                        confusionMatrix.FN(iT) = confusionMatrix.FN(iT) + 1;
                    else
                        confusionMatrix.TN(iT) = confusionMatrix.TN(iT) + 1;
                    end
                end
            case 3 %C
                if K(i-1) > D(i-1) && K(i) <= D(i) && volAverages(i)<paramAVolThreshold
                    Ra(iT)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                    L=min(verificationC(i+1:i+paramADuration,3));
                    if (-verificationC(i+1,1)+L)<-paramASL
                        Ra(iT)=-paramASL;
                    end
                    % MCC
                    if Ra(iT)>0
                        confusionMatrix.TP(iT) = confusionMatrix.TP(iT) + 1;
                    else
                        confusionMatrix.FP(iT) = confusionMatrix.FP(iT) + 1;
                    end
                    la(iT)=la(iT)+1;
                else
                    Ra(iT)=verificationC(i+paramADuration,4)-verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                    L=min(verificationC(i+1:i+paramADuration,3));
                    if (-verificationC(i+1,1)+L)<-paramASL
                        Ra(iT)=-paramASL;
                    end
                    % MCC
                    if Ra(iT)>0
                        confusionMatrix.FN(iT) = confusionMatrix.FN(iT) + 1;
                    else
                        confusionMatrix.TN(iT) = confusionMatrix.TN(iT) + 1;
                    end
                end
            case 4 %D
                if K(i-1) > D(i-1) && K(i) <= D(i) && volAverages(i)<paramAVolThreshold
                    Ra(iT)=-verificationC(i+paramADuration,4)+verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                    H=max(verificationC(i+1:i+paramADuration,2));
                    if (verificationC(i+1,1)-H)<-paramASL
                        Ra(iT)=-paramASL;
                    end
                    % MCC
                    if Ra(iT)>0
                        confusionMatrix.TP(iT) = confusionMatrix.TP(iT) + 1;
                    else
                        confusionMatrix.FP(iT) = confusionMatrix.FP(iT) + 1;
                    end
                    la(iT)=la(iT)+1;
                else
                    Ra(iT)=-verificationC(i+paramADuration,4)+verificationC(i+1,1)-spread; %zysk z i-tej pozycji long zamykanej na zamkniêciu po paramADuration kroku
                    H=max(verificationC(i+1:i+paramADuration,2));
                    if (verificationC(i+1,1)-H)<-paramASL
                        Ra(iT)=-paramASL;
                    end
                    % MCC
                    if Ra(iT)>0
                        confusionMatrix.FN(iT) = confusionMatrix.FN(iT) + 1;
                    else
                        confusionMatrix.TN(iT) = confusionMatrix.TN(iT) + 1;
                    end
                end
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