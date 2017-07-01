function fct_a_moviestatistic(filebase)
% Jun-07-2013, C. Brandt, San Diego
% changed Sep-10-2013
% changed Jan-21-2017
% This takes the raw data and generates the movie statistics
% call the function: fct_a_moviestatistic('raw data file name')
% eg: "raw data file name.cine"

disp('*** calculating average, std, and light fluctuation quantities')

filename = [filebase '.cine'];

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
movstat.avg = movstat.avg/N;


movstat.std = 0;
F = zeros(size(pic,1), size(pic,2));
s = 0;
for i=1:N
  disp_num(i,N);
  % ------------------------------------------ Calculate Standard Deviation
  pic = double(cineRead(filename, i));
  hv = (pic - movstat.avg).^2;
  s = s + hv;
  
  % -------------------------------- Calculate light fluctuation quantities  
  B = abs( (pic-movstat.avg)./movstat.avg );
  F = F + B;
  movstat.lightfluc.min(i)      = matmin( (pic-movstat.avg) );
  movstat.lightfluc.max(i)      = matmax( (pic-movstat.avg) );
  movstat.lightfluc.minperc(i)  = matmin( (pic-movstat.avg)./movstat.avg );
  movstat.lightfluc.maxperc(i)  = matmax( (pic-movstat.avg)./movstat.avg );
  %Gives the standard deviation of light intensity of all pixels for each frame
  
  %No toolbox required
  movstat.lightfluc.std2(i) =  std2(pic-movstat.avg);
  movstat.lightfluc.std2norm(i) =  std2(pic-movstat.avg./movstat.avg);
  
  % Toolbox required for std2 command
  %   movstat.lightfluc.std2(i) = std2( (pic-movstat.avg) ); sqrt(sum(sum(hv))/(size(pic,1)*size(pic,2)));
  %   movstat.lightfluc.std2norm(i) =   std2(
  %   (pic-movstat.avg)./movstat.avg ); sqrt(sum(sum(hv./movstat.avg))/(size(pic,1)*size(pic,2)));
end
movstat.std = sqrt(s/N);
movstat.flucpic = F/N;
movstat.lightfluc.time = ((1:N)-1)/info.frameRate;
movstat.lightfluc.amp = (movstat.lightfluc.max-movstat.lightfluc.min)/2;
movstat.lightfluc.ampperc = ...
  (movstat.lightfluc.maxperc-movstat.lightfluc.minperc)/2; %#ok<STRNU>


savefn = [filebase '_statistics.mat'];
save(savefn,'movstat');
%==========================================================================

end