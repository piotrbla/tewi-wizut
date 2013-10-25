function [ ] = MatrixToLatex( file_name, Matrix )

%%%%%%%%%%%%% LATEX %%%%%%%%%%%%%%%%
pocz_table = '\\begin{table} \n \\begin{tabular}{|l|l|} \n \\hline ';
tab0 = '\\multicolumn{2}{|c|}{Results} \\\\ \\hline \n';
tab1 = ['Profit & ' num2str(Matrix(1)) '\\\\ \\hline  \n'];
tab2 = ['Calmar & ' num2str(Matrix(2)) '\\\\ \\hline  \n'];
tab3 = ['MCC & ' num2str(Matrix(3)) '\\\\ \\hline  \n'];
tab4 = ['p1 & ' num2str(Matrix(4)) '\\\\ \\hline  \n'];
tab5 = ['p2 & ' num2str(Matrix(5)) '\\\\ \\hline  \n'];
tab6 = ['p3 & ' num2str(Matrix(6)) '\\\\ \\hline  \n'];
tab7 = ['p4 & ' num2str(Matrix(7)) '\\\\ \\hline  \n'];
tab8 = ['p5 & ' num2str(Matrix(8)) '\\\\ \\hline  \n'];
kon_table = '\\end{tabular} \n \\end{table}';

fileID = fopen(file_name,'w');
fprintf(fileID,pocz_table);

fprintf(fileID,tab0);
fprintf(fileID,tab1);
fprintf(fileID,tab2);
fprintf(fileID,tab3);
fprintf(fileID,tab4);
fprintf(fileID,tab5);
fprintf(fileID,tab6);
fprintf(fileID,tab7);
fprintf(fileID,tab8);

fprintf(fileID,kon_table);
fclose(fileID);


end

