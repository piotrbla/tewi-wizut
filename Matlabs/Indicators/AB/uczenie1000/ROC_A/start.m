function [] = start(nr_testu)


%nr_testu = 3;

eurusd221012;
file_name = ['tewiROC' num2str(nr_testu) 'ab'];
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
[roj, ~, l_op, zysk, Calmar] = PSO(opcje,C,pocz,kon,spread);

temp_p = roj.best_position;

% zapis optymalnych parametrów
fileID =fopen([file_name 'opt_param.txt'],'w');
fprintf(fileID, '%i\t %i-%i', nr_testu, pocz, kon);
fprintf(fileID, '\t%0.4f\t%0.4f\t%0.4f\t%0.4f\t%0.4f\t%0.4f', temp_p(1), ...
    temp_p(2),temp_p(3),temp_p(4),temp_p(5),temp_p(6));
fclose(fileID);

[roj.best_position_value, zysk]

[ zysk100, Ca100, l100] = ROCa( C, poczt, kon1, spread,...
    temp_p(1), temp_p(2), temp_p(3), temp_p(4), temp_p(5), temp_p(6));
[ zysk200, Ca200, l200] = ROCa( C, poczt, kon2, spread,...
    temp_p(1), temp_p(2), temp_p(3), temp_p(4), temp_p(5), temp_p(6));
[ zysk500, Ca500, l500] = ROCa( C, poczt, kon5, spread,...
    temp_p(1), temp_p(2), temp_p(3), temp_p(4), temp_p(5), temp_p(6));
%
[zysk100 zysk200 zysk500]

% zapis do pliku
fileID =fopen([file_name '.txt'],'w');
fprintf(fileID, '%i\t %i-%i', nr_testu, pocz, kon);
fprintf(fileID, '\t%0.4f\t%0.4f', zysk, Calmar)
fprintf(fileID, '\t%i\t%0.4f\t%0.4f\t%0.4f', l_op, zysk100, zysk200, zysk500); 
fclose(fileID);

% zapis calmarow
fileID =fopen([file_name 'calmars.txt'],'w');
fprintf(fileID, '%i\t %i-%i', nr_testu, pocz, kon);
fprintf(fileID, '\t%0.6f\t%0.6f\t%i\n', zysk100, Ca100, l100);
fprintf(fileID, '\t%0.6f\t%0.6f\t%i\n', zysk200, Ca200, l200);
fprintf(fileID, '\t%0.6f\t%0.6f\t%i\n', zysk500, Ca500, l500);
fclose(fileID);