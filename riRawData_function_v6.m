function riRawData_function_v5(FileToOpen,standardWeight,stdCarbon,stdNitrogen,appendL)
%function riRawData_function_v5(FileToOpen,standardWeight,stdCarbon,stdNitrogen,appendL)
%m-file to read *txt data exported from the TOC machine in Fye 114.
%This m-file assumes that you have the Statistics Toolbox
%FileToOpen is the text file exported from the instrument
%standardWeight is the weight of the diluted standard made daily (grams in 100 ml flask)
%stdCarbon is the concentration of C in the concentrated standard (in mM-carbon)
%stdNitrogen is the concentration of N in the concentrated standard (in mM-nitrogen)
%appendL is a text string added to the name of the standards (so you can
%have different standard curves, can be blank if nothing was added)
%Krista Longnecker 2/22/07; KL 12/13/10 ; KL 1/3/2012 
%Woods Hole Oceanographic Institution
%KL 9/13/2013 changing this to a function (was a script)
%KL 1/21/2022 updating with the new export options from new Shimadzu
%KL 4/11/2024 corrected excluded points on standard curve
%KL 5/21/2024 fix the long time issue where this requires all samples with
%data in text file
%KL 9/9/2024 change to using the dilution information from the instrument

%what will today's data be called? strip off the .txt extension
r = regexp(FileToOpen,'.txt','start');
NameOfFile=[FileToOpen(1:r-1) '.mat'];

%calculate the concentration of the standard (how much was in the stock vial?):
KHP_weight = standardWeight;
KHP_stock = stdCarbon;
CarbonStandard = ((KHP_weight*KHP_stock)./100 )*1000; % to get in uM carbon

KNO3_weight = standardWeight;
KNO3_stock = stdNitrogen;
NitrogenStandard = ((KNO3_weight*KNO3_stock)./100)*1000; %to get uM nitrogen 
clear *_weight *_stock

%use function at the end to do the calculating - NPOC and TN separately
try
    [concNPOC,FullSampleNameNPOC,autoDilution,injection] = doTheMath(FileToOpen,'NPOC',CarbonStandard,appendL);
    [concTN,FullSampleNameTN,autoDilution,injection] = doTheMath(FileToOpen,'TN',NitrogenStandard,appendL);
catch
    fprintf('This error probably means: (i) you did not remove empty rows from data file, or (ii) you have the wrong file name, (iii) or you have NPOC-only data\n')
end

%will overwrite autoDilution and injection, but OK as long as
%FullSampleName passes this check:
[c ia] = setdiff(FullSampleNameNPOC,FullSampleNameTN);
if ~isempty(c) %will be empty if the names match
    error('Something is wrong, should be empty')
end

%make a table for the results
dataOut = cell2table(FullSampleNameTN,'variableName',{'sName'});
dataOut.NPOC = concNPOC;
dataOut.TN = concTN;
dataOut.autoDilution = autoDilution;
dataOut.injection = injection;
clear conc* FullSampleName* autoDilution injection

%don't want some samples in the data matrix, just delete them
toDelete = {'MQfromVial','MQ','blankCN1','blank'};
[c ia ib] = intersect(toDelete,dataOut.sName);
dataOut(ib,:)=[];
clear c ia ib toDelete

save(NameOfFile);

end

