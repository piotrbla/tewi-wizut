clc
close
clear

EURJPY;
spread = 0.03;
k = 20*4;   % dane godzinowe
% k = 31*4;  % best
file_name = 'ROC_EURJPY_LS_simple';
rynek = 'EURJPY';

[profit, Calmar, sumR, iL, iS, ROC_vec] = ROC_LS( C, spread, k);

%%   WYNIKI
disp(['Wyniki --- Zysk: ' num2str(profit) ...
    ' --- Calmar: ' num2str(Calmar) ' dla: k=' num2str(k)...
    '. Otwartych pozycji dlugich: ' num2str(iL) ', krótkich: ' num2str(iS)]);

%%   ZAPIS
hFig = figure(1);
set(hFig, 'Position', [200 200 640 480]);
plot(C(:,4));
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
fprintf(fileID, 'Dlugosc cyklu: \t%i\n', k);
fprintf(fileID, 'Zysk skumulowany: \t%0.2f\n', profit);
fprintf(fileID, 'Calmar: \t%0.2f\n', Calmar);
fprintf(fileID, 'Liczba otwartych pozycji dlugich: \t%i\n', iL);
fprintf(fileID, 'Liczba otwartych pozycji krotkich: \t%i\n', iS);
fclose(fileID);

close all;