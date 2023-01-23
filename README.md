# NPOCandTNfromShimadzu
MATLAB code to process NPOC and TN data from a Shimadzu TOC/TN instrument\
Krista Longnecker\
29 March 2021

This code requires MATLAB and is known to work on MATLAB version 2019b. It probably works on older and newer versions of MATLAB. There are three files, `runFxn.m`, `SampleData.txt`, and `riRawData_function_v4.m`. You should only need to edit runFxn.m and the SampleData.txt can be used to test that everything has worked in MATLAB.

We export text files from the Shimadzu TOC/TN instrument and process the file using MATLAB. To run the code, edit `runFxn.m` to update the following:
* name of the file exported from the Shimadzu (line 6)
* the weight of KHP and KNO3 in the concentrated stock solution (lines 10 and 11)
* the weight of concentrated stock diluted into a 100 ml flask

Once the edits are done, type `runFxn` into the MATLAB command window.

update, Krista Longnecker\
23 January 2023
I added two files (`runFxn_smallVol.m` and `riRawData_smallVol_v1.m` to process the Shimadzu data from a project that requires manual injections of small volumes. Because of the sample limitations, I am forcing the instrument to do a preset number of samples. This requires slightly different processing to calculate the mean peak areas.
