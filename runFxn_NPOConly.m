%run the Shimadzu function
%Krista Longnecker 9/13/2013; updated 1/22/2022 
%KL 4/10/2024 - while the TN module is on the fritz, set up an NPOC-only
%method on the Shimadzu
close all
clear all

wDir = 'Y:\';
txtFile = 'testing.txt'; %data file name --> exported from Shimadz20
fName = strcat(wDir,filesep,txtFile);

%this next weight is the dilution of the concentrated stock solution; this
%dilution is made every 1-2 days
standardWeight = 2.3071; 

%To make the standard curve the diluted stock solution is diluted by the
%instrument, those vials are labeled in the sequence as follows:
%S30/S15/S10/S7, and S0 is the MilliQ water only vial
if 1 %must have some form of extra letters after S0, S30, etc. 
    appendL = '_1x'; %{'_again'} '';
end

if 1
    if 1
        %concentrated stock solution information: weighed out 4/3/2024
        %B24/p74
        KHP = 0.1356;
        KNO3 = 0.1430;
    elseif 0
        %weighed out by KL 8/11/2022 (keep for prior runs as needed)
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

%now to the math
riRawData_NPOConly_v2(fName,standardWeight,stdCarbon,appendL) 

%load up the resulting data file
load([fName(1:end-3) 'mat']) 
