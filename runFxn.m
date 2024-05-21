%run the Shimadzu function
%Krista Longnecker 9/13/2013; updated 1/22/2022; update 4/17/2024 change
%the sorting step to be stable (so I get a run order)
close all
clear all

% wDir = 'Z:\Shimadzu_outputFiles_allFiles';
wDir = 'Y:\';
txtFile = 'fixCode.txt'; %data file name --> exported from Shimadz20
fName = strcat(wDir,filesep,txtFile);

%this next weight is the dilution of the concentrated stock solution; this
%dilution is made every 1-2 days
standardWeight = 2.3071; % 

%To make the standard curve the diluted stock solution is diluted by the
%instrument, those vials are labeled in the sequence as follows:
%S30/S15/S10/S7, and S0 is the MilliQ water only vial
appendL = '_first'; %{'_again'} ''; %{'_first'} '';'first_1x1'

if 1
    %keep one stock solution prior to current one as I may want to use it
    if 1
        %concentrated stock solution information: weighed out 4/3/2024`
        %B24/p74
        KHP = 0.1356;
        KNO3 = 0.1430;
    elseif 0
        %concentrated stock solution information: weighed out 3/3/2024
        %B24/p74 (latest, multiple stocks on that page) 
        KHP = 0.1553;
        KNO3 = 0.1501;
    end  
    %calculate concentration in the stock solution
    stdCarbon = (KHP * 1000 * 8 * 1000)./(100 * 204.227); %in mM carbon
    stdNitrogen = (KNO3 * 1000 * 1000)./(100 * 101.103); %in mM nitrogen
else
    %enter the stock solution concentration manually
    stdCarbon = 58;
    stdNitrogen = 15;
end

%now to the math
riRawData_function_v6(fName,standardWeight,stdCarbon,stdNitrogen,appendL) 

%load up the resulting data file
load([fName(1:end-3) 'mat']) 

%tweak the figure
r = regexp(txtFile,'_');
txtFile(r) = ' ';
title_up(txtFile)
clear r
clear standardWeight stdCarbon stdNitrogen fName

% set(gcf,'position',[360 292 557 630])