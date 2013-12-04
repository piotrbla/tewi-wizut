%Tomasz Nyczaj 2013 Podsumowanie 4 substrategii

%Dane:
eurusd1h020313;
size(C)

%Inicjalizacja zmiennych, aby nie powiêkszaæ macierzy w pêtlach
R1=zeros(1,6000);
R1a=zeros(1,6000);
R1b=zeros(1,6000);
vol1=zeros(1,6000);
v1=zeros(1,6000);
R2=zeros(1,6000);
R2a=zeros(1,6000);
R2b=zeros(1,6000);
vol2=zeros(1,6000);
v2=zeros(1,6000);
R3=zeros(1,6000);
R3a=zeros(1,6000);
R3b=zeros(1,6000);
vol3=zeros(1,6000);
v3=zeros(1,6000);
R4=zeros(1,6000);
R4a=zeros(1,6000);
R4b=zeros(1,6000);
vol4=zeros(1,6000);
v4=zeros(1,6000);
P=zeros(1,6000);
RR1=zeros(1,6000);
RR2=zeros(1,6000);
SS1=zeros(1,6000);
SS2=zeros(1,6000);
sumR1=zeros(1,6000);
sumR1a=zeros(1,6000);
sumR2=zeros(1,6000);
sumR2a=zeros(1,6000);
sumR3=zeros(1,6000);
sumR3a=zeros(1,6000);
sumR4=zeros(1,6000);
sumR4a=zeros(1,6000);
suma=zeros(1,6000);
spread=0.0002;

lA=0;
lB=0;
lC=0;
lD=0;
TPA=0;
TPB=0;
TPC=0;
TPD=0;
FPA=0;
FPB=0;
FPC=0;
FPD=0;
TNA=0;
TNB=0;
TNC=0;
TND=0;
FNA=0;
FNB=0;
FNC=0;
FND=0;

k1=47;
t1=22;
l1=170;
b1=0.0054;
vp1=-52;
p1=1;

k2=178;
t2=139;
l2=31;
b2=0.0016;
vp2=-246;
p2=1;

k3=52;
t3=23;
l3=177;
b3=0.0018;
vp3=-129;
p3=1;

k4=91;
t4=2;
l4=76;
b4=0.0072;
vp4=-190;
p4=1;

begin1=k1+l1+1;%Zmienna do wyznaczenia najmniejszego i, dla którego mo¿emy iterowaæ
if (t1+1>begin1)
    begin1=t1+1;
end
begin2=k2+l2+1;%Zmienna do wyznaczenia najmniejszego i, dla którego mo¿emy iterowaæ
if (t2+1>begin2)
    begin2=t2+1;
end

begin3=k3+l3+1;%Zmienna do wyznaczenia najmniejszego i, dla którego mo¿emy iterowaæ
if (t3+1>begin3)
    begin3=t3+1;
end

begin4=k4+l4+1;%Zmienna do wyznaczenia najmniejszego i, dla którego mo¿emy iterowaæ
if (t4+1>begin4)
    begin4=t4+1;
end


for i=2:6000
   
    %Warunek zwi¹zany z porównaniem œredniego i obecnego wolumenu
if (i>=begin1)
    vol1(i)=mean(C(i-t1:i,5))-C(i,5);
    if vol1(i)>vp1
        v1(i)=1;
    else
        v1(i)=0;
    end
end    

if (i>=begin2)
    vol2(i)=mean(C(i-t2:i,5))-C(i,5);
    if vol2(i)>vp2
        v2(i)=1;
    else
        v2(i)=0;
    end  
end

if (i>=begin3)
    vol3(i)=mean(C(i-t3:i,5))-C(i,5);
    if vol3(i)>vp3
        v3(i)=1;
    else
        v3(i)=0;
    end
end    

if (i>=begin4)
    vol4(i)=mean(C(i-t4:i,5))-C(i,5);
    if vol4(i)>vp4
        v4(i)=1;
    else
        v4(i)=0;
    end    
