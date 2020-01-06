function h=cfigure(width,height)
%function h=cfigure(width,height)
% Customized figure function. Opens a figure with 
% specified width and height (in centimeters) centered
% on the screen.
% The properties are set such that Matlab won't resize the 
% figure while printing or exporting to graphics files (eps, 
% tiff, jpeg, ...).
%

% Get the screen size in centimeters
set(0,'units','centimeters')
scrsz=get(0,'screensize');
% Calculate the position of the figure
position=[scrsz(3)/2-width/2 scrsz(4)/2-height/2 width height];
h=figure;
set(h,'units','centimeters')
% Place the figure
set(h,'position',position)
% Do not allow Matlab to resize the figure while printing
set(h,'paperpositionmode','auto')
% Set screen and pigure units back to pixels
set(0,'units','pixel')
set(h,'units','pixel')

%
% Note: in order to avoid Matlab recalculating the axes ticks
% you will need to set the following commands in you program:
%
% set(gca,'xtickmode','manual')
% set(gca,'ytickmode','manual')
% set(gca,'ztickmode','manual') % IF you have a third axis
%