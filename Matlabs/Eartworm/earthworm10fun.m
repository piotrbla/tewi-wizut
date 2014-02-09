function [ zysk, Calmar, sumz, LongShort, lastPosState, lastOpenPrice] = ...
    earthworm10fun( C, Daty, spread, pocz, kon, p1, p2, p3, p4, p5StopLoss, firstPosState, lastOpenPrice, czyTestowy)%p6VolumeBarrier , p7VolumeBuffer )

ldl=0; %liczba otwaræ long
lds=0; %liczba otwaræ sh
lkl=0; %liczba kontunuacji long
lks=0; %liczba kontynuacji short

sumz = zeros(1,kon);
constShort = -1;
constLong = 1;
constNone = 0;
posState = firstPosState;
constSpread = spread;
openPrice = lastOpenPrice;
for i=pocz:kon%  p1+1+pocz:kon %m(1)-30000
    lts=0; %licznik warunków zgodnosci z trendem spadkowym
    volumeDownCount=0; %licznik warunków zgodnosci z trendem spadkowym
    z=0;
    pos=0; %znacznik otwarcia pozycji, jakiejkolwiek
    if i<=p1+1 %|| i<=p6VolumeBarrier + 1
        continue
    end
    for j=i-p1:i-1
        if C(j-1,4)>C(j,4)
            lts=lts+1;
        end
    end
%     for j=i-p6VolumeBarrier :i-1
%         if C(j-1,5)>C(j,5)
%             volumeDownCount = volumeDownCount +1;
%         end
%     end
%     if volumeDownCount >p1/2 + p7VolumeBuffer
%         isVolumeEarthwormDown = true;
%     else
%         isVolumeEarthwormDown = false;
%     end
        
    if lts>p1/2+p2 %&& isVolumeEarthwormDown
        lds=lds+1;
        if posState~=constShort
            z=C(i,1)-C(i,4);
            z=z-constSpread;
            openPrice = C(i,1);
            if czyTestowy info = sprintf('%d : %s : lts = %d #1 otwarcie krotkiej przy %0.5f', i, Daty{i}, lts, openPrice); disp(info); end
        else
            z=C(i-1,4)-C(i,4);
        end
        pos=1;
        posState = constShort;
    end
    if lts<p1/2-p2 %&& isVolumeEarthwormDown
        ldl=ldl+1;
        if posState~=constLong
            z=-C(i,1)+C(i,4);
            z=z-constSpread;
            openPrice = C(i,1);
            if czyTestowy info = sprintf('%d : %s : lts = %d #2 otwarcie dlugiej przy %0.5f', i, Daty{i}, lts, openPrice); disp(info); end
        else
            z=-C(i-1,4)+C(i,4);
        end
        pos=1;
        posState = constLong;
    end
    
    if pos==0 && posState==constLong 
        z=-C(i-1,4)+C(i,4);
        lkl=lkl+1;
    end
    if pos==0 && posState==constShort 
        z=C(i-1,4)-C(i,4);
        lks=lks+1;
    end

    if posState ~= constNone
        if posState == constLong
            if openPrice > C(i, 3) + p5StopLoss %|| ~isVolumeEarthwormInBufferZone %%|| C(i,5)-C(i-1,5)<-500
                z = -p5StopLoss + (openPrice - C(i-1, 4));
                posState = constNone;
                pos=1;
                if czyTestowy info = sprintf('%d : %s : lts = %d #3 SL dlugiej przy %0.5f', i, Daty{i}, lts, C(i, 3)); disp(info); end
            end
        end
        if posState == constShort
            if openPrice < C(i, 3) - p5StopLoss %|| ~isVolumeEarthwormInBufferZone %%|| C(i,5)-C(i-1,5)<-500
                z = -p5StopLoss - (openPrice - C(i-1, 4));
                posState = constNone;
                pos=1;
                if czyTestowy info = sprintf('%d : %s : lts = %d #4 SL krotkiej przy %0.5f', i, Daty{i}, lts, C(i, 3)); disp(info); end
            end
        end
    end

    sumz(i)=sumz(i-1)+z;
  
    if pos==0 && i>p3+1 && sumz(i-1)-sumz(i-p3-1)<p4
        posState=-posState;
        sumz(i)=sumz(i)- z-constSpread;
        if posState~=constShort
            z=C(i,1)-C(i,4);
            if czyTestowy info = sprintf('%d : %s : lts = %d #5 zamkniecie krotkiej przy %0.5f', i, Daty{i}, lts, C(i, 1)); disp(info); end
        end
        if posState~=constLong
            z=-C(i,1)+C(i,4);
            if czyTestowy info = sprintf('%d : %s : lts = %d #6 zamkniecie dlugiej przy %0.5f', i, Daty{i}, lts, C(i, 1)); disp(info); end
        end
        sumz(i)=sumz(i)+z;%tak powinno byæ, poniewa¿ jesteœmy na pocz¹tku œwiecy i-tej, 
        %tu podejmujemy decyzje, a zysk liczymy za i-t¹ œwiecê
        openPrice = C(i,1); 
    end
    
end
lastPosState=posState;
lastOpenPrice= openPrice;

zysk = sumz(kon);
Calmar = obliczCalmara(sumz);

LongShort= [ldl lds lkl lks];


end

