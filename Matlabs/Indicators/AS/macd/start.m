clc
close
clear

EURPLN60;
pip = 0.0001; % wielkosc pipsa na danym rynku
spread = 25 * pip; % spread dla rynku

file_name = 'MACD_EUR_PLN';
rynek = 'EUR_PLN';

%podzia³ na czêœæ ucz¹c¹ i waliduj¹c¹
C_learn = C(1:round(size(C,1)*0.6),:);
C_verrify = C(round(size(C,1)*0.6):end,:);

bestCalmar = -Inf;
bestProfit = -Inf;

for P1=10:30
	for P2=7:20
		for P3=3:20
            if(P1<P2)
                temp=P2;
                P2=P1;
                P1=temp;
            end
			[profit, Calmar, ~, iL, iS, MACD, SignalLine] = decision( C_learn, spread, P1, P2, P3);
			if Calmar>bestCalmar
				bestCalmar = Calmar;
				bestCalP1 = P1;
				bestCalP2 = P2;
				bestCalP3 = P3;
				disp(['Wyniki uczenie CALMAR --- Zysk: ' num2str(profit) ...
				' --- Calmar: ' num2str(Calmar) ' dla: P1=' num2str(bestCalP1) ' dla: P2=' num2str(bestCalP2) ' dla: P3=' num2str(bestCalP3) ...
				'. Otwartych pozycji dlugich: ' num2str(iL) ', krótkich: ' num2str(iS)]);
			end
			if profit>bestProfit
				bestProfit = profit;
				bestProfP1 = P1;
				bestProfP2 = P2;
				bestProfP3 = P3;
				disp(['Wyniki uczenie ZYSK --- Zysk: ' num2str(profit) ...
				' --- Calmar: ' num2str(Calmar) ' dla: P1=' num2str(bestProfP1) ' dla: P2=' num2str(bestProfP2) ' dla: P3=' num2str(bestProfP3) ...
				'. Otwartych pozycji dlugich: ' num2str(iL) ', krótkich: ' num2str(iS)]);
			end
		end
	end
end
fileID =fopen([file_name '.txt'],'w');
fprintf(fileID, '=========UCZENIE=========\n\n');
fprintf(fileID, 'MACD - najlepszy wynik ZYSK\n\n');
fprintf(fileID, 'Okres 1: \t%i\n', bestProfP1);
fprintf(fileID, 'Okres 2 \t%i\n', bestProfP2);
fprintf(fileID, 'Okres indykatora: \t%i\n', bestProfP3);
fprintf(fileID, 'Zysk skumulowany: \t%0.2f\n', bestProfit);

fprintf(fileID, '\n\nMACD - najlepszy wynik CALMAR\n\n');
fprintf(fileID, 'Okres 1: \t%i\n', bestCalP1);
fprintf(fileID, 'Okres 2 \t%i\n', bestCalP2);
fprintf(fileID, 'Okres indykatora: \t%i\n', bestCalP3);
fprintf(fileID, 'Calmar: \t%0.2f\n', bestCalmar);
fprintf(fileID, '\n\n=========Weryfikacja=========\n\n');

bestP1 = bestProfP1;
bestP2 = bestProfP2;
bestP3 = bestProfP3;
%bestP1 = bestCalP1;
%bestP2 = bestCalP2;
%bestP3 = bestCalP3;

[profit, Calmar, sumR, iL, iS, MACD, SignalLine] = decision( C_verrify, spread, bestP1, bestP2, bestP3);

%%   WYNIKI
disp(['Wyniki weryfikacja (Na ZYSK) --- Zysk: ' num2str(profit) ...
    ' --- Calmar: ' num2str(Calmar) ' dla: P1=' num2str(bestP1) ' dla: P2=' num2str(bestP2) ' dla: P3=' num2str(bestP3) ...
    '. Otwartych pozycji dlugich: ' num2str(iL) ', krótkich: ' num2str(iS)]);

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
h = plot(MACD);
hold on;
plot(zeros(1,length(MACD)),'k');
plot(SignalLine,'r');
title(['MACD i Signal Line - ' rynek]);
xlabel('Liczba swiec');
ylabel('Zmiana');
hold off;
set(hFig, 'PaperPositionMode','auto');
print(hFig,'-dpng', '-r0',[file_name '_MACD+Signal_Line']);


fprintf(fileID, 'MACD - najlepszy wynik ZYSK\n\n');
fprintf(fileID, 'Okres 1: \t%i\n', bestP1);
fprintf(fileID, 'Okres 2 \t%i\n', bestP2);
fprintf(fileID, 'Okres indykatora: \t%i\n', bestP3);
fprintf(fileID, 'Zysk skumulowany: \t%0.2f\n', profit);
fprintf(fileID, 'Calmar: \t%0.2f\n', Calmar);
fprintf(fileID, 'Liczba otwartych pozycji dlugich: \t%i\n', iL);
fprintf(fileID, 'Liczba otwartych pozycji krotkich: \t%i\n', iS);

[profit, Calmar, sumR, iL, iS, MACD, SignalLine] = decision( C_verrify, spread, bestCalP1, bestCalP2, bestCalP3);

%%   WYNIKI
disp(['Wyniki weryfikacja (Calmar) --- Zysk: ' num2str(profit) ...
    ' --- Calmar: ' num2str(Calmar) ' dla: P1=' num2str(bestCalP1) ' dla: P2=' num2str(bestCalP2) ' dla: P3=' num2str(bestCalP3) ...
    '. Otwartych pozycji dlugich: ' num2str(iL) ', krótkich: ' num2str(iS)]);

%%   ZAPIS
hFig = figure(1);
set(hFig, 'Position', [200 200 640 480]);
plot(sumR(sumR~=0));
hold on;
title(['Zysk skumulowany: ' num2str(profit) ' - ' rynek]);
xlabel('Liczba swiec');
ylabel('Zysk');
hold off;
set(hFig, 'PaperPositionMode','auto');
print(hFig,'-dpng', '-r0',[file_name '_zysk_Cal']);

hFig = figure(1);
set(hFig, 'Position', [200 200 640 480]);
h = plot(MACD);
hold on;
plot(zeros(1,length(MACD)),'k');
plot(SignalLine,'r');
title(['MACD i Signal Line - ' rynek]);
xlabel('Liczba swiec');
ylabel('Zmiana');
hold off;
set(hFig, 'PaperPositionMode','auto');
print(hFig,'-dpng', '-r0',[file_name '_MACD+Signal_Line_Cal']);

fprintf(fileID, '\n\nMACD - najlepszy wynik CALMAR\n\n');
fprintf(fileID, 'Okres 1: \t%i\n', bestCalP1);
fprintf(fileID, 'Okres 2 \t%i\n', bestCalP2);
fprintf(fileID, 'Okres indykatora: \t%i\n', bestCalP3);
fprintf(fileID, 'Zysk skumulowany: \t%0.2f\n', profit);
fprintf(fileID, 'Calmar: \t%0.2f\n', Calmar);
fprintf(fileID, 'Liczba otwartych pozycji dlugich: \t%i\n', iL);
fprintf(fileID, 'Liczba otwartych pozycji krotkich: \t%i\n', iS);

fclose(fileID);

close all;