%Script for generating Labeled DRR's using the Radon transform. 
%%Usage:
%load a 4D CT and a 4D tumor mask into the workspace and name them "CT_4D"
%and "mask". Define the projection angles and the geometry of the scan
%(SID,detector pixel spacing, isocenter position etc.). Then run.
%% Inputs
% load CT_4D
% load 4D_mask
SID = 1800;
SAD = 1000;
mag = SID/SAD;
pix_dim_image_plane = .388; 
pix_dim_obj_plane = pix_dim_image_plane / mag;
ct_axial_spacing = 1.0484; 
thetas = 0:3.6:359;

%% 
iso = zeros(512,512,78);
iso(127,256,34) = 1;
iso = iso(:,:,22:46);
iso = imresize3(iso, [512 512 348], 'Method', 'nearest');
trainingImages = zeros(324,324,1000);
trainingLabels = zeros(324,324,1000);
numAngles = length(thetas);
%


for theta_ind = 1:numAngles
theta = thetas(theta_ind);
for phase = 1:10
CT3 = CT_4D(:,:,22:46,phase);
mask3 = mask(:,:,22:46,phase);
mask3 = imresize3(mask3, [512 512 348], 'Method', 'nearest');
CT3 = imresize3(CT3, [512 512 348], 'Method', 'cubic');


numProj = 2*ceil(norm(size(CT3(:,:,1))-floor((size(CT3(:,:,1))-1)/2)-1))+3;
a = .02;
CT3 = a * CT3 / 1000 + a;
Ra = zeros(size(CT3,3), numProj);
iso_proj = zeros(size(CT3,3), numProj);
mask_proj = zeros(size(CT3,3), numProj);
for slice = 1:size(CT3,3)
Ra(slice,:) = radon(CT3(:,:,slice), -theta);
iso_proj(slice,:) = radon(iso(:,:,slice), -theta);
mask_proj(slice,:) = radon(mask3(:,:,slice), -theta);
end
% clear mask3
% clear CT3
mask_proj = logical(mask_proj);
Ra = exp(-Ra);
%determine width
width = sqrt(2) - abs(mod(theta, 90) - 45)/45*(sqrt(2)-1);
numProj = round(width*512*ct_axial_spacing / pix_dim_obj_plane);
Ra = imresize(Ra, [348 numProj], 'Method','bilinear');
mask_proj = imresize(mask_proj, [348 numProj], 'Method', 'nearest');
iso_proj = imresize(iso_proj, [348 numProj], 'Method', 'nearest');
iso_proj = regionprops(iso_proj~=0, 'Centroid');
iso_proj = floor(iso_proj.Centroid);
mask_proj = mask_proj(iso_proj(2)-161:iso_proj(2)+162, iso_proj(1)-161:iso_proj(1)+162);
Ra = Ra(iso_proj(2)-161:iso_proj(2)+162, iso_proj(1)-161:iso_proj(1)+162);
Ra = uint16(round(65535*Ra));

trainingImages(:,:,(phase-1)*numAngles+theta_ind) = Ra;
trainingLabels(:,:,(phase-1)*numAngles+theta_ind) = mask_proj;
end
disp(theta_ind)
end