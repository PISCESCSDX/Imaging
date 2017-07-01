function [info] = cineInfo(fileName)
%
% Reads header information from a Phantom Camera cine file, analagous to
% Mathworks aviinfo().  The values returned are:
%
% info.OffImageHeader - Offset of the BITMAPINFOHEADER structure in the
%   cine file.
% info.OffSetup - Offset of the SETUP structure in the cine file.
% info.headerPad - length of the variable portion of the pre-data header
% info.Width - image width
% info.Height - image height
% info.startFrame - first frame # saved from the camera cine sequence
% info.NumFrames - total number of frames
% info.endFrame - last frame # saved from the camera cine sequence
% info.biSizeImage - size, in bytes, of the image, uncompressed.
% info.bitDepth - image bit depth 
%       Here, 'bitDepth' is a misnomer (or ambiguous) term.  
%       info.bitDepth is bits of storage per pixel.
%       Each 10-, 12-, 14-, or 16-bit camera pixel is stored in 16-bits.
%       info.biBitCount should be the same as info.bitDepth.
% info.biBitCount - number of bits-per-pixel.  Determines the number of 
%   bits that define each pixel and the maximum number of colors in the
%   bitmap.  Phantom specific: can only be 8, 24, 16, 48 bits.  8 and 16
%   bit DIBs are monochrome, 24 and 48 are RGB color DIBs.  The meaning
%   of the 16 bit DIB is different from Windows: it is a 16 bit per pixel
%   grey image.  Each pixel value is stored on 16 bits even if the real
%   bit depth produced by the camera is 14, 12, or 10 bits.  The value 48
%   of this field corresponds to a color image having 16 bits per color
%   component.  Color palette images (8bpp) are not accepted; in the
%   Phantom environment they are converted to 24 bpp after the file load
%   or after the copy from clipboard.  The palette is not written in the
%   cine file but a gray palette is needed to render the monochrome 8bpp
%   DIBs in Windows.
% info.CompressionType - 0 for gray cines; 1 for a JPEG compressed file; 2
%   for uninterpolated color image.  (type 2 is not supported here).
% info.fileVersion - 0 for cine files created with Phantom software
%   version numbers less than 600.  1 for files created with Phantom
%   software with versions 600 and over.
%   Starting from version 600, Phantom software is able to write and read
%   files bigger than 4 GB if supported by the operating system.  
%   To allow this image pointers were changed from 32-bit to 64-bit
%   integers.     
% info.frameRate - frame rate the cine was recorded at
% info.exposure - frame exposure time in microseconds
% info.cameraType - model of camera used to record the cine
% info.firmwareVersion - camera firmware version.
% info.softwareVersion - Phantom control software version used in recording
% info.ColorFilterArray - 0 for gray images
% info.pImage[1:info.NumFrames] - array of pointers (i.e., file offsets) to
%    image frame blocks.  For cine files version 1 or greater, the array
%    contains 64-bit pointers.  For version 0 cine files, the array
%    contains 32-bit pointers.  Each frame block (a.k.a. "image object")
%    contains annotation data followed by the image data.  The first
%    32-bits contain the size of the annotation data.  The last 32 bits of
%    the annotation data contain the size of the image array in pixels.
%    (If the file is compressed, it may be mecessary to read this to get
%    the actual size of the pixel array that follows.  For uncompressed
%    cine files, the actual size is the same as info.biSizeImage.)
%
% Ty Hedrick, April 27, 2007
%  updated November 6, 2007
%  updated March 1, 2009
%  updated February 11, 2010, Loretta Reiss
% bitDepth changed to BitDepth Sept. 28, 2010 L. Reiss


% check for cin suffix.  This program will produce erratic results if run
% on an AVI!
if strcmpi(fileName(end-3:end),'.cin') || ...
    strcmpi(fileName(end-4:end),'.cine')
  % use the Phantom SDK libraries if we're on the 32bit windows platform
    if strcmp(computer,'PCWINE')
      info = cineInfoMex(fileName);
      info.NumFrames = info.endFrame - info.startFrame +1;
        
    % use the pure Matlab approach if we're on any other platform (Unix,
    % 64bit Windows, etc.)
    else
      % read the first chunk of header
      %
      % get a file handle from the filename
      f1=fopen(fileName);
      
      % read the 1st 410 32bit ints from the file
      header32=double(fread(f1,410,'*int32'));
        
      % release the file handle
      fclose(f1);
      
      % save fixed offset values from CINE header (these will not change in
      % new Phantom software releases)
      info.OffImageHeader = header32(7);
      info.OffSetup = header32(8);
      info.headerPad = header32(9); % variable length pre-data pad
      
      % set output values from certain magic locations in the header
      info.Width = header32(2 + (info.OffImageHeader/4));
      info.Height = header32(3 + (info.OffImageHeader/4));
      info.startFrame = header32(5); % First Image Number relative to trigger
      info.NumFrames = header32(6);  % Image Count
            
      info.endFrame = info.startFrame+info.NumFrames-1;
      % biSizeImage is image size in bits, e.g., for 12-bit samples, this is
      % 12 even though the sample is stored in a 16-bit word with four zeroes
      % padding.  
      info.biSizeImage = header32(6 + (info.OffImageHeader/4));
     
      info.BitDepth = (info.biSizeImage)*8/(info.Width*info.Height);
      % biBitCount is number of bits-per-pixel.  [same as info.bitDepth,
      % above]
      info.biBitCount = bitshift(bitand(header32(4 + (info.OffImageHeader/4)),...
          (2^32) - (2^16)), -16);
      info.CI = int16(bitand(header32(1), (2^16)-1));
      
        % check for "CI" (cine file header block starts with "CI")
        if (info.CI==18755) % 18755 is 'CI' in US-ASCII code
            info.CompressionType = bitand(header32(2), (2^16)-1);
            % check compression type here--we do not support type 2.
            % Type 2 is uninterpolated color image.
            if(info.CompressionType==0)||(info.CompressionType==1)
            % (uncompressed gray cine or JPEG compressed file)
            
            % check file version #--v. 1 for Phantom apps with version # >= 600;
            %                     --v. 0 for earlier Phantom apps.
            %   v. 0 has 32-bit pointers.  v. 1 has 64-bit pointers.
            info.fileVersion = bitshift(bitand(header32(2),...
                (2^32) - (2^16)), -16);
            info.frameRate=header32(193 + (info.OffSetup/4));
            info.exposure=header32(194 + (info.OffSetup/4));
            info.cameraType=header32(199 + (info.OffSetup/4));
            info.firmwareVersion=header32(200 + (info.OffSetup/4));
            info.softwareVersion=header32(201 + (info.OffSetup/4));
            info.ColorFilterArray = header32(203 + (info.OffSetup/4));
            else
            fprintf('%s is unsupported cine file type %d',fileName,...
                info.CompressionType);
            end
            % read array of pointers to images
            f1 = fopen(fileName);
            fseek (f1, info.headerPad, -1);
            if info.fileVersion==0
                info.pImage = fread(f1, info.NumFrames, '*uint32');
            else
                info.pImage = fread(f1, info.NumFrames, '*uint64');
            end
            fclose(f1);
            
        else
        fprintf('%s does not have cine file header block starting with CI',...
            fileName);
        end
    end
else
    fprintf('%s does not appear to be a cine file.',fileName)
    info=[];
end
