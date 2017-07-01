function wysiwyg_vid(res)
%==========================================================================
%function wysiwyg_vid(res)
%--------------------------------------------------------------------------
% WYSIWYG_VID changes two figure parameters that problems by exporting
% videos are removed. The one input parameters RES is the pixel resolution
% in x-direction. The y-direction will be calculated from the aspect ratio
% of the figure.
%--------------------------------------------------------------------------
% IN: res: desired pixel resolution in x-direction
%--------------------------------------------------------------------------
% EX: wysiwyg_vid(300)
%--------------------------------------------------------------------------
% (C) 07.01.2011 12:17, C. Brandt
%     - tests for several aspect ratios yield playing the movie in all 
%       players (vlc, dragon, mplayer) and compressing it to xvid by using
%       virtualdub
%==========================================================================

if nargin<1; res=200; end;

% (1) First set the units of the figure to "pixel" (video players use this)
  set(gcf, 'Units', 'pixel');

% (2) Change the position value of the position parameter to integer values
%     while keeping the aspect ratio of the figure
  ppos = get(gcf, 'PaperPosition');
  % calculate the aspect ratio
  rat = ppos(3)/ppos(4);
  % change the position parameter of the figure
  set(gcf, 'Position', [1 1 res res/rat]);

end