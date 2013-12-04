%Tomasz Nyczaj 2013 substrategia 3. 
%Cena pomiêdzy SS1 i SS2 --> pozycja d³uga

%Dane:
eurusd1h020313;
size(C)

%Inicjalizacja zmiennych, aby nie powiêkszaæ macierzy w pêtlach
R3=zeros(1,6000);
R3a=zeros(1,6000);
R3b=zeros(1,6000);
vol3=zeros(1,6000);
v3=zeros(1,6000);
P=zeros(1,6000);
RR1=zeros(1,6000);
RR2=zeros(1,6000);
SS1=zeros(1,6000);
SS2=zeros(1,6000);
sumR3=zeros(1,6000);
sumR3a=zeros(1,6000);
sumR3b=zeros(1,6000);
spread=0.0002;

%Zerowanie zmiennych do wyznaczania najlepszego przypadku
best3=0;
bestk3=0;
bestt3=0;
bestl3=0;
bestb3=0;
bestvp3=0;
p3=1;
bestmcc=0;

%Pêtle do optymalizacji parametrów
for k3=52:1:52 %liczba kroków wprzód, po której nale¿y zamkn¹æ pozycjê
for t3=23:1:23 %liczba kroków wstecz brana pod uwagê przy uwglêdnieniu wolumenu
for l3=177:1:177 %liczba kroków wstecz na krzywej zysku skumulowanego dla ustalenia decyzji o otwarciu pozycji
for b3=0.0018:0.0001:0.0018 %wielkoœæ obsuniêcia, która decyduje o wstrzymaniu otwarcia pozycji
for vp3=-129:1:-129 %poziom wolumenu decyduj¹cego o otwarciu pozycji    
mcc=0;
tp=0;
fp=0;
tn=0;
fn=0; 
begin3=k3+l3+1;%Zmienna do wyznaczenia najmniejszego i, dla którego mo¿emy iterowaæ
if (t3+1>begin3)
    begin3=t3+1;
end
    
for i=begin3:6000
   
    %Warunek zwi¹zany z porównaniem œredniego i obecnego wolumenu
    vol3(i)=mean(C(i-t3:i,5))-C(i,5);
    if vol3(i)>vp3
        v3(i)=1;
    else
        v3(i)=0;
    end
      
    %Wyliczenie punktów pivota  
    P(i)=(C(i-1,2)+C(i-1,3)+C(i-1,4))/3;  %pivot point
    RR1(i)=2*P(i)-C(i-1,3);  %pierwszy opór
    SS1(i)=2*P(i)-C(i-1,2);  %pierwsze wsparcie
    RR2(i)=P(i)+(RR1(i)-SS1(i)); %drugi opór
    SS2(i)=P(i)-(RR1(i)-SS1(i));  %drugie wsparcie 
    
    %Warunki otwarcia pozycji d³ugiej
    if SS1(i)>C(i,4) && C(i,4)>SS2(i) && v3(i)==0 %otwarcie pozycji d³ugiej je¿eli cena jest pomiêdzy SS2 i SS1
        R3(i)=C(i+k3,4)-C(i,4)-spread;
        if p3==1  %czy dotychczasowy przebieg krzywej zysku skumulowanego sumR3 sugeruje, by otworzyæ pozycjê
            R3a(i)=C(i+k3,4)-C(i+1,1)-spread;%zwrot z pozycji d³ugiej po spe³nienu warunku  
                    if R3a(i)>0
                        tp=tp+1;
                    else
                        fp=fp+1;
                    end       
        else
            R3a(i)=0;
            R3b(i)=C(i+k3,4)-C(i+1,1)-spread;
                    if R3b(i)>0
                        fn=fn+1;
                    else
                        tn=tn+1;
                    end
        end
    else
        R3(i)=0;
        R3a(i)=0;
        R3b(i)=C(i+k3,4)-C(i+1,1)-spread;
                    if R3b(i)>0
                        fn=fn+1;
                    else
                        tn=tn+1;
                    end
    end
    
    %Warunek zwi¹zany ze sprawdzeniem krzywej zysku skumulowanego
    if sumR3(i-k3-l3)-sumR3(i-k3)>b3
        p3=0;
    else
        p3=1;
    end 
    
    %Obliczanie zysku skumulowanego
    sumR3(i)=sum(R3(begin3:i));
    sumR3a(i)=sum(R3a(begin3:i));

end

mcc=(tp*tn-fp*fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn));
%Sprawdzenie czy otrzymany wynik jest lepszy od dotychczasowych
if (mcc>bestmcc)
    bestmcc=mcc;    
    bestk3=k3;
    bestt3=t3;
    bestl3=l3;
    bestb3=b3;
    bestvp3=vp3;
    best3=sumR3a(end);
end  
end
end
end
end
end

%Wypisanie najlepszego wyniku wraz z parametrami
best3
bestk3
bestt3
bestl3
bestb3
bestvp3
macierzC=[tp fp;fn tn]
bestmcc