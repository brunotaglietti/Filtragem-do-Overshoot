function fig = anotherfig( ~ )
%ANOTHERFIG Checks if a figure is open, else opens it.
%   Detailed explanation goes here
global fignum
if ishandle(fignum), close(fignum); end;
fig = figure(fignum);
fignum = fignum + 1;
end