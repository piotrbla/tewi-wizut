function [ ] = ConfusionMatrixToLatex( file_name, Matrix )

%TP FP
%FN TN

%%%%%%%%%%%%% LATEX %%%%%%%%%%%%%%%%
pocz_table = '\\begin{table} \n \\begin{tabular}{|l|l|l|} \n \\hline  & actual = profit & actual = loss\\\\ \\hline  \n';
firstLine_table = ['prediction = profit & ' num2str(Matrix(1,1)) ' & ' num2str(Matrix(1,2)) '\\\\ \\hline  \n'];
secondLine_table = ['prediction = loss & ' num2str(Matrix(2,1)) ' & ' num2str(Matrix(2,2)) '\\\\ \\hline  \n'];
kon_table = '\\end{tabular} \n \\end{table}';

fileID = fopen(file_name,'w');
fprintf(fileID,pocz_table);
fprintf(fileID,firstLine_table);
fprintf(fileID,secondLine_table);
fprintf(fileID,kon_table);
fclose(fileID);


end