end

    %Wyliczenie punktów pivota  
    P(i)=(C(i-1,2)+C(i-1,3)+C(i-1,4))/3;  %pivot point
    RR1(i)=2*P(i)-C(i-1,3);  %pierwszy opór
    SS1(i)=2*P(i)-C(i-1,2);  %pierwsze wsparcie
    RR2(i)=P(i)+(RR1(i)-SS1(i)); %drugi opór
    SS2(i)=P(i)-(RR1(i)-SS1(i));  %drugie wsparcie 
    
if (i>=begin1)
    if RR2(i)<C(i,4) && v1(i)==0 %otwarcie pozycji d³ugiej je¿eli cena jest powy¿ej RR2
        R1(i)=C(i+k1,4)-C(i,4)-spread;
        if p1==1  %czy dotychczasowy przebieg krzywej zysku skumulowanego sumR1 sugeruje, by otworzyæ pozycjê
            R1a(i)=C(i+k1,4)-C(i+1,1)-spread;%zwrot z pozycji d³ugiej po spe³nienu warunku  
            if R1a(i)>=0 
                TPA=TPA+1;
            else
                FPA=FPA+1;
            end        
        else
            R1a(i)=0;
            R1b(i)=C(i+k1,4)-C(i+1,1)-spread;
            if R1b(i)>=0 
                FNA=FNA+1;
            else
                TNA=TNA+1;
            end  
        end
    else
        R1(i)=0;
        R1a(i)=0;
        R1b(i)=C(i+k1,4)-C(i+1,1)-spread;
        if R1b(i)>=0 
            FNA=FNA+1;
        else
            TNA=TNA+1;
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
if (i>=begin2)
    if RR2(i)>C(i,4) && C(i,4)>RR1(i) && v2(i)==0 %otwarcie pozycji krótkiej je¿eli cena jest pomiêdzy RR1 i RR2
        R2(i)=C(i,4)-C(i+k2,4)-spread;
        if p2==1  %czy dotychczasowy przebieg krzywej zysku skumulowanego sumR2 sugeruje, by otworzyæ pozycjê
            R2a(i)=C(i+1,1)-C(i+k2,4)-spread;%zwrot z pozycji krótkiej po spe³nienu warunku        
            if R2a(i)>=0 
                TPB=TPB+1;
            else
                FPB=FPB+1;
            end        
        else
            R2a(i)=0;
            R2b(i)=C(i+1,1)-C(i+k2,4)-spread;
            if R2b(i)>=0 
                FNB=FNB+1;
            else
                TNB=TNB+1;
            end              
        end
    else
        R2(i)=0;
        R2a(i)=0;
        R2b(i)=C(i+1,1)-C(i+k2,4)-spread;
        if R2b(i)>=0 
            FNB=FNB+1;
        else
            TNB=TNB+1;
        end
    end
    
    %Warunek zwi¹zany ze sprawdzeniem krzywej zysku skumulowanego
    if sumR2(i-k2-l2)-sumR2(i-k2)>b2
        p2=0;
    else
        p2=1;
    end 
    
    %Obliczanie zysku skumulowanego
    sumR2(i)=sum(R2(begin2:i));
    sumR2a(i)=sum(R2a(begin2:i));
end
if (i>=begin3)
       %Warunek zwi¹zany ze sprawdzeniem krzywej zysku skumulowanego
    if SS1(i)>C(i,4) && C(i,4)>SS2(i) && v3(i)==0 %otwarcie pozycji d³ugiej je¿eli cena jest pomiêdzy SS2 i SS1
        R3(i)=C(i+k3,4)-C(i,4)-spread;
        if p3==1  %czy dotychczasowy przebieg krzywej zysku skumulowanego sumR3 sugeruje, by otworzyæ pozycjê
            R3a(i)=C(i+k3,4)-C(i+1,1)-spread;%zwrot z pozycji d³ugiej po spe³nienu warunku       
            if R3a(i)>=0 
                TPC=TPC+1;
            else
                FPC=FPC+1;
            end        
        else
            R3a(i)=0;
            R3b(i)=C(i+k3,4)-C(i+1,1)-spread;
            if R3b(i)>=0 
                FNC=FNC+1;
            else
                TNC=TNC+1;
            end
        end
    else
        R3(i)=0;
        R3a(i)=0;
        R3b(i)=C(i+k3,4)-C(i+1,1)-spread;
        if R3b(i)>=0 
            FNC=FNC+1;
        else
            TNC=TNC+1;
        end        
    end
    
    if sumR3(i-k3-l3)-sumR3(i-k3)>b3
        p3=0;
    else
        p3=1;
    end 
 
    %Obliczanie zysku skumulowanego
    sumR3(i)=sum(R3(begin3:i));
    sumR3a(i)=sum(R3a(begin3:i));
