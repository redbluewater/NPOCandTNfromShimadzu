%run the Shimadzu function
%Krista Longnecker 9/13/2013; updated 1/22/2022 
%KL 1/18/2023 - need separate code for the small volume, carbon-only
%samples for the vesicles project
%not sure if this is easeist to set as its own sequence, but I will have to
%separately calculate bc these will be 150 ul injections
close all
clear all

fName = 'vesicles_tempWorking.txt'; %data file name --> exported from Shimadzu

%this next weight is the dilution of the concentrated stock solution; this
%dilution is made every 1-2 days
standardWeight = 1.8662; % weighed 11/15/2022

if 1 %easier to just leave KNO3 in here so I can copy/paste, will not use it
    if 1
        %concentrated stock solution information: weighed out 11/15/2022 B23/p110
        KHP = 0.3363;
        KNO3 = 0.2828;
    elseif 0
        %weighed out by KL 8/11/2022
        KHP = 0.2294;
        KNO3 = 0.2411;
    end  
    %calculate concentration in the stock solution
    stdCarbon = (KHP * 1000 * 8 * 1000)./(100 * 204.227); %in mM carbon
    stdNitrogen = (KNO3 * 1000 * 1000)./(100 * 101.103); %in mM nitrogen
else
    %enter the stock solution concentration manually
    stdCarbon = 68.94289;
    stdNitrogen = 22.51169599;
end

%To make the standard curve the diluted stock solution is diluted by the
%instrument, those vials are labeled in the sequence as follows:
%S30/S15/S10/S7, and S0 is the MilliQ water only vial
if 1 %must have some form of extra letters after S0, S30, etc. 
    appendL = '_150injection'; %{'_again'} '';
end

%now to the math
riRawData_smallVol_v1(fName,standardWeight,stdCarbon,appendL) 

%load up the resulting data file
load([fName(1:end-3) 'mat']) 
