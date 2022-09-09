function [ g ] = iter_threshold(grayImage)
[pixelCount, grayLevels] = imhist(grayImage);
Id = im2double(grayImage);
Imax = max(Id(:));
Imin = min(Id(:));
T = 0.5*(min(Id(:)) + max(Id(:)));
deltaT = 0.01;
done = false;
counter = 1;
while counter<10
	savedThresholds(counter) = T;	
	g = Id >= T;
	Tnext = 0.5*(mean(Id(g)) + mean(Id(~g)));
	done = abs(T - Tnext) < deltaT;
	T = Tnext;
	counter = counter + 1;
end