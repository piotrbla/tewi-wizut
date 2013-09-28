load wynikiD.mat
step1 = 20;
step2 = 50;
A = cumulativeReturnsPerCandle(1020:step2:end,10:step1:end);
h = mesh(A,'EdgeColor','black');
set(h,'XData',get(h,'XData')*step1);
set(h,'YData',get(h,'YData')*step2);
set(h,'YData',get(h,'YData')+1000);
% 
xlabel('length of test period');
ylabel('candles count');
zlabel('cumulative return');
view(33, 52)

set(gcf, 'Position', [200 200 640 480])
set(gcf, 'PaperPositionMode','auto')
print(gcf,'-dpng', '-r0','cumulativeReturnsPerCandleD')