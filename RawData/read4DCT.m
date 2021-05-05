%script for reading 4DCT
numSlices = 78;
numPhases = 10;
CT_4D = zeros(512,512,numSlices,numPhases);
for i = 1:numSlices
    for phase = 1:numPhases
        if phase < 10
            info = dicominfo(['CT.TestMATCH.Image ' num2str(i) '.000' num2str(phase) '.dcm']);
        else
            info = dicominfo(['CT.TestMATCH.Image ' num2str(i) '.dcm']);
        end
        phi = str2double(info.SeriesDescription(end-2:end-1));
        slice = dicomread(info);
        slice = double(slice);
        slice = info.RescaleSlope*(slice + info.RescaleIntercept);
        CT_4D(:,:,i,phi/10+1) = slice;
    end
end