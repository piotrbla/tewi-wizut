close all
loopEnd=800;

load ('cadchf60');
pip = 0.0001; % wielkosc pipsa na danym rynku
spread = 8 * pip; % spread dla rynku
file_name = 'cadchf60';
disp(['BADANIE RYNKU ', file_name, ' strategia S4{A,B, C, D} >>']);
S4ABCD

load ('nzdjpy60');
pip = 0.01; % wielkosc pipsa na danym rynku
spread = 6 * pip; % spread dla rynku
file_name = 'nzdjpy60';
disp(['BADANIE RYNKU ', file_name, ' strategia S4{A,B, C, D} >>']);
S4ABCD

load ('usdcad60');
pip = 0.0001; % wielkosc pipsa na danym rynku
spread = 4 * pip; % spread dla rynku
file_name = 'usdcad60';
disp(['BADANIE RYNKU ', file_name, ' strategia S4{A,B, C, D} >>']);
S4ABCD