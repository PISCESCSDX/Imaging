function MeanIntensityOnePixelvsB(filebase,Ii,If,dI,X,Y)
% This function plots the magnetic field against the average intensity of
% one pixel in the camera
% Ii and If are the initial and final values for current. dI is the spacing
% between values of current recorded in the scan
% The filebase is the file name minus its number and extension
% X and Y are the coordinates of the pixel

means = zeros((If-Ii)/dI+1,1);
B = zeros((If-Ii)/dI+1,1);
for Ic = (Ii:dI:If)
    if (Ic == Ii)
        disp('*** calculating averages')
    end
    filename = [filebase num2str(Ic) '.cine'];
    disp([num2str(Ic/dI) '/' num2str(If/dI)]);
    %Stores info about the video in an "info" class. Access with
    %"info.NumFrames", etc.
    info = cineInfo(filename);

    % NOTE: To speed up analysis, devide "info.NumFrames" by a scalar.
    % Doing this may decrease the precision of the analysis
    N = info.NumFrames/100;

    %==========================================================================
    %-------------------------------------------------------- Calculate Average
    movstat.avg = 0;
    for i=1:N
        disp_num(i,N);
        pic = double(cineRead(filename, i));
        movstat.avg = movstat.avg + pic;
    end
    means(((Ic-Ii)/dI)+1,1) = mean(movstat.avg(X,Y));
    B(((Ic-Ii)/dI)+1,1) = 3.015*Ic+10;
end
plot(B,means);
xlabel('B');
ylabel('Average Intensity');
title(['Average Intensity vs Magnetic Field at Pixel X = ' num2str(X) ' Y = ' num2str(Y)]);

end