function [profit, Calmar, sumR, iL, iS, MACD, SignalLine] = decision( C, spread, P1, P2, P3)

pocz = P1+2;
kon = size(C,1)-1;
iL = 0; % przekroczenie 0 w górê - kupno (L)
iS = 0; % przekroczenie 0 w dó³ - sprzeda¿ (S)
sumR = zeros(1,size(C,1));
R = zeros(1,size(C,1));
Error=0.00001;

recordReturn = 0;  % rekord zysku
recordDrawdown = 0;  % rekord obsuniecia
LastPos = 0;    % zmienna do przechowywania wartosci na otwarciu ostatniej pozycji

[MACD SignalLine] = macd(C(pocz-P1:pocz+1,4),P1,P2,P3);
for i=pocz:kon
    if abs(MACD(end)-SignalLine(end))<Error   % przeciêcie MACD z lini¹ sygna³ow¹
        if MACD(end-1)<SignalLine(end-1)  % przeciêcie oddolne = BUY
            if iL+iS>0
                R(i) = -C(i+1,4)+LastPos-spread;   % zamkniêcie S
            end
            LastPos = C(i+1,1);   % otworzenie L
            iL = iL + 1;
        elseif MACD(end-1)>SignalLine(end-1)  % przeciêcie odgórne = SELL
            if iL+iS>0
                R(i) = C(i+1,4)-LastPos-spread;  % zamkniêcie L
            end
            LastPos = C(i+1,1);   % otworzenie S
            iS = iS + 1;
        end
    end
    sumR(i) = sum(R(pocz:i));
  
    if sumR(i)>recordReturn
        recordReturn=sumR(i);
    end
    
    if sumR(i)-recordReturn<recordDrawdown
        recordDrawdown=sumR(i)-recordReturn;  
    end
    
    [temp_macd temp_signal] = macd(C(i-P1:i,4),P1,P2,P3);
    MACD=vertcat(MACD, temp_macd(end)); 
    SignalLine=vertcat(SignalLine, temp_signal(end));
end
Calmar=-sumR(kon)/recordDrawdown;
profit = sumR(kon);

end