function []= title_up(txt,sz)
%TITLE_UP: Like title.m, but puts header at the top of the full page,
%       regardless of where the supplots are.  This routine must be 
%       called after at least one set of axes are established.
%       Like TITLE.m, but shifted up to allow a SUBTITLE below.
%
%       SYNTAX
%       ------
%       TITLE_UP(txt,fontsize)
%       TITLE_UP(txt)
%
%       Chris Edwards                   March 1994

if nargin == 1, sz = 13; end;

ca = get(gcf,'CurrentAxes');

%BAR = [0.1 0.93 0.8 0.02];
%hbar = subplot('position',BAR);
%hl = line([0 1], [0.9 0.9]);
%set(hbar,'visible','off');
%set(hl,'color','black');
%set(hl,'LineWidth',2);

rect = [0.1 0.975 0.8 0.02];
h = subplot('position', rect);
set(h, 'visible', 'off');
% htxt = text(.5, .5, txt) %KL 4/13/2020 added to this to get rid of annoying warning
htxt = text(.5, .5, txt,'interpreter','none');
set(htxt, 'FontSize', sz);
set(htxt, 'Fontweight', 'bold');
set(htxt, 'verticalAlignment', 'cap');
set(htxt, 'HorizontalAlignment', 'center');

set(gcf,'CurrentAxes',ca)

