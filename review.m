clear all;
clc;
close all;

%Get the directory of the images
srcFiles = dir('Dataset/*.jpg'); 

for i = 1 : length(srcFiles)
    
img=strcat('Dataset/',srcFiles(i).name);
I = imread(img);
I=imresize(I,[500 500]);

% apply guassian filter
I=rgb2gray(I);
J=imgaussfilt(I,0.5);

% Apply Iterative thresholding
iterthreshold=iter_threshold(J);

%complementing the thresholded image
I=imcomplement(iterthreshold);

%remove the lung border i.e.., the ribcage and muscle
I=imclearborder(I);


%fill the holes of the above image to get PT1
I=imfill(I,'holes');
PT1=I;

%mapping PT1 with input image
I=immultiply(J,I);


%Get the threshold value for thresholding above step image by CLAHE
I=adapthisteq(I);
level = graythresh(I);
I = imbinarize(I,level);

%complement the otsu's thresholded image
I=imcomplement(I);
%PT2 is this image
PT2=I;


%map PT1 and PT2 and fill the holes and remove small connected pixels and
%apply morphological closing to get the ROI
K=immultiply(PT1,PT2);

I=ExtractNLargestBlobs(K,1);
SE=strel('square',2);
I=imclose(I,SE);
I=imfill(I,'holes');
ROI=I;

%This is the segmented image mapped with ROI and original image
I=immultiply(I,J);


%Extract features from the ROI
area=regionprops(ROI,'area');
conv_Area=regionprops(ROI,'ConvexArea');
equi_diameter=regionprops(ROI,'EquivDiameter');
eccentricity=regionprops(ROI,'eccentricity');
solidity=regionprops(ROI,'Solidity');
perimeter=regionprops(ROI,'Perimeter');
standard_deviation=std2(I);

if i<length(srcFiles)
feature(i,:)=[area.Area,conv_Area.ConvexArea,eccentricity.Eccentricity,equi_diameter.EquivDiameter,perimeter.Perimeter,solidity.Solidity,standard_deviation];
if i>5      %modify this
    y(i,1)=0;    % 0 indicates no pneumothorax
else
    y(i,1)=1;    % 1 indicates pneumothorax
end
xlswrite('features.xls',[feature]);
else
    %Last images in the folder is the test input to test
    j=i-length(srcFiles)+1;
    sample(j,:)=[area.Area,conv_Area.ConvexArea,eccentricity.Eccentricity,equi_diameter.EquivDiameter,perimeter.Perimeter,solidity.Solidity,standard_deviation];
end
end

%Training model
net = fitnet(10,'trainlm');
net.divideParam.trainRatio=.7;
net.divideParam.valRatio=.15;
net.divideParam.testRatio=.15;
[net, pr]=train(net,feature',y');

%Test with input
output=net(sample')';
output1=round(output,0);

%Determine whether pneumothorax or not
if ((output1<0) || (output1==0))
    fprintf('The test CT does not have pneumothorax\n');
else 
    fprintf('The test CT has pneumothorax\n');
end

