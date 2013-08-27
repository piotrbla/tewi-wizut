clc
close
clear

EURJPY;
spread = 0.03;
bestReturn = -Inf;
k=5*4:4:50*4;
paramDuration = 2:1:22;

file_name = 'ROC_EURJPY_S_SearchBestKD';
rynek = 'EURJPY';

C_verrify = C(round(size(C,1)*0.6):end,:);
C_learn = C(1:round(size(C,1)*0.6),:);

for j=k
    for Duration = paramDuration
        [profit, ~, ~, Calmar, iS] = ROC_S_dur(C_learn,j,Duration,spread);
        if profit>bestReturn
            disp(['Wyniki uczenie --- Zysk: ' num2str(profit) ...
                ' --- Calmar: ' num2str(Calmar) ' dla: k=' num2str(j)...
                ', duration = ' num2str(Duration) '. Otwartych pozycji krotkich: ' num2str(iS)]);
            bestReturn = profit;
            bestK = j;
            bestDuration = Duration;
        end
    end
end

[profit, sumR, ROC_vec, Calmar,iS] = ROC_S_dur(C_verrify,bestK,bestDuration,spread);
%%   WYNIKI
disp(['Wyniki weryfikacja --- Zysk: ' num2str(profit) ...
    ' --- Calmar: ' num2str(Calmar) ' dla: k=' num2str(bestK)...
    '. Otwartych pozycji dlugich: ' num2str(iS)]);

%%   ZAPIS
hFig = figure(1);
set(hFig, 'Position', [200 200 640 480]);
plot(C_verrify(:,4));
hold on;
title(['Trend rynku - ' rynek]);
xlabel('Liczba swiec');
ylabel('Zamkniecie');
hold off;
set(hFig, 'PaperPositionMode','auto');
print(hFig,'-dpng', '-r0',[file_name '_trend']);

hFig = figure(1);
set(hFig, 'Position', [200 200 640 480]);
plot(sumR(sumR~=0));
hold on;
title(['Zysk skumulowany: ' num2str(profit) ' - ' rynek]);
xlabel('Liczba swiec');
ylabel('Zysk');
hold off;
set(hFig, 'PaperPositionMode','auto');
print(hFig,'-dpng', '-r0',[file_name '_zysk']);

hFig = figure(1);
set(hFig, 'Position', [200 200 640 480]);
h = plot(ROC_vec);
hold on;
plot(zeros(1,length(ROC_vec)),'k');
title(['Krzywa ROC - ' rynek]);
xlabel('Liczba swiec');
ylabel('Zmiana');
hold off;
set(hFig, 'PaperPositionMode','auto');
print(hFig,'-dpng', '-r0',[file_name '_krzywaROC']);

fileID =fopen([file_name '.txt'],'w');
fprintf(fileID, 'Rate Of Change - najlepszy wynik\n\n');
fprintf(fileID, 'Dlugosc cyklu: \t%i\n', bestK);
fprintf(fileID, 'Duration: \t%i\n', bestDuration);
fprintf(fileID, 'Zysk skumulowany: \t%0.2f\n', profit);
fprintf(fileID, 'Calmar: \t%0.2f\n', Calmar);
fprintf(fileID, 'Liczba otwartych pozycji dlugich: \t%i\n', iS);
fclose(fileID);

close all;