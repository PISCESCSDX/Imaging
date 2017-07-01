function [cdata] = cineRead(fileName,frameNum)
%
% Reads the frame specified by frameNum from the Phantom camera cine file
% specified by fileName.  It will not read compressed cines.  Furthermore,
% the bitmap in cdata may need to be flipped, transposed or rotated to
% display properly in your imaging application.
%
% frameNum is 1-based and starts from the first frame available in the
% file.  It does not use the internal frame numbering of the cine itself.
%
% This function uses the cineReadMex implementation on 32bit Windows; on
% all other platforms it uses a pure Matlab implementation that has been
% tested on (and works on) grayscale CIN files from a Phantom v5.1 and
% Phantom v7.0 camera.  The cineReadMex function has only been tested with
% 1024x1024 cines from a Phantom v5.1 and likely will not work with other
% data files.
%
% Ty Hedrick, April 27, 2007
%  updated November 06, 2007
%  updated March 1, 2009
%  updated February 11, 2010 Loretta Reiss
% updated March 22, 2010 Loretta Reiss (support files larger than 2GB)
% updated 21 May 2010 Loretta Reiss (initialization to 'uint8' for cdata)
% check inputs
if strcmpi(fileName(end-3:end),'.cin') || ...
        strcmpi(fileName(end-4:end),'.cine') && isnan(frameNum)==false
    
    % use the Phantom SDK libraries if we're on the 32bit windows platform
    if strcmp(computer,'PCWINE')
        cdata = cineReadMex(fileName,frameNum)';
        
        % use the pure Matlab approach if we're on any other platform (Unix,
        % 64bit Windows, etc.)
    else
        % get file info from the cineInfo function
        info=cineInfo(fileName);
        if (info.CI==18755) % 18755 is 'CI' in US-ASCII code
            % if info.CI is not "CI", a message was displayed by cineInfo.
            
            %TODO: add checks for other unsupported files here.
            
            % info.pImage[1:info.NumFrames] point to start of frame blocks.
            % Each frame block (a.k.a. "image object") contains annotation
            % data followed by the image data.  The first 32 bits contain
            % the size ofthe annotation data.  The last 32 bits contain
            % the size of the image array in pixels. There can be 
            % additional information between these two 32-bit words. 
            % If there is additional information, the value of the first
            % word will be greater than 8, i.e., the annotation block of
            % the image object  will be greater than 8 bytes.  To support
            % this, we read the first word of the annotation block and
            % move the file pointer accordingly.
            % If the file is compressed, it may be
            % necessary to use the last 32-bit word of the annotation
            % block to get the actual size of the pixel array that
            % follows.  For uncompressed cine files, the actual
            % size in bytes is info.biSizeImage.
            
            % get a handle to the file from the filename
            f1=fopen(fileName);
            
            % read size of annotation portion of image object:
            fseek(f1, int64(info.pImage(frameNum)),-1);
            annotationSize = fread(f1,1,'*uint32');
            % file pointer is now positioned immediately after the
            % annotation size field

            % position file pointer at last 4 bytes of annotation block:
            fseek(f1,annotationSize-8,0);  
 
            % read actual size of image data:
            ImageSize = double(fread(f1,1,'*uint32'));
            % file pointer is now positioned at start of image data
            
            % read a certain amount of data in - the amount determined by 
            % the size of the frames and the camera bit depth, then cast
            %  the data to either 8-bit or 16-bit unsigned integer
            if info.biBitCount==8 % 8-bit gray
                idata=fread(f1,ImageSize,'*uint8');
                clname = 'uint8';
                nDim=1;
            elseif info.biBitCount==16 % 10-, 12-, 14-, or 16-bit gray
               idata=fread(f1,ImageSize/2,'*uint16');
               clname = 'uint16';
                nDim=1;
            elseif info.biBitCount==24 % 24-bit color
                idata=double(fread(f1,info.Height*info.Width*3,'*uint8'))/255;
                clname = 'uint8';
                nDim=3;
            else  % unsupported format or error
                disp('error: unknown bitdepth')
                return
            end
            
            % destroy the handle to the file
            fclose(f1);
            
            % the data come in from fread() as a 1 dimensional array; here we
            % reshape them to a 2-dimensional array of the appropriate size
            cdata=zeros(info.Height,info.Width,nDim, clname);
            for i=1:nDim
                tdata=reshape(idata(i:nDim:end),info.Width,info.Height);
                cdata(:,:,i)=fliplr(rot90(tdata,-1));
            end
        end
    end
else
    % complain if the use gave what appears to be an incorrect filename
    fprintf( ...
        '%s does not appear to be a cine file or frameNum is not available.'...
        ,fileName)
end
