%% Perform Segmentation on Live Radiographs Using CNN
%load MATLAB\segNet2_600epochs.mat %- load in CNN
%load MATLAB\Radiographs %-  load stack of 2D radiographs
sigma = 4; %intratreatment images contain Poisson noise which must be smoothed
segmented = zeros(size(Radiographs));
for i = 1:size(Radiographs,1)
R = Radiographs(:,:,i);
R = (R - mean(R(:))) / std(R(:)); % normalize to mean 0 std 1
R = imgaussfilt(R,sigma);% smooth Poisson noise
segmented(:,:,i) = semanticseg(R, segnet);
%imwrite(R, ['MATLAB\radiographs\image_' num2str(i) '.jpg'], 'BitDepth' ,16);

end
