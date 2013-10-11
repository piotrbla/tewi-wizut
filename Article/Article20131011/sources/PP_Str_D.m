%Tomasz Nyczaj 2013 substrategia 4.
%Cena poni�ej SS2 --> pozycja kr�tka

%Dane:
eurusd1h020313;
size(C)

%Inicjalizacja zmiennych, aby nie powi�ksza� macierzy w p�tlach
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
sumR4=zeros(1,6000);
sumR4a=zeros(1,6000);
sumR4b=zeros(1,6000);
spread=0.0002;

%Zerowanie zmiennych do wyznaczania najlepszego przypadku
best4=0;
bestk4=0;
bestt4=0;
bestl4=0;
bestb4=0;
bestvp4=0;
p4=1;
bestmcc=0;

%P�tle do optymalizacji parametr�w
for k4=91:1:91 %liczba krok�w wprz�d, po kt�rej nale�y zamkn�� pozycj�
    for t4=2:1:2 %liczba krok�w wstecz brana pod uwag� przy uwgl�dnieniu wolumenu
        for l4=76:1:76 %liczba krok�w wstecz na krzywej zysku skumulowanego dla ustalenia decyzji o otwarciu pozycji
            for b4=0.0072:0.0001:0.0072%wielko�� obsuni�cia, kt�ra decyduje o wstrzymaniu otwarcia pozycji
                for vp4=-190:1:-190 %poziom wolumenu decyduj�cego o otwarciu pozycji
                    tp=0;
                    fp=0;
                    tn=0;
                    fn=0;
                    begin4=k4+l4+1;%Zmienna do wyznaczenia najmniejszego i, dla kt�rego mo�emy iterowa�
                    if (t4+1>begin4)
                        begin4=t4+1;
                    end
                    
                    for i=begin4:6000
                        
                        %Warunek zwi�zany z por�wnaniem �redniego i obecnego wolumenu
                        vol4(i)=mean(C(i-t4:i,5))-C(i,5);
                        if vol4(i)>vp4
                            v4(i)=1;
                        else
                            v4(i)=0;
                        end
                        
                        %Wyliczenie punkt�w pivota
                        P(i)=(C(i-1,2)+C(i-1,3)+C(i-1,4))/3;  %pivot point
                        RR1(i)=2*P(i)-C(i-1,3);  %pierwszy op�r
                        SS1(i)=2*P(i)-C(i-1,2);  %pierwsze wsparcie
                        RR2(i)=P(i)+(RR1(i)-SS1(i)); %drugi op�r
                        SS2(i)=P(i)-(RR1(i)-SS1(i));  %drugie wsparcie
                        
                        %Warunki otwarcia pozycji kr�tkiej
                        if SS2(i)>C(i,4) && v4(i)==0 %otwarcie pozycji kr�tkiej je�eli cena jest mniejsza od SS2
                            R4(i)=C(i,4)-C(i+k4,4)-spread;
                            if p4==1  %czy dotychczasowy przebieg krzywej zysku skumulowanego sumR4 sugeruje, by otworzy� pozycj�
                                R4a(i)=C(i+1,1)-C(i+k4,4)-spread;%zwrot z pozycji kr�tkiej po spe�nienu warunku
                                if R4a(i)>0
                                    tp=tp+1;
                                else
                                    fp=fp+1;
                                end
                            else
                                R4a(i)=0;
                                R4b(i)=C(i+1,1)-C(i+k4,4)-spread;
                                if R4b(i)>0
                                    fn=fn+1;
                                else
                                    tn=tn+1;
                                end
                            end
                        else
                            R4(i)=0;
                            R4a(i)=0;
                            R4b(i)=C(i+1,1)-C(i+k4,4)-spread;
                            if R4b(i)>0
                                fn=fn+1;
                            else
                                tn=tn+1;
                            end
                        end
                        
                        %Warunek zwi�zany ze sprawdzeniem krzywej zysku skumulowanego
                        if sumR4(i-k4-l4)-sumR4(i-k4)>b4
                            p4=0;
                        else
                            p4=1;
                        end
                        
                        %Obliczanie zysku skumulowanego
                        sumR4(i)=sum(R4(begin4:i));
                        sumR4a(i)=sum(R4a(begin4:i));
                        
                    end
                    %tn=tn/10;
                    %fn=fn/10;
                    mcc=(tp*tn-fp*fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn));
                    %Sprawdzenie czy otrzymany wynik jest lepszy od dotychczasowych
                    if (mcc>bestmcc)
                        best4=sumR4a(end);
                        bestk4=k4;
                        bestt4=t4;
                        bestl4=l4;
                        bestb4=b4;
                        bestvp4=vp4;
                        bestmcc=mcc;
                    end
                end
            end
        end
    end
end

file_name = 'PivotPointsD';
SaveGraph( sumR4a, file_name )

%Wypisanie najlepszego wyniku wraz z parametrami
Calmar = obliczCalmara(sumR4a);
Matrix = [round2(best4,0.001), round2(Calmar,0.001), round2(bestmcc,0.001), bestk4, bestt4, bestl4, bestb4, bestvp4];
MatrixToLatex([file_name '_results.txt'], Matrix);

macierzD=[tp fp;fn tn];
ConfusionMatrixToLatex( [file_name '_CM.txt'], macierzD );
