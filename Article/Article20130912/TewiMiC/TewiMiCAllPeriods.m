personNumber = 1;
for personInitials ={'AB'};%,'KB','MZ'}
%for personInitials =strsplit('AB', ';')
    personalFileName = cell2mat(strcat('tewiMiC', personInitials, '.csv'));
    personalFileHandle = fopen(personalFileName, 'r');
    header = textscan(personalFileHandle, '%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n');
    testSize = 401;
    scanPeriodCount = 31;%tylko do 100 œwiec mo¿na testowaæ 34 okresy, do 200 - 33
    returns3d = zeros((scanPeriodCount + 3)* 100,testSize, scanPeriodCount);
    returns2d = zeros((scanPeriodCount + 3)* 100,testSize);
    calmars3d = zeros(testSize,testSize, scanPeriodCount);
    for i =1:scanPeriodCount
        C=textscan(personalFileHandle, '%d;%f;%f;%d;%d;%d;%f;%f;%d;%d;%d;%d;%f;%f\n');
        pocz = cell2mat(C(1));
        kon = pocz + testSize;
        zyl = cell2mat(C(2));
        b = cell2mat(C(3));
        wstp = cell2mat(C(4));
        wstk = cell2mat(C(5));
        lkr = cell2mat(C(6));
        SL = cell2mat(C(7));
        TP = cell2mat(C(8));
        op = cell2mat(C(9));
        bvol = cell2mat(C(10));
        vwst = cell2mat(C(11));
        ll3 = cell2mat(C(12));
        bawe = cell2mat(C(13));
        bcawe = cell2mat(C(14));
        returns= TewiMiCOnePeriodOneParamSet(pocz, kon, b, wstp, wstk, lkr, SL, TP, op, bvol, vwst, ll3, bawe, bcawe);
        returns3d(1:kon,:,i)= returns;
        %calmars3d do wyliczenia; 
        %tu powinniœmy zwróciæ macierz
        %return dla poszczególnych okresów testowych - 400 kolumn x 400
        %wierszy - lewy dolny róg wype³niony zerami
    end
    fclose(personalFileHandle);

    returns2d = sum (returns3d, 3);
    for i=1:kon
        for j=1:testSize
            returns2d(i,j)= returns2d(i,j) / nnz(returns3d(i,j,:));
            %returns2d(i,j)=  nnz(returns3d(i,j,:)); %mo¿na zobaczyæ jak
            %wyglada nachodzenie siê okresów
        end
    end
    returns2d(isnan(returns2d)) = 0; 
    cumulativeReturns = zeros((scanPeriodCount + 3)* 100,testSize);
    for j=1:testSize
    	cumulativeReturns(1,j)= returns2d(1,j);
    end
    for i=2:kon
        for j=1:testSize
            cumulativeReturns(i,j)= cumulativeReturns(i-1,j) + returns2d(i,j);
        end
    end
    cumulativeReturnsPerCandle = cumulativeReturns;
    for i=1:kon
        for j=1:testSize
            cumulativeReturnsPerCandle(i,j)= cumulativeReturnsPerCandle(i,j)/j;
        end
    end
    %tu liczymy calmars3d i kumulujemy zyski
%     actualRecord = zysl(i);
%     if actualRecord >returnRecord
%         returnRecord = actualRecord;
%     end
%     actualDrawdown = actualRecord - returnRecord;
%     if actualDrawdown<worstDrawdown
%         worstDrawdown = actualDrawdown;
%     end
%     actualCalmar = actualRecord / - worstDrawdown;
%     actualStart = i-pocz+1;
%     for x=actualStart:testSize
%         returns(x,actualStart)=actualRecord ;
%         calmars(x,actualStart)=actualCalmar;%interesuje nas tylko calmars(i,i)
%     end

    Tab =[];
    for i=10:10:size(cumulativeReturns,2)
        Calmar = obliczCalmara( cumulativeReturns(:,i) );
        [cumulativeReturns(end,i) Calmar];
        Tab(end+1,:) = [i,cumulativeReturns(end,i),Calmar];
    end
    MatrixToLatex( 'Wyniki_MiC.txt', Tab )
    
    hFig = figure(personNumber);
    mesh(cumulativeReturns);
    xlabel('length of test period');
    ylabel('candles count');
    zlabel('cumulative return');
    SaveGraph( hFig, 'mic' )
    
    personNumber = personNumber + 1;
    hFig = figure(personNumber);
    mesh(cumulativeReturnsPerCandle);
    xlabel('length of test period');
    ylabel('candles count');
    zlabel('cumulative return per candle');
    SaveGraph( hFig, 'mic_percandle' )
    
    
    personNumber = personNumber + 1;
    hFig = figure(personNumber);
    plot(cumulativeReturns(end,:));
    xlabel('length of test period');
    ylabel('cumulative return');
    SaveGraph( hFig, 'mic_end' )
    
    personNumber = personNumber + 1;
    hFig = figure(personNumber);
    plot(cumulativeReturnsPerCandle(end,:));
    xlabel('length of test period');
    ylabel('cumulative return per candle');
    SaveGraph( hFig, 'mic_percandle_end' )
    
    personNumber = personNumber + 1;
    hFig = figure(personNumber);
    plot(cumulativeReturns(:,100));
    xlabel('candles count');
    ylabel('cumulative return');
    SaveGraph( hFig, 'mic_100' )
    
%     personNumber = personNumber + 1;
%     figure(personNumber);
%     plot(cumulativeReturnsPerCandle(:,100));
    
    
    personNumber = personNumber + 1;
end