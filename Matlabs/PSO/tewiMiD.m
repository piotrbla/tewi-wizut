function [ zyl, Calmar, l_open] = tewiMiD( C, spread, pocz, kon, ...
    b, wstp, wstk, lkr, SL, TP, bvol, vwst, ll3,...
    bawe, bcawe)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

m=size(C);

F=C(pocz+1:end,:);  %macierz danych z "przysz³osci"
C1=C(1:pocz,:);   %macierz danych do chwili bie¿¹cej


ll=0; %liczba pozycji dlugich w badanym okresie
ls=0;  %liczba poz krotkich
lsll=0;

%cowst=0; %przesuniecie wstegi Bollingera
zl=zeros(1,m(1));
zs=zeros(1,m(1));
zsp=zeros(1,m(1));
zlp=zeros(1,m(1));
zspd=zeros(1,m(1));
zlpd=zeros(1,m(1));

zl1=zeros(1,m(1));
zl2=zeros(1,m(1));
zl3=zeros(1,m(1));
zl4=zeros(1,m(1));
zl5=zeros(1,m(1));
zl6=zeros(1,m(1));
zl7=zeros(1,m(1));
zl8=zeros(1,m(1));

lo1=0;
lo2=0;
l1=0;
l2=0;
l3=0;
l4=0;
l5=0;
l6=0;
l7=0;
pp=0;
pw=0;

lop=0;
lop(pocz-1)=0;
l=0;  %licznik nowych ?wiec
j1=1;
lll=0;

%parametry strategii

pawe=1;
cawe=1;



