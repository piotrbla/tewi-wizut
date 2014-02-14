clc
close
clear


fid = fopen('EURUSD60.csv','r');
Data = textscan(fid, '%f %f %f %f %f %s', 'delimiter',',', 'CollectOutput',true);
C = Data{1};
Daty = Data{2}; 
fclose(fid);

lastPosState = 0;
lastPosLearnState = 0;
lastOpenPrice=0;
lastOpenPriceTest=0;
for kk=[1:51]
%for kk=[1:15]
    [returnTest, lastPosState, lastPosLearnState, lastOpenPrice, lastOpenPriceTest] = startEarthworm( C, Daty, kk, lastPosState, lastPosLearnState, lastOpenPrice, lastOpenPriceTest);
    returns(kk)= returnTest;
    returnSum(kk) = sum(returns(1:kk));
end
figure(1);
plot(returns);
figure(2);
plot(returnSum);
zlacz_wyniki;