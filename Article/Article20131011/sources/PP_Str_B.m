%Tomasz Nyczaj 2013 substrategia 2.
%Cena pomiêdzy RR1 i RR2 --> pozycja krótka

%Dane:
eurusd1h020313;
size(C)

%Inicjalizacja zmiennych, aby nie powiêkszaæ macierzy w pêtlach
R2=zeros(1,6000);
R2a=zeros(1,6000);
R2b=zeros(1,6000);
vol2=zeros(1,6000);
v2=zeros(1,6000);
P=zeros(1,6000);
RR1=zeros(1,6000);
RR2=zeros(1,6000);
SS1=zeros(1,6000);
SS2=zeros(1,6000);
sumR2=zeros(1,6000);
sumR2a=zeros(1,6000);
sumR2b=zeros(1,6000);
spread=0.0002;

%Zerowanie zmiennych do wyznaczania najlepszego przypadku
best2=0;
bestk2=0;
bestt2=0;
bestl2=0;
bestb2=0;
bestvp2=0;
p2=1;
bestmcc=0;
%Pêtle do optymalizacji parametrów
for k2=178:1:178 %liczba kroków wprzód, po której nale¿y zamkn¹æ pozycjê
    for t2=139:1:139 %liczba kroków wstecz brana pod uwagê przy uwglêdnieniu wolumenu
        for l2=31:1:31 %liczba kroków wstecz na krzywej zysku skumulowanego dla ustalenia decyzji o otwarciu pozycji
            for b2=0.0016:0.0001:0.0016 %wielkoœæ obsuniêcia, która decyduje o wstrzymaniu otwarcia pozycji
                for vp2=-246:1:-246 %poziom wolumenu decyduj¹cego o otwarciu pozycji
                    mcc=0;
                    tp=0;
                    fp=0;
                    tn=0;
                    fn=0;
                    begin2=k2+l2+1;%Zmienna do wyznaczenia najmniejszego i, dla którego mo¿emy iterowaæ
                    if (t2+1>begin2)
                        begin2=t2+1;
                    end
                    
                    for i=begin2:6000
                        
                        %Warunek zwi¹zany z porównaniem œredniego i obecnego wolumenu
                        vol2(i)=mean(C(i-t2:i,5))-C(i,5);
                        if vol2(i)>vp2
                            v2(i)=1;
                        else
                            v2(i)=0;
                        end
                        
                        %Wyliczenie punktów pivota
                        P(i)=(C(i-1,2)+C(i-1,3)+C(i-1,4))/3;  %pivot point
                        RR1(i)=2*P(i)-C(i-1,3);  %pierwszy opór
                        SS1(i)=2*P(i)-C(i-1,2);  %pierwsze wsparcie
                        RR2(i)=P(i)+(RR1(i)-SS1(i)); %drugi opór
                        SS2(i)=P(i)-(RR1(i)-SS1(i));  %drugie wsparcie
                        
                        %Warunki otwarcia pozycji krótkiej
                        if RR2(i)>C(i,4) && C(i,4)>RR1(i) && v2(i)==0 %otwarcie pozycji krótkiej je¿eli cena jest pomiêdzy RR1 i RR2
                            R2(i)=C(i,4)-C(i+k2,4)-spread;
                            if p2==1  %czy dotychczasowy przebieg krzywej zysku skumulowanego sumR2 sugeruje, by otworzyæ pozycjê
                                R2a(i)=C(i+1,1)-C(i+k2,4)-spread;%zwrot z pozycji krótkiej po spe³nienu warunku
                                if R2a(i)>0
                                    tp=tp+1;
                                else
                                    fp=fp+1;
                                end
                            else
                                R2a(i)=0;
                                R2b(i)=C(i+1,1)-C(i+k2,4)-spread;
                                if R2b(i)>0
                                    fn=fn+1;
                                else
                                    tn=tn+1;
                                end
                            end
                        else
                            R2(i)=0;
                            R2a(i)=0;
                            R2b(i)=C(i+1,1)-C(i+k2,4)-spread;
                            if R2b(i)>0
                                fn=fn+1;
                            else
                                tn=tn+1;
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
                    %tn=tn/10;
                    %fn=fn/10;
                    mcc=(tp*tn-fp*fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn));
                    %Sprawdzenie czy otrzymany wynik jest lepszy od dotychczasowych
                    if (mcc>bestmcc)
                        bestmcc=mcc;
                        bestk2=k2;
                        bestt2=t2;
                        bestl2=l2;
                        bestb2=b2;
                        bestvp2=vp2;
                        best2=sumR2a(end);
                    end
                end
            end
        end
    end
end
% 
% pocz = 5570;
% kon = 5600;
% hFig = figure;
% plot(C(pocz:kon,4),'k','LineWidth',2)
% hold on;
% plot(P(pocz:kon),'r');
% plot(RR1(pocz:kon),'g');
% plot(SS1(pocz:kon),'c');
% plot(RR2(pocz:kon),'m');
% plot(SS2(pocz:kon),'b');
% legend('Close price','Pivot Point','R1','S1','R2','S2');
% xlabel('Candles count');
% ylabel('Close price');
% set(hFig, 'Position', [200 200 640 480])
% set(hFig, 'PaperPositionMode','auto')
% print(hFig,'-dpng', '-r0','samplePP')

% hFig = figure;
% plot(C(1:6000,4));
% xlabel('Candles count');
% ylabel('Close price');
% set(hFig, 'Position', [200 200 640 480])
% set(hFig, 'PaperPositionMode','auto')
% print(hFig,'-dpng', '-r0','researched_data')

file_name = 'PivotPointsB';
SaveGraph( sumR2a, file_name )

%Wypisanie najlepszego wyniku wraz z parametrami
Calmar = obliczCalmara(sumR2a);
Matrix = [round2(best2,0.001), round2(Calmar,0.001), round2(bestmcc,0.001), bestk2, bestt2, bestl2, bestb2, bestvp2];
MatrixToLatex([file_name '_results.txt'], Matrix);

macierzB=[tp fp;fn tn];
ConfusionMatrixToLatex( [file_name '_CM.txt'], macierzB );
