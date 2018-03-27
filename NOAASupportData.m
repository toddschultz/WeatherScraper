function [varTable,QCTable] = NOAASupportData()
%%NOAASUPPORTDATA provides critical support data for each variable
% This function creates data tables necessary to properly interpret the
%   data provide by the legacy NOAA webservice API for the historic global
%   hourly Integrated Surface Data. (See <https://www.ncei.noaa.gov/support/access-data-service-api-user-documentation> 
%   and <https://www.ncdc.noaa.gov/isd>.) This data includes: 
%   * descriptions of the quality codes assigned to each variable.
%   * Scale factor to convert the raw text transmission to physical units.
%   * Minimum and maximum values allowed for each variable.
%   * Value assigned to missing values.
%   * Units for each variable.
%   * List of available categorical codes and descriptions. 
%   The raw data was typically transmitted as a string of ASCII characters
%   and stored as such by NOAA. Thus, a scale factor was applied to each
%   variable to transmit only integer values leaving the conversion back to
%   physical units to the data users. Also, missing values were assigned
%   values such as '+999' or '+99999' and should be converted to more
%   typcial values such as 'NaN', 'missing', or '<undefined>'. 
%   
% Syntax
% [varTable,QCTable] = NOAASupportData()
% 
% Inputs
%
% Outputs
% varTable = table of support information for each variable
% QCTable =  table of the quality codes and descriptions
%
%   Example
%      [varTable,QCTable] = NOAASupportData()
% 
%   See also GRABNOAAWEATHERDATA, CLEANNOAAWEATHERTABLE

% Reference
% National Climatic Data Center (2016). Federal climate complex data 
%   documentatoin for integrated surface data. Asheville, NC: NOAA. 
%   (<https://www.ncdc.noaa.gov/isd>).

% Copyright 2018
% Written by Todd Schultz

%% Validate inputs and outputs
narginchk(0,0);
nargoutchk(1,2);

%% Quality codes
% Individual quality code descriptions
QCset = ["0"    "Passed gross limits check"; ...
         "1"    "Passed all quality control checks"; ...
         "2"    "Suspect"; ...
         "3"    "Erroneous"; ...
         "4"    "Passed gross limits check , data originate from an NCEI data source"; ...
         "5"    "Passed all quality control checks, data originate from an NCEI data source"; ...
         "6"    "Suspect, data originate from an NCEI data source"; ...
         "7"    "Erroneous, data originate from an NCEI data source"; ...
         "9"    "Passed gross limits check if element is present"; ...
         "A"    "Data value flagged as suspect, but accepted as a good value"; ...
         "C"    "Temperature and dew point received from Automated Weather Observing System (AWOS) are reported in whole degrees Celsius. Automated QC flags these values, but they are accepted as valid."; ...
         "I"    "Data value not originally in data, but inserted by validator"; ...
         "M"    "Manual changes made to value based on information provided by NWS or FAA"; ...
         "P"    "Data value not originally flagged as suspect, but replaced by validator"; ...
         "R"    "Data value replaced with value computed by NCEI software"; ...
         "U"    "Data value replaced with edited value"];
QCTable = table(categorical(QCset(:,1)),categorical(QCset(:,2)),'VariableNames',{'QualityCode','QualityCodeDescr'});


%% SOURCE
% Convert SOURCE to a categorical variable. The source is a code for 
% describing the original source of the data values. 

valcatset = ["1"    "USAF SURFACE HOURLY observation, candidate for merge with NCEI SURFACE HOURLY (not yet merged, failed element cross-checks)"; ...
             "2"    "NCEI SURFACE HOURLY observation, candidate for merge with USAF SURFACE HOURLY (not yet merged, failed element cross-checks)"; ...
             "3"    "USAF SURFACE HOURLY/NCEI SURFACE HOURLY merged observation"; ...
             "4"    "USAF SURFACE HOURLY observation"; ...
             "5"    "NCEI SURFACE HOURLY observation"; ...
             "6"    "ASOS/AWOS observation from NCEI"; ...
             "7"    "ASOS/AWOS observation merged with USAF SURFACE HOURLY observation"; ...
             "8"    "MAPSO observation (NCEI)"; ...
             "A"    "USAF SURFACE HOURLY/NCEI HOURLY PRECIPITATION merged observation, candidate for merge with NCEI SURFACE HOURLY (not yet merged, failed element cross-checks)"; ...
             "B"    "NCEI SURFACE HOURLY/NCEI HOURLY PRECIPITATION merged observation, candidate for merge with USAF SURFACE HOURLY (not yet merged, failed element cross-checks)"; ...
             "C"    "USAF SURFACE HOURLY/NCEI SURFACE HOURLY/NCEI HOURLY PRECIPITATION merged observation"; ...
             "D"    "USAF SURFACE HOURLY/NCEI HOURLY PRECIPITATION merged observation"; ...
             "E"    "NCEI SURFACE HOURLY/NCEI HOURLY PRECIPITATION merged observation"; ...
             "F"    "Form OMR/1001 � Weather Bureau city office (keyed data)"; ...
             "G"    "SAO surface airways observation, pre-1949 (keyed data)"; ...
             "H"    "SAO surface airways observation, 1965-1981 format/period (keyed data)"; ...
             "I"    "Climate Reference Network observation"; ...
             "J"    "Cooperative Network observation "; ...
             "K"    "Radiation Network observation"; ...
             "L"    "Data from Climate Data Modernization Program (CDMP) data source"; ...
             "M"    "Data from National Renewable Energy Laboratory (NREL) data source"; ...
             "N"    "NCAR / NCEI cooperative effort (various national datasets)"; ...
             "O"    "Summary observation created by NCEI using hourly observations that may not share the same data source flag"; ...
             "9"    "Missing"];
SourceTable = table(categorical(valcatset(:,1)),categorical(valcatset(:,2)),'VariableNames',{'SOURCE','SOURCE_DESCR'});

%% REPORT_TYPE
% Convert REPORT_TYPE to a categorical variable. 

valcatset = ["AERO"     "Aerological report"; ...
             "AUST"     "Dataset from Australia"; ...
             "AUTO"     "Report from an automatic station"; ...
             "BOGUS"    "Bogus report"; ...
             "BRAZ"     "Dataset from Brazil"; ...
             "COOPD"    "US Cooperative Network summary of day report"; ...
             "COOPS"    "US Cooperative Network soil temperature report"; ...
             "CRB"      "Climate Reference Book data from CDMP"; ...
             "CRN05"    "Climate Reference Network report, with 5-minute reporting interval"; ...
             "CRN15"    "Climate Reference Network report, with 15-minute reporting interval"; ...
             "FM-12"    "SYNOP Report of surface observation form a fixed land station"; ...
             "FM-13"    "SHIP Report of surface observation from a sea station"; ...
             "FM-14"    "SYNOP MOBIL Report of surface observation from a mobile land station"; ...
             "FM-15"    "METAR Aviation routine weather report"; ...
             "FM-16"    "SPECI Aviation selected special weather report"; ...
             "FM-18"    "BUOY Report of a buoy observation"; ...
             "GREEN"    "Dataset from Greenland"; ...
             "MESOH"    "Hydrological observations from MESONET operated civilian or government agency"; ...
             "MESOS"    "MESONET operated civilian or government agency"; ...
             "MESOW"    "Snow observations from MESONET operated civilian or government agency"; ...
             "MEXIC"    "Dataset from Mexico"; ...
             "NSRDB"    "National Solar Radiation Data Base"; ...
             "PCP15"    "US 15-minute precipitation network report"; ...
             "PCP60"    "US 60-minute precipitation network report"; ...
             "S-S-A"    "Synoptic, airways, and auto merged report"; ...
             "SA-AU"    "Airways and auto merged report"; ...
             "SAO"      "Airways report (includes record specials)"; ...
             "SAOSP"    "Airways special report (excluding record specials)"; ...
             "SHEF"     "Standard Hydrologic Exchange Format"; ...
             "SMARS"    "Supplementary airways station report"; ...
             "SOD"      "Summary of day report from U.S. ASOS or AWOS station"; ...
             "SOM"      "Summary of month report from U.S. ASOS or AWOS station"; ...
             "SURF"     "Surface Radiation Network report"; ...
             "SY-AE"    "Synoptic and aero merged report"; ...
             "SY-AU"    "Synoptic and auto merged report"; ...
             "SY-MT"    "Synoptic and METAR merged report"; ...
             "SY-SA"    "Synoptic and airways merged report"; ...
             "WBO"      "Weather Bureau Office"; ...
             "WNO"      "Washington Naval Observatory"; ...
             "99999"    "Missing"];
ReportTypeTable = table(categorical(valcatset(:,1)),categorical(valcatset(:,2)),'VariableNames',{'REPORT_TYPE','REPORT_TYPE_DESCR'});

%% Convert visibility variability code to categorical
valcatset = ["N"    "Not variable"; ...
             "V"    "Variable"; ...
             "9"    "Missing"];
VisVarTable = table(categorical(valcatset(:,1)),categorical(valcatset(:,2)),'VariableNames',{'VIS_VAR','VIS_VAR_DESCR'});

%% Convert ceiling determination code to categorical
valcatset = ["A"    "Aircraft"; ...
             "B"    "Balloon"; ...
             "C"    "Statistically derived"; ...
             "D"    "Persistent cirriform ceiling (pre-1950 data)"; ...
             "E"    "Estimated"; ...
             "M"    "Measured"; ...
             "P"    "Precipitation ceiling (pre-1950 data)"; ...
             "R"    "Radar"; ... 
             "S"    "ASOS augmented"; ...
             "U"    "Unknown ceiling (pre-1950 data)"; ...
             "V"    "Variable ceiling (pre-1950 data)"; ...
             "W"    "Obscured"; ...
             "9"    "Missing"];
CigDeterTable = table(categorical(valcatset(:,1)),categorical(valcatset(:,2)),'VariableNames',{'CIG_DETER','CIG_DETER_DESCR'});

%% Convert ceiling and visibility okay code to categorical
valcatset = ["N"    "No"; ...
             "Y"    "Yes"; ...
             "9"    "Missing"];
CigCavokTable = table(categorical(valcatset(:,1)),categorical(valcatset(:,2)),'VariableNames',{'CIG_CAVOK','CIG_CAVOK_DESCR'});

%% Convert wind type to categorical
valcatset = ["A" "Abridged Beaufort"; ...
             "B" "Beaufort"; ...
             "C" "Calm"; ...
             "H" "5-Minute Average Speed"; ...
             "N" "Normal"; ...
             "R" "60-Minute Average Speed"; ...
             "Q" "Squall"; ...
             "T" "180-Minute Average Speed"; ...
             "V" "Variable"; ...
             "9" "Missing"];
WindTypeTable = table(categorical(valcatset(:,1)),categorical(valcatset(:,2)),'VariableNames',{'WND_TYPE','WND_TYPE_DESCR'});

%% Variable data
% Data for each individual variable of interest. All numeric values in the
% table are raw or unscaled values. 

varName = ["SOURCE"; "REPORT_TYPE"; "WND_DIR"; "WND_TYPE"; "WND_SPEED"; ... 
    "CIG_HEIGHT"; "CIG_DETER"; "CIG_CAVOK"; "VIS_DIST"; "VIS_VAR"; "TMP"; "DEW"; "SLP"];
varDescription = ["Original data source for observatoin"; ...
    "Type of geophysical surface observation"; "Wind direction"; ... 
    "Wind type code"; "Wind speed"; "Ceiling height"; ... 
    "Ceiling determination code"; "Ceiliing & visibility okay code"; ... 
    "Visibility distance"; "Visibility variability code"; ... 
    "Air temperature"; "Dew point temperature"; "Sea level pressure"];
ScaleFactor = [nan; nan; 1; nan; 10; 1; nan; nan; 1; nan; 10; 10; 10];
Min = [nan; nan; 1; nan; 0; 0; nan; nan; 0; nan; -932; -982; 8600];
Max = [nan; nan; 360; nan; 900; 22000; nan; nan; 160000; nan; 618; 368; 10900];
Missing = ["9"; "99999"; "999"; "9"; "9999"; "99999"; "9"; "9"; "999999"; "9"; "+9999"; "+9999"; "99999"];
Units = [""; ""; "degs"; ""; "m/s"; "m"; ""; ""; "m"; ""; "degs C"; "degs C"; "hPa"];
AvailableCodes = {SourceTable; ReportTypeTable; {}; WindTypeTable; {}; {}; ... 
    CigDeterTable; CigCavokTable; {}; VisVarTable; {}; {}; {}};

varTable = table(varName,varDescription,ScaleFactor,Min,Max,Missing,Units,AvailableCodes);

end