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
   
for i=2:6000
      
    %Wyliczenie punktów pivota  
    P(i)=(C(i-1,2)+C(i-1,3)+C(i-1,4))/3;  %pivot point
    RR1(i)=2*P(i)-C(i-1,3);  %pierwszy opór
    SS1(i)=2*P(i)-C(i-1,2);  %pierwsze wsparcie
    RR2(i)=P(i)+(RR1(i)-SS1(i)); %drugi opór
    SS2(i)=P(i)-(RR1(i)-SS1(i));  %drugie wsparcie 
    
    %Warunki otwarcia pozycji d³ugiej
    if RR2(i)<C(i,1)
        RA(i)=C(i,4)-C(i,1)-spread;
	lA=lA+1;
    end
if RR2(i)>C(i,1) && C(i,1)>RR1(i)
        RB(i)=C(i,1)-C(i,4)-spread;
	lB=lB+1;
    end
if SS1(i)>C(i,1) && C(i,1)>SS2(i)
        RC(i)=C(i,4)-C(i,1)-spread;
	lC=lC+1;
    end
if SS2(i)>C(i,1)
        RD(i)=C(i,1)-C(i,4)-spread;
	lD=lD+1;
    end
   
%Obliczanie zysku skumulowanego
    sumRA(i)=sum(RA(2:i));
    sumRB(i)=sum(RB(2:i));
    sumRC(i)=sum(RC(2:i));
    sumRD(i)=sum(RD(2:i));
    sumS(i)=sumRA(i)+sumRB(i)+sumRC(i)+sumRD(i);
end

sumaA=sumRA(6000)
lA
sumaB=sumRB(6000)
lB
sumaC=sumRC(6000)
lC
sumaD=sumRD(6000)
lD
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