%% Description
% The goal is to triangulate the tumors 3D position from its centroid
% positions on the face of the detector. Since there is noise in the
% measurement of the centroid, we use more than 2 frames to triangulate the 3D position.
% Using siddons ray tracing algorithm, we shoot back a ray from the
% centroid position on each detector. As the ray travels it deposits a vote
% in each pixel it intersects, weighted by the length of the intersection.
% This is repeated for each of the 5 rays and the pixel with the most votes
% is chosed as the tumor 3D position.
%%
load MATLAB\centroids.mat %2D location of centroids on detector. Is calculated from segmented images using region props
numFrames = 5; %number of frames used for triangulation
ps = zeros(3, 1610 - numFrames + 1);
for rad = numFrames:1610
    p = get_p(Rad_processed(rad-(numFrames-1):rad,:),centroids(:,rad-(numFrames-1):rad),...
        SAD,SID, numFrames);
    ps(:,rad-(numFrames-1)) = p;
end
%% Functions
function p = get_p(Rads, C, SAD, SID, numFrames)
A = zeros(200,200);
[X, Y] = meshgrid(-4.95:9.9/(size(A,1)-1):4.95,-4.95:9.9/(size(A,1)-1):4.95);
for i = 1:numFrames
info1 = Rads{i,2};
theta1 = -info1.GantryAngle;
R = [cosd(theta1) -sind(theta1);sind(theta1) cosd(theta1)];
x1 = R * [0; SAD]; %x1 = [x1; 0];
CoM1 = C(:,i) - [160.5 ;160.5];
detector_normal = cat(1,R * [0 ; SAD-SID],0);
u1 = detector_normal + cat(1, CoM1(1)*R*[1;0], -CoM1(2)); 
z = u1(3);
u1 = u1(1:2);
%[X, Y] = meshgrid(-4.95:.1:4.95,-4.95:.1:4.95);
firstPlanes = -5; lastPlanes = 5;

A = rayTrace(u1, x1, [firstPlanes firstPlanes], [lastPlanes lastPlanes], ...
    A, 10./size(A), size(A,1)+1);
end
G = fspecial('gaussian', 200, 50);
temp = imgaussfilt(A,1) .* G;
[ypix,xpix] = find(temp == max(temp(:)),1,'first');
y = Y(ypix,xpix);
x = X(ypix,xpix);
alpha = (x - x1(1)) / (u1(1) - x1(1));
z_a = alpha*z;

p = [x; y; z_a];
%imagesc(temp)
end
function A=rayTrace(del_xy, xray_source, firstPlanes, lastPlanes, A, VoxelSpacing, num_xy_planes)
dif = (del_xy - xray_source);
alpha_0 = (firstPlanes - xray_source) ./ dif;
alpha_f = (lastPlanes - xray_source) ./ dif;
alpha_xyz_min = min([alpha_0 alpha_f], [] ,2);
alpha_xyz_max = max([alpha_0 alpha_f], [] ,2);
alpha_min = max(alpha_xyz_min);
alpha_max = min(alpha_xyz_max);
if xray_source(1) < del_xy(1)
    if alpha_min == alpha_xyz_min(1)
        i_min = 2;
    else
        i_min = ceil((xray_source(1) + alpha_min*dif(1) - firstPlanes(1)) / VoxelSpacing(1)) + 1;%validate
    end
    if alpha_max == alpha_xyz_max(1)
        i_max = num_xy_planes;
    else
        i_max = floor((xray_source(1) + alpha_max*dif(1) - firstPlanes(1)) / VoxelSpacing(1)) + 1;%validate
    end
else
    if alpha_min == alpha_xyz_min(1)
        i_max = num_xy_planes-1;
    else
        i_max = floor((xray_source(1) + alpha_min*dif(1) - firstPlanes(1)) / VoxelSpacing(1)) + 1;%validate
    end
    if alpha_max == alpha_xyz_max(1)
        i_min = 1;
    else
        i_min = ceil((xray_source(1) + alpha_max*dif(1) - firstPlanes(1)) / VoxelSpacing(1)) + 1;%validate
    end
end
if xray_source(2) < del_xy(2)
    if alpha_min == alpha_xyz_min(2)
        j_min = 2;
    else
        j_min = ceil((xray_source(2) + alpha_min*dif(2) - firstPlanes(2)) / VoxelSpacing(2))  + 1;%validate
    end
    if alpha_max == alpha_xyz_max(2)
        j_max = num_xy_planes;
    else
        j_max = floor((xray_source(2) + alpha_max*dif(2) - firstPlanes(2)) / VoxelSpacing(2)) + 1;%validate
    end
else
    if alpha_min == alpha_xyz_min(2)
        j_max = num_xy_planes-1;
    else
        j_max = floor((xray_source(2) + alpha_min*dif(2) - firstPlanes(2)) / VoxelSpacing(2)) + 1;%validate
    end
    if alpha_max == alpha_xyz_max(2)
        j_min = 1;
    else
        j_min = ceil((xray_source(2) + alpha_max*dif(2) - firstPlanes(2)) / VoxelSpacing(2)) + 1;%validate
    end
end
i_array = i_min-1:i_max-1;
j_array = j_min-1:j_max-1;
if xray_source(1) < del_xy(1)
    alpha_x = (firstPlanes(1) + i_array*VoxelSpacing(1) - xray_source(1)) ./ dif(1);
else
    alpha_x = (firstPlanes(1) + flip(i_array)*VoxelSpacing(1) - xray_source(1)) ./ dif(1);
end
if xray_source(2) < del_xy(2)
    alpha_y = (firstPlanes(2) + j_array*VoxelSpacing(2) - xray_source(2)) ./ dif(2);
else
    alpha_y = (firstPlanes(2) + flip(j_array)*VoxelSpacing(2) - xray_source(2)) ./ dif(2);
end
alpha_xyz = unique([alpha_x alpha_y]);
temp = (alpha_xyz + circshift(alpha_xyz,1))/2;
temp = temp(2:end);
i_m = floor( (xray_source(1) + temp*dif(1) - firstPlanes(1)) ./ VoxelSpacing(1) ) + 1; %+1?
j_m = floor( (xray_source(2) + temp*dif(2) - firstPlanes(2)) ./ VoxelSpacing(2) ) + 1; %+1?
L = (alpha_xyz - circshift(alpha_xyz,1)) * norm(dif);
L = L(2:end); L = L/sum(L);
temp = sub2ind(size(A), j_m,i_m);
A(temp) = A(temp) + L;
end