%Tomasz Nyczaj 2013 substrategia 1.
%Cena powy¿ej RR2 --> pozycja d³uga

%Dane:
eurusd1h020313;
size(C)

%Inicjalizacja zmiennych, aby nie powiêkszaæ macierzy w pêtlach
R1=zeros(1,6000);
R1a=zeros(1,6000);
R1b=zeros(1,6000);
vol1=zeros(1,6000);
v1=zeros(1,6000);
P=zeros(1,6000);
RR1=zeros(1,6000);
RR2=zeros(1,6000);
SS1=zeros(1,6000);
SS2=zeros(1,6000);
sumR1=zeros(1,6000);
sumR1a=zeros(1,6000);
sumR1b=zeros(1,6000);
spread=0.0002;


%Zerowanie zmiennych do wyznaczania najlepszego przypadku
best=0;
bestk1=0;
bestt1=0;
bestl1=0;
bestb1=0;
bestvp1=0;
p1=1;
bestmcc=0;

%Pêtle do optymalizacji parametrów
for k1=47:1:47 %liczba kroków wprzód, po której nale¿y zamkn¹æ pozycjê
for t1=22:1:22 %liczba kroków wstecz brana pod uwagê przy uwglêdnieniu wolumenu
for l1=165:1:180 %liczba kroków wstecz na krzywej zysku skumulowanego dla ustalenia decyzji o otwarciu pozycji
for b1=0.0054:0.0002:0.0054 %wielkoœæ obsuniêcia, która decyduje o wstrzymaniu otwarcia pozycji
for vp1=-52:1:-52 %poziom wolumenu decyduj¹cego o otwarciu pozycji   
tp=0;
fp=0;
tn=0;
fn=0;
%R1b=zeros(1,6000);
begin1=k1+l1+1;%Zmienna do wyznaczenia najmniejszego i, dla którego mo¿emy iterowaæ
if (t1+1>begin1)
    begin1=t1+1;
end

for i=begin1:6000
   
    %Warunek zwi¹zany z porównaniem œredniego i obecnego wolumenu
    vol1(i)=mean(C(i-t1:i,5))-C(i,5);
    if vol1(i)>vp1
        v1(i)=1;
    else
        v1(i)=0;
    end
      
    %Wyliczenie punktów pivota  
    P(i)=(C(i-1,2)+C(i-1,3)+C(i-1,4))/3;  %pivot point
    RR1(i)=2*P(i)-C(i-1,3);  %pierwszy opór
    SS1(i)=2*P(i)-C(i-1,2);  %pierwsze wsparcie
    RR2(i)=P(i)+(RR1(i)-SS1(i)); %drugi opór
    SS2(i)=P(i)-(RR1(i)-SS1(i));  %drugie wsparcie 
    
    %Warunki otwarcia pozycji d³ugiej
    if RR2(i)<C(i,4) && v1(i)==0 %otwarcie pozycji d³ugiej je¿eli cena jest powy¿ej RR2
        R1(i)=C(i+k1,4)-C(i,4)-spread;
        if p1==1  %czy dotychczasowy przebieg krzywej zysku skumulowanego sumR1 sugeruje, by otworzyæ pozycjê
            R1a(i)=C(i+k1,4)-C(i+1,1)-spread;%zwrot z pozycji d³ugiej po spe³nienu warunku  
                    if R1a(i)>0
                        tp=tp+1;
                    else
                        fp=fp+1;
                    end
        else
            R1a(i)=0;
            R1b(i)=C(i+k1,4)-C(i+1,1)-spread;
                    if R1b(i)>0
                        fn=fn+1;
                    else
                        tn=tn+1;
                    end
        end
    else
        R1(i)=0;
        R1a(i)=0;
                    R1b(i)=C(i+k1,4)-C(i+1,1)-spread;
                    if R1b(i)>0
                        fn=fn+1;
                    else
                        tn=tn+1;
                    end
    end
    
    %Warunek zwi¹zany ze sprawdzeniem krzywej zysku skumulowanego
    if sumR1(i-k1-l1)-sumR1(i-k1)>b1
        p1=0;
    else
        p1=1;
    end 
    
    %Obliczanie zysku skumulowanego
    sumR1(i)=sum(R1(begin1:i));
    sumR1a(i)=sum(R1a(begin1:i));

end

mcc=(tp*tn-fp*fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn));
%Sprawdzenie czy otrzymany wynik jest lepszy od dotychczasowych
if (mcc>bestmcc)
    bestmcc=mcc;
    bestk1=k1;
    bestt1=t1;
    bestl1=l1;
    bestb1=b1;
    bestvp1=vp1;
    best=sumR1a(end);
end  
end
end
end
end
end


%Wypisanie najlepszego wyniku wraz z parametrami
best
bestk1
bestt1
bestl1
bestb1
bestvp1
macierzA=[tp fp;fn tn]
bestmcc
