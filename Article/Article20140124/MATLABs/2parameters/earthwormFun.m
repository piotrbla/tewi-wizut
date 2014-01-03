function [ sumReturn, Calmar, l_long, l_short ] = earthwormFun( C, spread, pocz, kon, p1, p2, Daty, zapis )
%earthworm1 (C) Antoni Wili�ski 2013
%- prosta strategia otwierania pozycji przemienniue kr�tkich i
%dlugich
global name;

if zapis
    fileID =fopen(['log' name '.txt.'],'w');
end

ldl=0; %liczba otwar� long
lds=0; %liczba otwar� sh

ll=0;
zysk=0;

l=0; %znacznik otwarcia pozycji d�ugiej
s=0;  %kr�tkiej
pocz = pocz+p1+1;
sumz = zeros(1,pocz);

for i=pocz:kon
    lts=0; %licznik warunk�w zgodnosci z trendem spadkowym
    z=0;
    for j=i-p1:i-1
        if C(j,4)>C(j+1,4)
            lts=lts+1;
        end
    end
    if lts>p1/2+p2
        if s==1
            spread=0;
        else
            spread=0.0002;
        end
        lds=lds+1;
        z=C(i,4)-C(i+1,4)-spread;
        s=1;
        l=0;
        if zapis
            fprintf(fileID, 'OTWARCIE Short:\t\t %s\t%0.5f\t%0.5f\n', Daty{i}, z, C(i,4));
        end
    end
    if lts<p1/2-p2
        if l==1
            spread=0;
        else
            spread=0.0002;
        end
        ldl=ldl+1;
        z=-C(i,4)+C(i+1,4)-spread;
        l=1;
        s=0;
        if zapis
            fprintf(fileID, 'OTWARCIE  LONG:\t\t %s\t%0.5f\t%0.5f\n', Daty{i}, z, C(i,4));
        end
    end
    sumz(i)=sumz(i-1)+z; 
end
l_long = ldl;
l_short = lds;
sumReturn = sumz(end)
Calmar = obliczCalmara(sumz);


if zapis
    fclose(fileID);
    figure;
    plot(sumz)
end
end


