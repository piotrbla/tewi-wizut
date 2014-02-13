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


AdxPeriod=14;
AdxBegin=3;
AdxEnd=200;
PlusSdiBuffer=zeros(1, AdxEnd);
MinusSdiBuffer=zeros(1, AdxEnd);
for i=AdxBegin:AdxEnd
    
    price_low = C(i-1, 3);
    price_high = C(i-1, 2);
    pdm = price_high - C(i-2, 2);
    mdm = C(i-2, 3) - price_low;
    if(pdm<0) 
        pdm=0;  % +DM
    end
    if mdm<0
        mdm=0;  % -DM
    end
    if pdm==mdm
        pdm=0; 
        mdm=0;
    else
        if pdm<mdm 
            pdm=0;
        else
            if mdm<pdm
                mdm=0;
            end
        end
    end
    num1=abs(price_high-price_low);
    num2=abs(price_high-C(i-2, 4));
    num3=abs(price_low-C(i-2, 4));
    tr=max(num1,num2);
    tr=max(tr, num3);
    %       counting plus/minus direction
    if tr==0 
        PlusSdiBuffer(i)=0;
        MinusSdiBuffer(i)=0;
    else
        PlusSdiBuffer(i)=100.0*pdm/tr; 
        MinusSdiBuffer(i)=100.0*mdm/tr;
    end
%     if i<=AdxBegin+AdxPeriod 
%         continue;
%     end
    
end

   %apply EMA to +DI
   PlusDiBuffer=ema(PlusSdiBuffer, AdxPeriod);
   MinusDiBuffer=ema(MinusSdiBuffer, AdxPeriod);
   DiffBuffer=zeros(1, AdxEnd);
   for x=1:length(PlusDiBuffer)
       if PlusDiBuffer(x)>MinusDiBuffer(x)
        DiffBuffer(x)=1;
       else
        DiffBuffer(x)=0;
       end
   end
   TempBuffer=zeros(1, AdxEnd);
   for i=AdxBegin:AdxEnd
	div=abs(PlusDiBuffer(i)+MinusDiBuffer(i));
    if div==0.00 || isnan(PlusDiBuffer(i)) 
        TempBuffer(i)=0;
    else
        TempBuffer(i)=100*(abs(PlusDiBuffer(i)-MinusDiBuffer(i))/div);
    end
   end
    % //---- ADX is exponential moving average on DX
    ADXBuffer=ema(TempBuffer, AdxPeriod);
   x=AdxBegin:AdxEnd;
   figure(1);
   plot(MinusDiBuffer, 'r');
   hold on;
   plot(PlusDiBuffer, 'g');
   hold on;
   plot(ADXBuffer, 'b');
   
%    figure(2);
%    plot(DiffBuffer)
