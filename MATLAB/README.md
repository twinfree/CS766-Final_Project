
GenerateLabeledTrainingData.m is a script that computes a set of tumor-labeled radiographs from a 4D CT volume and a 4D tumor mask. This script was used to generate the images in
Images/TrainingData and labels in Images/TrainingLabels.

Network_Training.m is used to inialize and train a convolutional neural network for semantic segmentation using SegNet architecture. This script requires the user to input 
a path to a directory containing training Images, and another containing training labels. Note: Network training can take up to 24 hours. As such, a pretrained network for 2D
tumor segmentation that was trained using the data in {CS766-Final_project/TrainingImages, CS766-Final_project/TrainingLabels} is provided (SegNet2_600epochs.mat).

segmentImages.m takes a segmentation CNN from the workspace and uses it to segment a stack of 2D radiographs from the workspace. 

Triangulate.m is a script for triangulating the tumors 3D position from the 2D positions on the detector. The 2D positions can be calculated from the segmented images using region props. In the algorithm, we use siddons ray tracing algorithm to shoot back a ray from the 2D positions on the detectors. As the ray travels it votes for each pixel it intersects. This is done for the 5 most recent radiographs, and the pixel with the most votes from the 5 rays is chosen as the 3D position. An example of this is shown in the final project presentation.
