clc
close
clear

% skrypt do ³¹czenia wyników
id = fopen('wyniki_laczne.txt','w');

for i=4:33
    plik = sprintf('tewiROC%iab.txt',i);
    id_t = fopen(plik);
    tresc = fscanf(id_t,'%c');
    fprintf(id,tresc);
    fprintf(id,'\n');
    fclose(id_t);
end

fclose(id);


% skrypt do ³¹czenia wyników
id = fopen('wyniki_laczne_opt.txt','w');

for i=4:33
    plik = sprintf('tewiROC%iabopt_param.txt',i);
    id_t = fopen(plik);
    tresc = fscanf(id_t,'%c');
    fprintf(id,tresc);
    fprintf(id,'\n');
    fclose(id_t);
end

fclose(id);