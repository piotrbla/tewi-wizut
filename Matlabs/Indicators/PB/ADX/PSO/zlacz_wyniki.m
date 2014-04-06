    

for iParticle = 1:20
	fileID = fopen(['wyniki_Sum_particle' num2str(iParticle) '.txt'], 'w');
	for i = 1:51%    name = ['EURUSD4_bySum_' num2str(kk) '_particle_' num2str(iParticle)];
		tmpF = fopen(['EURUSD4_bySum_' num2str(i) '_particle_' num2str(iParticle) '.txt']);
		D = textscan(tmpF,'%s','delimiter','\n');
		A = D{1};
% 		if i==1
% 			fprintf(fileID,'%s\n%s\n',A{1}, A{2});
% 		else
% 			fprintf(fileID,'%s\n',A{2});
% 		end
        fprintf(fileID,'%s\n',A{1});
		fclose(tmpF);
    end
    fclose(fileID);
end

