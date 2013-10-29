personNumber = 1;
eurusd221012;
spread = 0.0002;
personalFileHandle = fopen('tewiROCaAB.csv', 'r');
header = textscan(personalFileHandle, '%s;%s;%s;%s;%s;%s;%s;%s\n');
testSize = 100;
scanPeriodCount = 31;%tylko do 100 œwiec mo¿na testowaæ 34 okresy, do 200 - 33
returns3d = zeros((scanPeriodCount + 3)* 100,testSize, scanPeriodCount);
returns2d = zeros((scanPeriodCount + 3)* 100,testSize);
WYN = [];
wynKON = 0;
for i =1:scanPeriodCount
    Cc=textscan(personalFileHandle, '%d;%f;%d;%d;%d;%f;%f;%d\n');
    pocz = cell2mat(Cc(1));
    kon = pocz + testSize;
    zyl = cell2mat(Cc(2));
    dur = cell2mat(Cc(3));
    vt = cell2mat(Cc(4));
    vl = cell2mat(Cc(5));
    bff = cell2mat(Cc(6));
    SL = cell2mat(Cc(7));
    op = cell2mat(Cc(8));
    [ Sum, Calmar, iL, returns] = ROCa( C, pocz, kon, spread,...
    dur,vt,vl,bff,SL,op);
    wynKON(end+1) = wynKON(end) + Sum;
	if i>1
        returns = returns + WYN(end);
    end
    WYN = [WYN returns];
end
fclose(personalFileHandle);

wynKON(end)
[ Calmar ] = obliczCalmara( WYN )
plot(wynKON)
figure
plot(WYN)

% returns2d = sum (returns3d, 3);
% for i=1:kon
%     for j=1:testSize
%         returns2d(i,j)= returns2d(i,j) / nnz(returns3d(i,j,:));
%     end
% end
% returns2d(isnan(returns2d)) = 0;
% cumulativeReturns = zeros((scanPeriodCount + 3)* 100,testSize);
% for j=1:testSize
%     cumulativeReturns(1,j)= returns2d(1,j);
% end
% for i=2:kon
%     for j=1:testSize
%         cumulativeReturns(i,j)= cumulativeReturns(i-1,j) + returns2d(i,j);
%     end
% end
% cumulativeReturnsPerCandle = cumulativeReturns;
% for i=1:kon
%     for j=1:testSize
%         cumulativeReturnsPerCandle(i,j)= cumulativeReturnsPerCandle(i,j)/j;
%     end
% end
% 
% figure(personNumber);
% mesh(cumulativeReturns);
% personNumber = personNumber + 1;
% figure(personNumber);
% mesh(cumulativeReturnsPerCandle);
% personNumber = personNumber + 1;