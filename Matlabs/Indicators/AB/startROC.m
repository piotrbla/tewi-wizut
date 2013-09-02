clc
close
clear

EURJPY;
spread = 0.03;
k=89;%5*4:1:50*4;
file_name = 'ROC_EURJPY_LS_SearchBestK';
rynek = 'EURJPY';

C_learn = C(1:round(size(C,1)*0.6),:);
C_verrify = C(round(size(C,1)*0.6):end,:);

fileID =fopen([file_name '.txt'],'w');

bestProfit = -Inf;

for i=k
    [profit, Calmar, ~, iL, iS, ~] = ROC_LS( C_learn, spread, i);
    if profit>bestProfit
        bestProfit = profit;
        bestK = i;
        bestCalmar = Calmar;
        bestiL = iL;
        bestiS = iS;
        disp(['Wyniki uczenie --- Zysk: ' num2str(profit) ...
        ' --- Calmar: ' num2str(Calmar) ' dla: k=' num2str(i)...
        '. Otwartych pozycji dlugich: ' num2str(iL) ', krótkich: ' num2str(iS)]);
    end
end
[profit, Calmar, sumR, iL, iS, ROC_vec] = ROC_LS( C_verrify, spread, bestK);

%%   WYNIKI
disp(['Wyniki weryfikacja --- Zysk: ' num2str(profit) ...
    ' --- Calmar: ' num2str(Calmar) ' dla: k=' num2str(bestK)...
    '. Otwartych pozycji dlugich: ' num2str(iL) ', krótkich: ' num2str(iS)]);

fprintf(fileID, 'Rate Of Change - najlepszy wynik\n\n');
fprintf(fileID, 'OKRES UCZ¥CY\n');
fprintf(fileID, 'D³ugoœæ cyklu: \t%i\n', bestK);
fprintf(fileID, 'Zysk skumulowany: \t%0.2f\n', bestProfit);
fprintf(fileID, 'Calmar: \t%0.2f\n', bestCalmar);
fprintf(fileID, 'Liczba otwartych pozycji d³ugich: \t%i\n', bestiL);
fprintf(fileID, 'Liczba otwartych pozycji krótkich: \t%i\n\n', bestiS);


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

hFig = figure(2);
set(hFig, 'Position', [200 200 640 480]);
plot(sumR(sumR~=0));
hold on;
title(['Zysk skumulowany: ' num2str(profit) ' - ' rynek]);
xlabel('Liczba swiec');
ylabel('Zysk');
hold off;
set(hFig, 'PaperPositionMode','auto');
print(hFig,'-dpng', '-r0',[file_name '_zysk']);

hFig = figure(3);
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


fprintf(fileID, 'OKRES WALIDUJ¥CY\n');
fprintf(fileID, 'D³ugoœæ cyklu: \t%i\n', bestK);
fprintf(fileID, 'Zysk skumulowany: \t%0.2f\n', profit);
fprintf(fileID, 'Calmar: \t%0.2f\n', Calmar);
fprintf(fileID, 'Liczba otwartych pozycji d³ugich: \t%i\n', iL);
fprintf(fileID, 'Liczba otwartych pozycji krótkich: \t%i\n', iS);
fclose(fileID);

close all;