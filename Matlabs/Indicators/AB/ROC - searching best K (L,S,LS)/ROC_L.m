function [ Sum, sumR, ROC_vec, Calmar, iL] = ROC_L( C, k, spread )

pocz = k+2;
kon = size(C,1)-1;
iL = 0; % przekroczenie 0 w górê - kupno (L)
sumR = zeros(1,size(C,1));
R = zeros(1,size(C,1));
ROC_vec = zeros(1,kon-k+1);
ROC_vec(pocz-1) = ((C(pocz-1,4) - C(pocz-1-k,4))/C(pocz-1-k,4))*100;

recordReturn=0;  %rekord zysku
recordDrawdown=0;  %rekord obsuniecia
LastPos = 0;

for i=pocz:kon
    ROC_vec(i) = ((C(i,4) - C(i-k,4))/C(i-k,4))*100;
    if ROC_vec(i)*ROC_vec(i-1)<=0   % przeciêcie krzywej ROC z zerem
        if ROC_vec(i-1)<ROC_vec(i)  % warunek kupna
            LastPos = C(i+1,1);   % otworzenie L
            iL = iL + 1;
        elseif ROC_vec(i-1)>ROC_vec(i)
            if iL>0
                R(i) = C(i+1,4)-LastPos-spread;  % zamkniêcie L
            end
        end
    end
    
    sumR(i) = sum(R(pocz:i));
    
    if sumR(i)>recordReturn
        recordReturn=sumR(i);
    end
    
    if sumR(i)-recordReturn<recordDrawdown
        recordDrawdown=sumR(i)-recordReturn;
    end
end

Calmar=-sumR(kon)/recordDrawdown;
Sum = sumR(kon);
end