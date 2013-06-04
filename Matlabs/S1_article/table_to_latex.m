function [] = table_to_tex(rynek)
%%%%%%%%%%%%% LATEX %%%%%%%%%%%%%%%%
pocz_table = '\\begin{table} \n \\begin{center} \n \\begin{tabular}{|l|l|l|l|l|} \n \\hline \\textbf{strategy} & \\textbf{profit} & \\textbf{bestCalmar} & \\textbf{bestMALength} & \\textbf{la} \\\\ \\hline  \n';
kon_table = '\\hline \\end{tabular} \n \\end{center} \n \\end{table}';

A = load(['texRa_' rynek '.txt']);
temp = num2str(A);
midda_table = ['S1a & ' regexprep(temp,'( )+',' & ') '\\\\ \\hline \n'];

B = load(['texRb_' rynek '.txt']);
temp = num2str(B);
middb_table = ['S1b & ' regexprep(temp,'( )+',' & ') '\\\\ \\hline \n'];

C = load(['texRc_' rynek '.txt']);
temp = num2str(C);
middc_table = ['S1c & ' regexprep(temp,'( )+',' & ') '\\\\ \\hline \n'];


D = load(['texRd_' rynek '.txt']);
temp = num2str(D);
middd_table = ['S1d & ' regexprep(temp,'( )+',' & ') '\\\\ \\hline \n'];

S = load(['texRs_' rynek '.txt']);
temp = num2str(S);
midds_table = ['S1s & ' regexprep(temp,'( )+',' & ') '\\\\ \n'];



fileID = fopen(['table_tex_' rynek '.txt'],'w');
fprintf(fileID,pocz_table);
fprintf(fileID,midda_table);
fprintf(fileID,middb_table);
fprintf(fileID,middc_table);
fprintf(fileID,middd_table);
fprintf(fileID,midds_table);
fprintf(fileID,kon_table);
fclose(fileID);