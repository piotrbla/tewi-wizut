function [ ] = SaveGraph( hFig, file_name )
set(hFig, 'Position', [200 200 640 480])
set(hFig, 'PaperPositionMode','auto')
print(hFig,'-dpng', '-r0',file_name)
end

