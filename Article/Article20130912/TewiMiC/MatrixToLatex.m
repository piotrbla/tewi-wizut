function [ ] = MatrixToLatex( file_name, Matrix )

%%%%%%%%%%%%% LATEX %%%%%%%%%%%%%%%%
pocz_table = '\\begin{table} \n \\begin{tabular}{|l|l|l|l|l|l|} \n \\hline test size & profit & profit per canlde & Calmar & Open positions & Percentage [\\%%]\\\\ \\hline  \n';
kon_table = '\\hline \\end{tabular} \n \\end{table}';

mid_table = [];

for i=1:length(Matrix)
    for j=1:size(Matrix,2)-1
        mid_table = [mid_table num2str(Matrix(i,j)) ' & '];
    end
    mid_table = [mid_table num2str(Matrix(i,end)) ' \\\\ \n '];
end




fileID = fopen(file_name,'w');
fprintf(fileID,pocz_table);
fprintf(fileID,mid_table);
fprintf(fileID,kon_table);
fclose(fileID);


end

