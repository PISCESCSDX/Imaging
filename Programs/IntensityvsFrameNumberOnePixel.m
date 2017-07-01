function IntensityvsFrameNumberOnePixel(filebase,X,Y)
% Creates a graph of intensity vs frame number for a specific pixel from
% the camera.
% The filebase is the file name minus its extension
% X and Y are the coordinates of the pixel
    
filename = [filebase '.cine'];
%Stores info about the video in an "info" class. Access with
%"info.NumFrames", etc.
info = cineInfo(filename);
N = info.NumFrames;
frames = 1:N;
means = zeros(1,N);
%==========================================================================
%-------------------------------------------------------- Calculate Average
disp('*** Calculating averages');
for i=1:N
    disp_num(i,N);
    pic = double(cineRead(filename, i));
    means(1,i) = pic(X,Y);
end

plot(frames,means);
xlabel('Frame Number');
ylabel('Average Intensity');
title(['Magnetic Field vs Average Intensity at Pixel X = ' num2str(X) ' Y = ' num2str(Y)]);



end