function [concentrationOut,FullSampleName,UseDilution,UseInjectVol] = doTheMath(FileToOpen,calcVariable,useStandard,appendL)
    warning('off','MATLAB:table:ModifiedAndSavedVarnames')
    if verLessThan('matlab','9.14') %not exactly sure where the code will break, but this is a start
        %for older versions of MATLAB you have to trim the empty rows out
        %of the text file before running this (or re-write the next section
        %a different way)
        T = readtable(FileToOpen,'delimiter',',');
    else
        opts = delimitedTextImportOptions;
        opts.DataLines = 7;
        opts.VariableNamesLine = 6;
        T = readtable(FileToOpen,opts); 
        %this next bit is an annoying way of doing this, but it workds
        T.Area = str2double(T.Area); 
        T.MeanArea = str2double(T.MeanArea); 
        T.Excluded = str2double(T.Excluded); 
        T.Inj_Vol_ = str2double(T.Inj_Vol_); 
        T.Auto_Dil_ = str2double(T.Auto_Dil_); 
        %then trim T to only include rows with data...
        i = isnan(T.Area);
        T(i,:) = []; clear i
    end

    
    %use this step to figure out what I am searching for in the data file
    atype = strcmp(T.Analysis_Inj__,calcVariable);

    st = startsWith(T.SampleName,'S');
    sc = endsWith(T.SampleName,appendL); %better choice 4/10/2024
    ks = find(st==1 & sc==1 &atype==1 & T.Excluded==0); %updated 4/11/2024

    %find the MilliQ from the vial:
    s=strcmp(T.SampleName,strcat('S0',appendL));
    k0=find(s==1 & atype == 1); clear s
    %k0 = ks; %need this to hack in the S0 below
    %ks = [k0; ks];
    
    %use autodilution (now possible, 1/2022)
    AmountInjected=T.Inj_Vol_(ks); 
    tDilute = T.Auto_Dil_(ks);
    
    [c ia ib] = intersect(ks,k0);
    tDilute(ia)= Inf;

    %Nadded=(useStandard./tDilute).*(AmountInjected./150); %this syntax allowed for different injection volumes
    Nadded=(useStandard./tDilute);
    x=Nadded;
    y=T.Area(ks);
    clear r rr mu ks Nadded AmountInjected

    %apply the calibration curve, use regress to get the r2:
    [b, bint, r, rint, stats]=regress(y,[ones(1,length(x))' , x]);
    r2=stats(1) ;
    slope=b(2);
    yintercept=b(1);
    clear b bint r rint stats

    %set up for plotting
    if isequal(calcVariable,'NPOC')
        sp = 1;
    else
        sp = 2;
    end
    subplot(2,1,sp)
    plot(x,y,'ko','markersize',5,'markerfacecolor','b')
    xlabel(strcat(calcVariable,{' '},'added (uM)'))
    ylabel(strcat('Area under peak for',{' '},calcVariable))
    title(strcat('Standard curve for',{' '},calcVariable))
    lsline
    text(1,3,{'Slope=' num2str(slope) 'yInt=' num2str(yintercept) 'r^2=' num2str(r2)});
    %gtext({'Slope=' num2str(slope) 'yInt=' num2str(yintercept) 'r^2=' num2str(r2)});
    clear x y

    % Get the mean blank value, so I can subtract that from the samples later
    yt=char(T.SampleName);
    yt(:,3:end)=[]; yt=cellstr(yt); %leave only the MQ letters
    kyt=strcmp('MQ',yt);
    ky=find(kyt==1 & atype==1); %these will be rows with MQ blanks:
    BlanksOnly=T.MeanArea(ky); 
    BlankArea=mean(BlanksOnly);
    clear yt kyt ky BlanksOnly

    %pull the sample names - can change if you want this sorted by name or
    %in order; add April 2024
    if 1
        [FullSampleName]=unique(T.SampleName,'stable'); %list as run order    
    elseif 0
        [FullSampleName]=unique(T.SampleName,'sorted'); %this will sort by name   
    end
    
    TNarea = []; %will be more general, but easier to keep this name
    UseInjectVol =[];
    UseDilution = [];

    for a = 1:size(FullSampleName,1)
        s = strcmp(FullSampleName{a},T.SampleName);
        kns = find(s==1 & atype==1);  %will be the same number multiple times
        TNarea(a,1)=T.MeanArea(kns(1)); 
        UseInjectVol(a,1)=T.Inj_Vol_(kns(1)); 
        UseDilution(a,1) = T.Auto_Dil_(kns(1));
    end
    clear a

    %now need to convert the area under the curve data (NPOCarea) torunF
    %concentrations of carbon using the calibration curve 
    %concentrationOut=(TNarea./slope);
    %change to considering the dilution information for the samples:
    concentrationOut = ((TNarea.*UseDilution)./slope);
    %added for Sarah 5/9/2025
    %concentrationOut = ((TNarea.*UseDilution)./slope) - yintercept;
    averageBlank=BlankArea./slope; %not using this, keep for historical purposes
end

