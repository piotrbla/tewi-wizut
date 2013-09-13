function [ par ] = wczytajCSV( file_name, numOfVariables )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

personalFileID = fopen(file_name);
fgetl(personalFileID);
par=[];
fileFormat = [repmat('%f;', 1, numOfVariables) '%f\n'];

while ~feof(personalFileID)
    temp = fscanf(personalFileID, fileFormat);
    if ~isempty(temp)
        par(end+1,:)=temp;
    end
end
fclose(personalFileID);

end

