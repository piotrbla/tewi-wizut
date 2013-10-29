clc
close
clear

ma=5;
mb=1;
mc=47;
md=5;

CHFJPY;
C = C(size(C,1)-5000:end,:);
rynek = 'chfjpy';


S1a(C,ma,rynek)
S1b(C,mb,rynek)
S1c(C,mc,rynek)
S1d(C,md,rynek)
S1s(C,ma,mb,mc,md,rynek)

table_to_latex(rynek)