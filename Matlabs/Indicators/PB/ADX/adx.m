%   double pdm,mdm,tr;
%   double price_high,price_low;
%   int    starti,i,counted_bars=IndicatorCounted();
%//----
%    PlusSdiBuffer[i+1]=0;
%    MinusSdiBuffer[i+1]=0;
%    if(counted_bars>=i) i=Bars-counted_bars-1;
%    starti=i;
%//----


fid = fopen('EURUSD60.csv','r');
Data = textscan(fid, '%f %f %f %f %f %s', 'delimiter',',', 'CollectOutput',true);
C = Data{1};
Daty = Data{2}; 
fclose(fid);


adxPeriod=14;
adxBegin=53;
adxEnd=200;
plusSdiBuffer=zeros(1, adxEnd);
minusSdiBuffer=zeros(1, adxEnd);
adxBegin = adxBegin - adxPeriod;
if adxBegin<1
    adxBegin=1;
end
for i=adxBegin:adxEnd
    
    priceLow = C(i-1, 3);
    priceHigh = C(i-1, 2);
    higherPriceDiff = priceHigh - C(i-2, 2);
    lowerPriceDiff = C(i-2, 3) - priceLow;
    if(higherPriceDiff<0) 
        higherPriceDiff=0;  % +DM
    end
    if lowerPriceDiff<0
        lowerPriceDiff=0;  % -DM
    end
    if higherPriceDiff==lowerPriceDiff
        higherPriceDiff=0; 
        lowerPriceDiff=0;
    else
        if higherPriceDiff<lowerPriceDiff 
            higherPriceDiff=0;
        else
            if lowerPriceDiff<higherPriceDiff
                lowerPriceDiff=0;
            end
        end
    end
    candleRange=abs(priceHigh-priceLow);
    candleRangeHigh=abs(priceHigh-C(i-2, 4));
    candleRangeLow=abs(priceLow-C(i-2, 4));
    trueRange=max(candleRange,candleRangeHigh);
    trueRange=max(trueRange, candleRangeLow);
    %       counting plus/minus direction
    if trueRange==0 
        plusSdiBuffer(i)=0;
        minusSdiBuffer(i)=0;
    else
        plusSdiBuffer(i)=100.0*higherPriceDiff/trueRange; 
        minusSdiBuffer(i)=100.0*lowerPriceDiff/trueRange;
    end
%     if i<=AdxBegin+AdxPeriod 
%         continue;
%     end
    
end

   %apply EMA to +DI
   plusDiBuffer=ema(plusSdiBuffer, adxPeriod);
   minusDiBuffer=ema(minusSdiBuffer, adxPeriod);
   diffBuffer=zeros(1, adxEnd);
   for x=1:length(plusDiBuffer)
       if plusDiBuffer(x)>minusDiBuffer(x)
        diffBuffer(x)=1;
       else
        diffBuffer(x)=0;
       end
   end
   tempBuffer=zeros(1, adxEnd);
   for i=adxBegin:adxEnd
	div=abs(plusDiBuffer(i)+minusDiBuffer(i));
    if div==0.00 || isnan(plusDiBuffer(i)) 
        tempBuffer(i)=0;
    else
        tempBuffer(i)=100*(abs(plusDiBuffer(i)-minusDiBuffer(i))/div);
    end
   end
    % //---- ADX is exponential moving average on DX
    adxBuffer=ema(tempBuffer, adxPeriod);
   x=adxBegin:adxEnd;
   figure(1);
   plot(minusDiBuffer, 'r');
   hold on;
   plot(plusDiBuffer, 'g');
   hold on;
   plot(adxBuffer, 'b');
   
%    figure(2);
%    plot(DiffBuffer)