for i=pocz:kon%20:pocz+6100 %40000:pocz+16000  %pêtla g³ówna, ka¿dy i-ty krok po pocz, to chwila bie¿¹ca, nie dysponuje siê informacj¹ od i+1 wprzód; dopisane 1000 œwiec to swiece z przysz³osci
    lop(i)=lop(i-1);
    otw(i)=0; %tyo otwarcia - 1 lub 2
    
    
    
    MA3(i)=(C1(i-1,4)+C1(i-2,4)+C1(i-3,4))/3;
    
    max10(i)=max(C1(i-wstp:i-wstk,2)); %z kruts2d
    min10(i)=min(C1(i-wstp:i-wstk,3));
    
    gwp(i)=max10(i);  %tu zmiana !!!
    dwp(i)=min10(i);
    
    zz(i)=0;
    %stol(i)=0;
    
    
    vol(i)=-mean(C1(i-vwst:i,5))+C1(i,5);
    
    if vol(i)>bvol
        vo(i)=1;
    else
        vo(i)=0;
    end
    
    
    %otwarcie 1. typu
    if C1(i,1)<dwp(i)-b && vo(i)==1 && pawe==1 && cawe==1
        ll=ll+1;
        open(ll)=C1(i,1);
        poczpoz(ll)=i;
        lop(i)=lop(i)+1;
        stol(ll)=0;
        lo1=lo1+1;
        otw(ll)=1;
    end
    
    %otwarcie  2. typu
    if C1(i,3)<dwp(i)-b && C1(i,1)>dwp(i)-b  && vo(i)==1 && pawe==1  && cawe==1%otwarcie krotkiej z parametrami SL TP  gwp i lkr
        ll=ll+1;
        open(ll)=dwp(i)-b;
        poczpoz(ll)=i;
        lop(i)=lop(i)+1;
        stol(ll)=0;
        lo2=lo2+1;
        otw(ll)=2;
    end
    
    
    sumcurr(i)=0;
    
    
    %sprawdzeniee warunków zamkniecia poprzednio otwartych pozycji
    for j=1:ll  %(poprawiæ)
        lll=lll+1;
        
        %zamkniecie 1. typu
        if stol(j)==0
            if i==poczpoz(j)+lkr && stol(j)==0 && otw(j)==1
                zz(j)=-C1(i,4)+open(j)-spread;  %(zwrot z pozycji krotkiej)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl1(j)=zz(j);
                l1=l1+1;
            end
            
            %zamkniêcie 2. typu
            
            if -C1(i,1)+open(j)<-SL && stol(j)==0 && otw(j)==1 %&& i>poczpoz(j)
                zz(j)=-C1(i,1)+open(j)-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl2(j)=zz(j);
                l2=l2+1;
                %l5=l5+1;
            end
            
            %zamkniecie 3. typu
            
            if -C1(i,2)+open(j)<-SL && stol(j)==0 && C1(i,1)-open(j)>-SL && otw(j)==1%&& i>poczpoz(j)
                zz(j)=-SL-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl3(j)=zz(j);
                %l2=l2+1;
                l3=l3+1;
                %pause
            end
            
            
            %zamkniecie 4. typu
            
            if -C1(i,1)+open(j)>TP && stol(j)==0 && otw(j)==1%&& i>poczpoz(j)
                zz(j)=-C1(i,1)+open(j)-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl4(j)=zz(j);
                l4=l4+1;
                
            end
            
            %zamkniecie 5. typu
            
            if -C1(i,3)+open(j)>TP && stol(j)==0 && otw(j)==1%&& i>poczpoz(j)
                zz(j)=TP-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl5(j)=zz(j);
                l5=l5+1;
                
            end
            
            %zamkniêcie 6. typu
            
            if C1(i,1)>dwp(i) && stol(j)==0 && otw(j)==1 %&& i>poczpoz(j)
                zz(j)=-C1(i,1)+open(j)-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl6(j)=zz(j);
                l6=l6+1;
            end
            
            %zamkniêcie 7. typu
            
            if C1(i,2)>dwp(i) && stol(j)==0 && otw(j)==1 %&& i>poczpoz(j)
                zz(j)=-dwp(i)+open(j)-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl7(j)=zz(j);
                l7=l7+1;
            end
            
            %dla otw=2
            
            %zamkniecie 1. typu
            
            if i==poczpoz(j)+lkr && stol(j)==0 && otw(j)==2
                zz(j)=-C1(i,4)+open(j)-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl1(j)=zz(j);
                l1=l1+1;
            end
            
            
            %zamkniêcie 2. typu
            
            if -C1(i,1)+open(j)<-SL && stol(j)==0 && otw(j)==2 && i>poczpoz(j)
                zz(j)=-C1(i,1)+open(j)-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl2(j)=zz(j);
                l2=l2+1;
                %l5=l5+1;
            end
            
            
            %zamkniecie 3. typu
            
            if -C1(i,2)+open(j)<-SL && stol(j)==0 && C1(i,1)-open(j)>-SL && otw(j)==2 && i>poczpoz(j)
                zz(j)=-SL-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl3(j)=zz(j);
                %l2=l2+1;
                l3=l3+1;
                %pause
            end
            
            
            
            %zamkniecie 4. typu
            
            if -C1(i,1)+open(j)>TP && stol(j)==0 && otw(j)==2%&& i>poczpoz(j)
                zz(j)=-C1(i,1)+open(j)-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl4(j)=zz(j);
                l4=l4+1;
                
            end
            
            
            %zamkniecie 5. typu
            
            if -C1(i,3)+open(j)>TP && stol(j)==0 && otw(j)==2 && i>poczpoz(j)
                zz(j)=TP-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl5(j)=zz(j);
                l5=l5+1;
                
            end
            
            
            
            %zamkniêcie 6. typu
            
            if C1(i,1)>dwp(i) && stol(j)==0 && otw(j)==2 && i>poczpoz(j)
                zz(j)=-C1(i,1)+open(j)-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl6(j)=zz(j);
                l6=l6+1;
            end
            
            
            
            %zamkniêcie 7. typu
            
            if C1(i,2)>dwp(i) && stol(j)==0 && otw(j)==2 && i>poczpoz(j)
                zz(j)=-dwp(i)+open(j)-spread;  %(zwrot z pozycji)
                lop(i)=lop(i)-1;
                stol(j)=1;
                zl7(j)=zz(j);
                l7=l7+1;
            end
            
            
            curr(j)=C1(i,4)-open(j);
            sumcurr(i)=sumcurr(i)+curr(j);
            
            
        end %if stol
        
        
        
        
    end %j
    
    
    
    
    zysl(i)=sum(zz(1:ll));
    
    if sumcurr(i)<-bcawe
        cawe=0;
    else
        cawe=1;
    end
    
    if zysl(i-lkr-ll3)-zysl(i-lkr)>bawe
        pawe=0;
    else
        pawe=1;
    end
    
    if i>=pocz
        l=l+1;
        C1(pocz+l,:)=F(l,:);  %dodanie nowej œwiecy z macierzy F (przysz³ej, odcietej od przesz³³oœci); w tym miejscu powinien nastapiæ import swiecy z platfoermy brokerskiej
        
    end %if
    
    
end %i



zyl=sum(zz);
%sharpe=zyl/std(zz)

recZ=0;
recO=0;
for j=1:kon
    %zysk(j)=sum(zk(1:j));
    if zysl(j)>recZ
        recZ=zysl(j);
    end
    dZ(j)=zysl(j)-recZ;
    
    if dZ(j)<recO
        recO=dZ(j);  %obsuniecie maksymalne
    end
end
Calmar=-(zyl)/recO;


l_open = lo1+lo2;



end

