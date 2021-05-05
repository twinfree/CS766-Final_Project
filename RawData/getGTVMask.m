function mask=getGTVMask(structinfo, CT_Grid_Vectors, roi)
mask = zeros(512, 512, 78);
numItems = length(fieldnames(structinfo.ROIContourSequence.(['Item_' num2str(roi)]).ContourSequence));
for i = 1:numItems
cData = structinfo.ROIContourSequence.(['Item_' num2str(roi)]).ContourSequence.(['Item_' num2str(i)]).ContourData;
numP = structinfo.ROIContourSequence.(['Item_' num2str(roi)]).ContourSequence.(['Item_' num2str(i)]).NumberOfContourPoints;
sliceLocation = find(cData(3) == CT_Grid_Vectors.z);
cData = reshape(cData, [3 numP]);
cData(1,:) = interp1(CT_Grid_Vectors.x, 1:512, cData(1,:));
cData(2,:) = interp1(CT_Grid_Vectors.y, 1:512, cData(2,:));
mask(:,:,sliceLocation) = poly2mask(cData(1,:), cData(2,:), 512, 512);
end
end