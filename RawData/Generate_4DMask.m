%% Generate Mask from Contour set
mask = zeros(512, 512, 78, 10);
for phase = 1:10
structinfo = dicominfo(['D:\CS766_FinalProject\MATCH upload\MATCH upload\Planning CT and treatment plans\4DCT\TestMATCH\RS.TestMATCH.4D_MOVING_' num2str((phase-1)*10) '%.dcm']);
mask_slice = getGTVMask(structinfo, CT_Grid_Vectors, 1);
mask(:,:,:,phase) = mask_slice;
end
