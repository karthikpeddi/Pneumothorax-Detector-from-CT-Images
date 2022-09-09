clear all;
clc;
close all;
srcFiles = dir('Dataset/*.jpg'); 
for i = 1 : length(srcFiles)
img=strcat('Dataset/',srcFiles(i).name);
I = imread(img);
I=imresize(I,[500 500]);


I=rgb2gray(I);
J=imgaussfilt(I,0.5);
figure('name','Original Image');imshow(I);

iterthreshold=iter_threshold(J);
figure('name','Iterative Thresholding');imshow(iterthreshold);

I=imcomplement(iterthreshold);
figure('name','Complemented');imshow(I);

I=imclearborder(I);
figure('name','Lung border removed');imshow(I);

I=imfill(I,'holes');
PT1=I;
figure('name','Holes filled image');imshow(I);

I=immultiply(J,I);
figure('name','Mapped with input image');imshow(I);

I=adapthisteq(I);
level = graythresh(I);
I = imbinarize(I,level);
figure('Name','Otsu Thresholded image'),imshow(I);

I=imcomplement(I);
figure('name','Complement of otsu threshold');imshow(I);
PT2=I;

K=immultiply(PT1,PT2);
figure('name','Mapping of PT1 and PT2');imshow(K);

I=ExtractNLargestBlobs(K,1);
SE=strel('square',2);
I=imclose(I,SE);
I=imfill(I,'holes');
figure('name','Small pieces are removed and closed');imshow(I);
ROI=I;

I=immultiply(I,J);
figure('name','ROI');imshow(I);
end