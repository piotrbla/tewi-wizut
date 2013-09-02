load ('cadchf60');
pip = 0.0001; % wielkosc pipsa na danym rynku
spread = 8 * pip; % spread dla rynku
file_name = 'cadchf60';
disp(['BADANIE RYNKU ', file_name, ' strategi¹ S4L >>']);
S4L_clear
disp(['BADANIE RYNKU ', file_name, ' strategi¹ S4s >>']);
load ('cadchf60');
S4s_clear

load ('nzdjpy60');
pip = 0.01; % wielkosc pipsa na danym rynku
spread = 6 * pip; % spread dla rynku
file_name = 'nzdjpy60';
disp(['BADANIE RYNKU ', file_name, ' strategi¹ S4L >>']);
S4L_clear
disp(['BADANIE RYNKU ', file_name, ' strategi¹ S4s >>']);
load ('nzdjpy60');
S4s_clear

load ('usdcad60');
pip = 0.0001; % wielkosc pipsa na danym rynku
spread = 4 * pip; % spread dla rynku
file_name = 'usdcad60';
disp(['BADANIE RYNKU ', file_name, ' strategi¹ S4L >>']);
S4L_clear
disp(['BADANIE RYNKU ', file_name, ' strategi¹ S4s >>']);
load ('usdcad60');
S4s_clear