function playBscan(filebase,Ii,If, dI)
% Creates a video of the average pixel intensity of the plasma as it is
% subjected to an increasing or decreasing magnetic field. 
% Ii and If are the initial and final values for current. dI is the spacing
% between values of current recorded in the scan
% The filebase is the file name minus its number and extension

frames = cell((If-Ii)/dI+1,1);

for Ic = (Ii:dI:If)
    if (Ic == Ii)
        disp('*** calculating averages')
    end
    filename = [filebase num2str(Ic) '.cine'];
    disp([num2str(Ic/dI) '/' num2str(If/dI)]);
    %Stores info about the video in an "info" class. Access with
    %"info.NumFrames", etc.
    info = cineInfo(filename);

    N = info.NumFrames;

    %==========================================================================
    %-------------------------------------------------------- Calculate Average
    movstat.avg = 0;
    for i=1:N
        disp_num(i,N);
        pic = double(cineRead(filename, i));
        movstat.avg = movstat.avg + pic;
    end
    frames{((Ic-Ii)/dI)+1,1} = movstat.avg;
end

x=1:size(movstat.avg,1);
y=1:size(movstat.avg,2);

%Number of Smoothing Pixels
sm = 2;

%Display Controls
 zoom = 1;

% Video using PCOLOR
set(gcf,'PaperUnits','centimeters','PaperType','a4letter', ...
  'PaperPosition', [1 1 zoom*20 zoom*7],'Color','w');
wysiwyg_vid(1000)
clf;

N = (If-Ii)/dI; % Number of frames that you want to make the movie from

% Preallocate movie structure.
mov(1:N) = struct('cdata', [], 'colormap', []);

for i=1:N
  %Creates video for raw data
  pic = cell2mat(frames(i));
  pic = smoothBrochard(smoothBrochard(pic,sm)',sm)';
  pcolor(x,y,pic)
  shading flat
  axis square
  colormap(gray)
  set(gca,'zLim',[0 1000])
  mkplotnice('x (pixel)', 'y (pixel)', 12, '-27', '-32');
  puttextonplot(gca, [0 1],5,-15,['B = ' num2str(3.015*(Ii + dI*i)+10)],0,12,'w');
  axis tight
  set(gca,'nextplot','replacechildren');
  mov(i) = getframe(gcf);
  pause(0.001); clf
end
%movie2avi(mov, 'Bscan.avi', 'compression', 'None', 'fps', 10);

end

