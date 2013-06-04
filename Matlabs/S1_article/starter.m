clc
close
clear

ma=24;
mb=6;
mc=6;
md=21;

EURJPY60;
rynek = 'eurjpy';


S1a(C,ma,rynek)
S1b(C,mb,rynek)
S1c(C,mc,rynek)
S1d(C,md,rynek)
S1s(C,ma,mb,mc,md,rynek)

table_to_latex(rynek)