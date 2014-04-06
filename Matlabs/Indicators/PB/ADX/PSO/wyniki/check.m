fid = fopen('wyniki_Sum_particle8.txt');
out2=textscan(fid, '%d%s%d%s%d%s%f%f%d%d%d%f%f%d%d%f\n', 'delimiter', ';');
fclose(fid);
out2{1,16};
dataLength = length(out2{1,16});
sumReturns = zeros(1, dataLength );
sumReturns(1) = out2{1,16}(1);
for i=2:dataLength 
    sumReturns(i) = sumReturns(i-1) + out2{1,16}(i);
end
plot(sumReturns);
