
GenerateLabeledTrainingData.m is a script that computes a set of tumor-labeled radiographs from a 4D CT volume and a 4D tumor mask. This script was used to generate the images in
Images/TrainingData and labels in Images/TrainingLabels.

Network_Training.m is used to inialize and train a convolutional neural network for semantic segmentation using SegNet architecture. This script requires the user to input 
a path to a directory containing training Images, and another containing training labels. Note: Network training can take up to 24 hours. As such, a pretrained network for 2D
tumor segmentation that was trained using the data in {CS766-Final_project/TrainingImages, CS766-Final_project/TrainingLabels} is provided (SegNet2_600epochs.mat).

segmentImages.m takes a segmentation CNN from the workspace and uses it to segment a stack of 2D radiographs from the workspace. 
