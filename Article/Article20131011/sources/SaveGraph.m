function [ ] = SaveGraph( sumR1a, file_name )
hFig = figure;
plot(sumR1a);
xlabel('Candles count');
ylabel('Cumulative profit');
set(hFig, 'Position', [200 200 640 480])
set(hFig, 'PaperPositionMode','auto')
print(hFig,'-dpng', '-r0',file_name)
end

