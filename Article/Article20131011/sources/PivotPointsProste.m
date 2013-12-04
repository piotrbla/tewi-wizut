%Tomasz Nyczaj 2013 substrategie A-D

%Dane:
eurusd1h020313;
size(C)

RA=zeros(1,6000);
sumRA=zeros(1,6000);
RB=zeros(1,6000);
sumRB=zeros(1,6000);
RC=zeros(1,6000);
sumRC=zeros(1,6000);
RD=zeros(1,6000);
sumRD=zeros(1,6000);
sumRS=zeros(1,6000);
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
MCCA=0;
MCCB=0;
MCCC=0;
MCCD=0;
   
for i=2:6000
      
    %Wyliczenie punktów pivota  
    P(i)=(C(i-1,2)+C(i-1,3)+C(i-1,4))/3;  %pivot point
    RR1(i)=2*P(i)-C(i-1,3);  %pierwszy opór
    SS1(i)=2*P(i)-C(i-1,2);  %pierwsze wsparcie
    RR2(i)=P(i)+(RR1(i)-SS1(i)); %drugi opór
    SS2(i)=P(i)-(RR1(i)-SS1(i));  %drugie wsparcie 
    

    if RR2(i)<C(i,1)
        RA(i)=C(i,4)-C(i,1)-spread;
        lA=lA+1;
        if RA(i)>=0 
            TPA=TPA+1;
        else
            FPA=FPA+1;
        end
    else
        RA2(i)=C(i,4)-C(i,1)-spread;
        if RA2(i)>=0 
            FNA=FNA+1;
        else
            TNA=TNA+1;
        end        
    end
    
    if RR2(i)>C(i,1) && C(i,1)>RR1(i)
        RB(i)=C(i,1)-C(i,4)-spread;
        lB=lB+1
        if RB(i)>=0 
            TPB=TPB+1;
        else
            FPB=FPB+1;
        end
    else
        RB2(i)=C(i,1)-C(i,4)-spread;
        if RB2(i)>=0 
            FNB=FNB+1;
        else
            TNB=TNB+1;
        end 
    end
    
    if SS1(i)>C(i,1) && C(i,1)>SS2(i)
        RC(i)=C(i,4)-C(i,1)-spread;
        lC=lC+1;
        if RC(i)>=0 
            TPC=TPC+1;
        else
            FPC=FPC+1;
        end
    else
        RC2(i)=C(i,4)-C(i,1)-spread;
        if RC2(i)>=0 
            FNC=FNC+1;
        else
            TNC=TNC+1;
        end        
    end
    
    if SS2(i)>C(i,1)
        RD(i)=C(i,1)-C(i,4)-spread;
        lD=lD+1;
        if RD(i)>=0 
            TPD=TPD+1;
        else
            FPD=FPD+1;
        end
    else
        RD2(i)=C(i,1)-C(i,4)-spread;
        if RD2(i)>=0 
            FND=FND+1;
        else
            TND=TND+1;
        end         
    end
   
%Obliczanie zysku skumulowanego
    sumRA(i)=sum(RA(2:i));
    sumRB(i)=sum(RB(2:i));
    sumRC(i)=sum(RC(2:i));
    sumRD(i)=sum(RD(2:i));
    sumS(i)=sumRA(i)+sumRB(i)+sumRC(i)+sumRD(i);
end

sumaA=sumRA(6000)
MCCA=(TPA*TNA-FPA*FNA)/sqrt((TPA+FPA)*(TPA+FNA)*(TNA+FPA)*(TNA+FNA))
macierzA=[TPA FPA;FNA TNA]
lA
sumaB=sumRB(6000)
MCCB=(TPB*TNB-FPB*FNB)/sqrt((TPB+FPB)*(TPB+FNB)*(TNB+FPB)*(TNB+FNB))
macierzB=[TPB FPB;FNB TNB]
lB
sumaC=sumRC(6000)
MCCC=(TPC*TNC-FPC*FNC)/sqrt((TPC+FPC)*(TPC+FNC)*(TNC+FPC)*(TNC+FNC))
macierzC=[TPC FPC;FNC TNC]
lC
sumaD=sumRD(6000)
MCCD=(TPD*TND-FPD*FND)/sqrt((TPD+FPD)*(TPD+FND)*(TND+FPD)*(TND+FND))
macierzD=[TPD FPD;FND TND]
lD
TP=TPA+TPB+TPC+TPD;
TN=TNA+TNB+TNC+TND;
FP=FPA+FPB+FPC+FPD;
FN=FNA+FNB+FNC+FND;
MCC=(TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN))
macierz=[TP FP;FN TN]
sumaS=sumS(6000)


file_name = 'PivotPointsA';
SaveGraph( sumRA, file_name );
file_name = 'PivotPointsB';
SaveGraph( sumRB, file_name );
file_name = 'PivotPointsC';
SaveGraph( sumRC, file_name );
file_name = 'PivotPointsD';
SaveGraph( sumRD, file_name );
file_name = 'PivotPointsS';
SaveGraph( sumS, file_name );