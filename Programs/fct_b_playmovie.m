function fct_b_playmovie(filebase)
% Jun-07-2013, C. Brandt, San Diego

filename = [filebase '.cine'];
info = cineInfo(filename);
fs = info.frameRate;
dt = 1/fs;

%==========================================================================
% Play movie
%--------------------------------------------------------------------------
savefn = [filebase '_statistics.mat'];
load(savefn);
x=1:size(movstat.avg,1);
y=1:size(movstat.avg,2);

% number of smoothing points
sm = 2;

j=0;
j=j+1; ax{j} = [0.04 0.12 0.42 0.80];
j=j+1; ax{j} = [0.53 0.12 0.42 0.80];

zoom = 1;
% Video using PCOLOR
set(gcf,'PaperUnits','centimeters','PaperType','a4letter', ...
  'PaperPosition', [1 1 zoom*20 zoom*7],'Color','w');
wysiwyg_vid(1000)
clf;

N = 500; % Number of frames that you want to make the movie from
% Preallocate movie structure.
mov(1:N) = struct('cdata', [], 'colormap', []);

for i=1:N
  j=0;
  picraw = double(cineRead(filename, i));
  pic = (picraw - movstat.avg) ./ movstat.std;

  %Creates a video of raw data
%   raw = picraw/5e3;
%   j=j+1; axes('Position',ax{j})
%   gamma = 0.2;
%   J = imadjust(raw,[0 1],[0 1], gamma);
%   pcolor(x,y,J)
%   colormap(gray)
%   shading flat
%   axis square
%   set(gca,'clim', [0.2 1.0])
%   freezeColors
%   mkplotnice('x (pixel)', 'y (pixel)', 12, '-27', '-27');
%   mknicecolorbar('EastOutside','raw image intensity (arb.u.)',12,0.15,0.1,3);
% %   our_colorbar('raw image intensity (arb.u.)',10,9,0.010,-0.00);
%   freezeColors
%   axis tight
%   set(gca,'nextplot','replacechildren');

% Creates a background subtracted video
  j=j+1; axes('Position',ax{j})
  pic = smoothBrochard(smoothBrochard(pic,sm)',sm)';
  pcolor(x,y,pic)
  shading flat
  axis square
  % colormap(pastelldeep(64))
  colormap(gray)
  set(gca,'zLim',[0 1000])
  set(gca,'clim', 4*[-1 1])
  %set(gca,'clim', 1.0*matmax(pic)*[0 1])
  mkplotnice('x (pixel)', '-1', 12, '-27', '-32');
  tstr = ['\tau=' sprintf('%.3f',1e3*((i-1)*dt)) 'ms'];
  puttextonplot(gca, [0 1],5,-15,['#' num2str(i)],0,12,'k');
  puttextonplot(gca, [0 1],5,-35,tstr,0,12,'k');
  axis tight
  set(gca,'nextplot','replacechildren');
  %mknicecolorbar('EastOutside','(p-{\langle}p{\rangle}) / \sigma',12,0.15,0.1,3);
  
  % Get movie frame
  mov(i) = getframe(gcf);
  pause(0.001); clf
end

% Create AVI file.
movie2avi(mov, [filebase '.avi'], 'compression', 'None', 'fps', 25);
%==========================================================================

end