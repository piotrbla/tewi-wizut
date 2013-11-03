function [ Calmar ] = obliczCalmara( sumR )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
recordReturn = 0;  % rekord zysku
recordDrawdown = 0;  % rekord obsuniecia

for i=1:length(sumR)
    if sumR(i)>recordReturn
        recordReturn=sumR(i);
    end
    
    if sumR(i)-recordReturn<recordDrawdown
        recordDrawdown=sumR(i)-recordReturn;  
    end
end

Calmar=-sumR(end)/recordDrawdown;

end

