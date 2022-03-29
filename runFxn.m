%run the Shimadzu function
%Krista Longnecker 9/13/2013; updated 1/22/2022 
close all
clear all

fName = 'SampleData.txt'; %data file name --> exported from Shimadzu

if 1
    %concentrated stock solution information: weighed out 2/9/2022 B22/p169
    KHP = 0.2395;
    KNO3 = 0.2916;
    %calculate concentration in the stock solution
    stdCarbon = (KHP * 1000 * 8 * 1000)./(100 * 204.227); %in mM carbon
    stdNitrogen = (KNO3 * 1000 * 1000)./(100 * 101.103); %in mM nitrogen
else
    %enter the stock solution concentration manually
    stdCarbon = 68.94289;
    stdNitrogen = 22.51169599;
end

%this next weight is the dilution of the concentrated stock solution; this
%dilution is made every 1-2 days
standardWeight = 2.0265; %

%To make the standard curve the diluted stock solution is diluted by the
%instrument, those vials are labeled in the sequence as follows:
%S30/S15/S10/S7, and S0 is the MilliQ water only vial
if 1 %must have some form of extra letters after S0, S30, etc. req3 injections
    appendL = '_again'; %{'_again'} '';
end

%now to the math
riRawData_function_v4(fName,standardWeight,stdCarbon,stdNitrogen,appendL) 

%load up the resulting data file
load([fName(1:end-3) 'mat']) 

%tweak the figure
r = regexp(fName,'_');
fName(r) = ' ';
title_up(fName)
clear r
clear standardWeight stdCarbon stdNitrogen fName

set(gcf,'position',[360 292 557 630])