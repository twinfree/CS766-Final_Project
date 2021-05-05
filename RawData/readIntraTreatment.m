%script for reading in intra-treatment images and dicominfo structs
numImages = 1610;
info = cell(numImages,1);
Images = cell(numImages,1);
for i = 1:numImages
    ind = i-1;
    t1 = '00000';
    t2 = length(num2str(ind));
    t1(6-t2:end) = num2str(ind);
    info{i} = dicominfo([t1 '_masked.dcm']);
    Images{i} = dicomread(info{i});
end