end
if (i>=begin4)
    if SS2(i)>C(i,4) && v4(i)==0 %otwarcie pozycji krótkiej je¿eli cena jest mniejsza od SS2
        R4(i)=C(i,4)-C(i+k4,4)-spread;
        if p4==1  %czy dotychczasowy przebieg krzywej zysku skumulowanego sumR4 sugeruje, by otworzyæ pozycjê
            R4a(i)=C(i+1,1)-C(i+k4,4)-spread;%zwrot z pozycji krótkiej po spe³nienu warunku  
            if R4a(i)>=0 
                TPD=TPD+1;
            else
                FPD=FPD+1;
            end         
        else
            R4a(i)=0;
            R4b(i)=C(i+1,1)-C(i+k4,4)-spread;
            if R4b(i)>=0 
                FND=FND+1;
            else
                TND=TND+1;
            end            
        end
    else
        R4(i)=0;
        R4a(i)=0;
        R4b(i)=C(i+1,1)-C(i+k4,4)-spread;
        if R4b(i)>=0 
            FND=FND+1;
        else
            TND=TND+1;
        end          
    end
    
    %Warunek zwi¹zany ze sprawdzeniem krzywej zysku skumulowanego
    if sumR4(i-k4-l4)-sumR4(i-k4)>b4
        p4=0;
    else
        p4=1;
    end 
    
    %Obliczanie zysku skumulowanego
    sumR4(i)=sum(R4(begin4:i));
    sumR4a(i)=sum(R4a(begin4:i));
end
suma(i)=sumR4a(i)+sumR3a(i)+sumR2a(i)+sumR1a(i);    
end  

sumaA=sumR1a(6000)
CalmarA=obliczCalmara(sumR1a)
MCCA=(TPA*TNA-FPA*FNA)/sqrt((TPA+FPA)*(TPA+FNA)*(TNA+FPA)*(TNA+FNA))
macierzA=[TPA FPA;FNA TNA]

sumaB=sumR2a(6000)
CalmarB=obliczCalmara(sumR2a)
MCCB=(TPB*TNB-FPB*FNB)/sqrt((TPB+FPB)*(TPB+FNB)*(TNB+FPB)*(TNB+FNB))
macierzB=[TPB FPB;FNB TNB]

sumaC=sumR3a(6000)
CalmarC=obliczCalmara(sumR3a)
MCCC=(TPC*TNC-FPC*FNC)/sqrt((TPC+FPC)*(TPC+FNC)*(TNC+FPC)*(TNC+FNC))
macierzC=[TPC FPC;FNC TNC]

sumaD=sumR4a(6000)
CalmarD=obliczCalmara(sumR4a)
MCCD=(TPD*TND-FPD*FND)/sqrt((TPD+FPD)*(TPD+FND)*(TND+FPD)*(TND+FND))
macierzD=[TPD FPD;FND TND]

TP=TPA+TPB+TPC+TPD;
TN=TNA+TNB+TNC+TND;
FP=FPA+FPB+FPC+FPD;
FN=FNA+FNB+FNC+FND;
suma(end)
CalmarS=obliczCalmara(suma)
MCC=(TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN))
macierz=[TP FP;FN TN]
file_name = 'PivotPointsA';
SaveGraph( sumR1a, file_name );
file_name = 'PivotPointsB';
SaveGraph( sumR2a, file_name );
file_name = 'PivotPointsC';
SaveGraph( sumR3a, file_name );
file_name = 'PivotPointsD';
SaveGraph( sumR4a, file_name );
file_name = 'PivotPointsPodsumowanie';
SaveGraph( suma, file_name );