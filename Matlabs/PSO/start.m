function [] = start(nr_testu)


% nr_testu = 33;

eurusd221012;
file_name = ['tewiMiCD' num2str(nr_testu) 'ab'];
spread = 0.0002;

pocz=(nr_testu-1)*100;
kon=pocz+1000;
poczt=pocz+1000;
kon1=poczt+100;
kon2=poczt+200;
kon5=poczt+500;


opcje = PSODefaultOptions(spread);
timeout = 1;
% definicje funkcji
if(timeout)
    opcje.best_position_timeout = 100;
end


% PSO
[roj, ~, l_op, zysk] = PSO(opcje,C,pocz,kon,spread);

temp_p = roj.best_position;

% zapis optymalnych parametrów
fileID =fopen([file_name 'opt_param.txt'],'w');
fprintf(fileID, '%i\t %i-%i', nr_testu, pocz, kon);
fprintf(fileID, '\t%0.5f\t%0.2f\t%0.2f\t%0.2f', temp_p(1), temp_p(2),temp_p(3),temp_p(4));
fprintf(fileID, '\t%0.5f\t%0.5f\t%0.2f', temp_p(5), temp_p(6),temp_p(7));
fprintf(fileID, '\t%0.2f\t%0.2f\t%0.5f\t%0.5f', temp_p(8), temp_p(9),temp_p(10),temp_p(11));
fclose(fileID);

[zysk roj.best_position_value]

[ zysk100, Ca100, l100] = tewiMiD( C, spread, poczt, kon1, ...
    temp_p(1), temp_p(2), temp_p(3), temp_p(4), temp_p(5),...
    temp_p(6), temp_p(7), temp_p(8), temp_p(9), temp_p(10),...
    temp_p(11));


[zysk100]

% zapis do pliku
fileID =fopen([file_name '.txt'],'w');
fprintf(fileID, '%i\t %i-%i', nr_testu, pocz, kon);
fprintf(fileID, '\t%0.4f\t%0.4f', zysk, roj.best_position_value);
fprintf(fileID, '\t%i\t%0.4f', l_op, zysk100); 
fclose(fileID);
