    
fileID = fopen('wyniki4_Sum.txt','w');

for i = 1:51
    tmpF = fopen(['EURUSD4_bySum_' num2str(i) '.txt']);
    D = textscan(tmpF,'%s','delimiter','\n');
    A = D{1};
    if i==1
        fprintf(fileID,'%s\n%s\n',A{1}, A{2});
    else
        fprintf(fileID,'%s\n',A{2});
    end
    fclose(tmpF);
end

fclose(fileID);