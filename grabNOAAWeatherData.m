function weathertable = grabNOAAWeatherData(weatherstation,begindate,enddate)
%%GRABNOAAWEATHERDATA imports historical hourly weather data from NOAA
% Reads historic hourly weather observation data NOAA webservice API which
%   is at <https://www.ncei.noaa.gov/support/access-data-service-api-user-documentation> 
%   and is from the Integrated Surface Data (ISD) dataset from <https://www.ncdc.noaa.gov/isd>. 
%   This function uses the webread command, which is based on RESTful
%   interface, to connect with and read data from the NOAA servers. The
%   weather station identifier required in the 4-letter ICAO code and the
%   results returned in the weather table are inclusive of the dates
%   provided to the function. This function uses the time table feature
%   which was available beginning in MATLAB R2016b but requires MATLAB
%   R2018a or newer if used on a network with a proxy server. 
%   
% Syntax
% weathertable = grabNOAAWeatherData(weatherstation,begindate,enddate)
% 
% Inputs
% weatherstation = four letter string for location's ICAO code, e.g. "KSEA"
% begindate = begining date of range of interest in UTC (datestr format, e.g. "01-Jan-2016")
% enddate = end date of range of interest in UTC (datestr format, e.g. "26-Jan-2017")
%
% Outputs
% weathertable = time table of weather hourly observation data
%
%   Example
%      weathertable = grabNOAAWeatherData("KSEA","01-Mar-2016","07-Mar-2016")
% 
%   See also GRABWEATHERDATA, WEBREAD, TIMETABLE, DATETIME

% Reference
% National Climatic Data Center (2016). Federal climate complex data 
%   documentatoin for integrated surface data. Asheville, NC: NOAA. 
%   (<https://www.ncdc.noaa.gov/isd>).

% Copyright 2018
% Written by Todd Schultz

%% Validate inputs and outputs
narginchk(3,3);
nargoutchk(1,2);

% weather station
validateattributes(weatherstation,{'char','string'},{'nonempty','scalartext'},mfilename,'weatherstation')

% begin date
validateattributes(begindate,{'char','string'},{'nonempty','scalartext'},mfilename,'begindate')

% end date
validateattributes(enddate,{'char','string'},{'nonempty','scalartext'},mfilename,'enddate')

%% Parameters
% webservices options
opt = weboptions('Timeout',60);

%% Convert date strings to datetime
try
    begindate = datetime(begindate,'TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''z''');
    enddate = datetime(enddate,'TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''z''');
catch err
    error('grabNOAAWeatherData:datetime','Unable to convert input dates using datetime')
end

% force that endate > begindate
assert(enddate >= begindate,'grabNOAAWeatherData:dateOrderError','Begin date is not later then end date.')

%% Read NOAA support data
% The support data provide in the function NOAASupportData comes from the
% NOAA report referenced in the header of this function. 
[varTable,QCTable] = NOAASupportData();

%% Find weather station USAF/WBAN identifier
% Find the USAF/WBAN identifier to use in the NOAA legacy API for the 
% weather station and check to ensure that data for the dates requested is
% available. 
stationtable = findStationIdentifier(weatherstation);
% Combination of 6-digit US AFWA (AWS) identifier and 5-digit WBAN identifier
stationId = char(stationtable.USAF + stationtable.WBAN);

%% Create URL for API data query
% Query for historic hourly weather observation data in the Global Hourly
% dataset with dataset identifier 'global-hourly'. See
% legacyNOAAWalkthrough.mlx live script for demonstration of working with
% the NOAA API to find datasets, stations, etc and for the origins some of 
% the choices below. 

% Base url for data query
baseDataURL = 'https://www.ncdc.noaa.gov/access-data-service/api/v1/data';

% Add dataset identifier
datasetId = 'global-hourly';
dataURL = [baseDataURL '?dataset=' datasetId];

% Add station identifier
dataURL = [dataURL '&stations=' stationId];

% Add datatype identifiers
% Data types to query
% Wind, WND
% Sky condition, CIG
% Visibility, VIS
% Air temparture, TMP
% Dew point temperature, DEW
% Atmospheric pressure, SLP
dataTypeId = 'WND,CIG,VIS,TMP,DEW,SLP';
dataURL = [dataURL '&dataTypes=' dataTypeId];

% Add start and end dates
dataURL = [dataURL '&startDate=' char(begindate) '&endDate=' char(enddate)];

% Add output data format
format = 'json';
dataURL = [dataURL '&format=' format];

% Add output unit system
units = 'metric';
dataURL = [dataURL '&units=' units];

% Add station name and data type attributes
dataURL = [dataURL '&includeStationName=true' '&includeAttributes=true'];

% Retrieve data
weathertable = webread(dataURL,opt);
weathertable = struct2table(weathertable);

%% Parse and convert variables to usable data types
% Convert to time table
weathertable.DATE = datetime(weathertable.DATE,'InputFormat','yyyy-MM-dd''T''HH:mm:ss','TimeZone','UTC');
weathertable = table2timetable(weathertable);

%% REPORT_TYPE
% Convert REPORT_TYPE to a categorical variable. 
vartmp = 'REPORT_TYPE';
convertCategorical(vartmp);
weathertable.Properties.VariableDescriptions{string(weathertable.Properties.VariableNames) == vartmp} = 'Type of geophysical surface observation';

%% STATION and NAME
% Convert the station identifier and name to categorical variables. 
weathertable.STATION = categorical(weathertable.STATION);
weathertable.NAME = categorical(weathertable.NAME);

%% QUALITY_CONTROL
% Convert QUALITY_CONTROL to a categorical variable. This is a code for the
% quality control process applied to the entire row observation.
weathertable.QUALITY_CONTROL = categorical(weathertable.QUALITY_CONTROL);
weathertable.Properties.VariableDescriptions{string(weathertable.Properties.VariableNames) == vartmp} = 'Name of the quality control process applied to a weather observation';

%% SOURCE
% Convert SOURCE to a categorical variable. The source is a code for 
% describing the original source of the data values. 
vartmp = 'SOURCE';
convertCategorical(vartmp);
weathertable.Properties.VariableDescriptions{string(weathertable.Properties.VariableNames) == vartmp} = 'Name or combination of names for the data sources used in creating the observation';

%% TMP (Temperature)
% Convert the temperature variable, TMP, to a numeric value and its quality 
% code. Then remove the scale factor of 10 and assign units of degrees 
% Celsius.

% Convert to numeric values
vartmp = 'TMP';
convertValueQualityCodePair(vartmp);

%% DEW (Dew point temperature)
% Convert the dew point temperature variable, DEW, to a numeric value and 
% its quality code. Then remove the scale factor of 10 and assign units of 
% degrees Celsius.

% Convert to numeric values
vartmp = 'DEW';
convertValueQualityCodePair(vartmp);

%% SLP (Sea level pressure)
% Convert the air pressure relative to mean sea level, SLP, to a numeric 
% value and its quality code. Then remove the scale factor of 10 and assign
% units of HectoPascals (hPa).

% Convert to numeric values
vartmp = 'SLP';
convertValueQualityCodePair(vartmp);

%% WND (Wind)
% The observed wind data consists of three parts: the heading relative to 
% true north from which the wind is blowing, the categorical wind type, 
% and the observed wind speed. The returned string is separated into the 
% three parts, converted to the appropriate data types with the scale 
% factors removed, the quality code separated, and stored with the 
% appropriate metadata.

% Separate wind string
tmp = split(string(weathertable.WND),",");
weathertable.WND_DIR = tmp(:,1) + "," + tmp(:,2);
weathertable.WND_TYPE = tmp(:,3);
weathertable.WND_SPEED = tmp(:,4) + "," + tmp(:,5);

% Convert wind type to categorical
vartmp = 'WND_TYPE';
convertCategorical(vartmp);
weathertable.Properties.VariableDescriptions{string(weathertable.Properties.VariableNames) == vartmp} = 'Category or type of wind observed';

% Convert wind direction to numeric values
vartmp = 'WND_DIR';
convertValueQualityCodePair(vartmp);

% Convert wind direction to numeric values
vartmp = 'WND_SPEED';
convertValueQualityCodePair(vartmp);

% delete original column
weathertable = removevars(weathertable,'WND');

%% VIS (Visibility observation)
% The observed horizontal visibility data consists of four parts: the 
% visibility in distance with a maximum entry value of 160,000 m and its 
% quality control code, and the categorical visibility variability code 
% and its quality control code. The returned string is separated into the 
% four parts, converted to the appropriate data types with the scale 
% factors removed, and stored with the appropriate metadata.

% Separate vis string
tmp = split(string(weathertable.VIS),",");
weathertable.VIS_DIST = tmp(:,1) + "," + tmp(:,2);
weathertable.VIS_VAR = tmp(:,3);
weathertable.VIS_VAR_QC = tmp(:,4);

% Convert visibility variability code to categorical
vartmp = 'VIS_VAR';
convertCategorical(vartmp);
weathertable.Properties.VariableDescriptions{string(weathertable.Properties.VariableNames) == vartmp} = 'Observed horizontal visibility variability code';
weathertable.([vartmp '_QC']) = categorical(weathertable.([vartmp '_QC']),string(QCTable.QualityCode));
weathertable.Properties.VariableDescriptions{string(weathertable.Properties.VariableNames) == [vartmp '_QC']} = 'Observed horizontal visibility variability code quality code';

% Convert visibility distance to numeric values
vartmp = 'VIS_DIST';
convertValueQualityCodePair(vartmp);

% delete original column
weathertable = removevars(weathertable,'VIS');

%% CIG (Sky condition observation)
% The observed sky condition data consists of four parts: the ceiling 
% height with a maximum entry value of 22,000 m and its quality control 
% code, and the categorical ceiling determination and the ceilng and 
% visibility okay condition code. The returned string is separated into 
% the four parts, converted to the appropriate data types with the scale 
% factors removed, and stored with the appropriate metadata.

% Separate CIG string
tmp = split(string(weathertable.CIG),",");
weathertable.CIG_HEIGHT = tmp(:,1) + "," + tmp(:,2);
weathertable.CIG_DETER = tmp(:,3);
weathertable.CIG_CAVOK = tmp(:,4);

% Convert ceiling determination code to categorical
vartmp = 'CIG_DETER';
convertCategorical(vartmp);
weathertable.Properties.VariableDescriptions{string(weathertable.Properties.VariableNames) == vartmp} = 'Observed ceiling determination code';

% Convert ceiling and visibility okay code to categorical
vartmp = 'CIG_CAVOK';
convertCategorical(vartmp);
weathertable.Properties.VariableDescriptions{string(weathertable.Properties.VariableNames) == vartmp} = 'Observed ceiling and visibility okay code';

% Convert ceiling height to numeric values
vartmp = 'CIG_HEIGHT';
convertValueQualityCodePair(vartmp);

% delete original column
weathertable = removevars(weathertable,'CIG');

%% Nested functions
    function stationtable = findStationIdentifier(station)
        %%FINDSTATIONIDENTIFER Find station metadata for the given staion ICAO code
        
        % Find directory path for function
        funname = mfilename('fullpath');
        funpath = fileparts(funname);
        
        % Load station information file
        stationfile = 'isd-history.csv';
        
        formatstr = '%q %q %q %q %q %q %q %q %q %{yyyyMMdd}D %{yyyyMMdd}D';
        warning('off','MATLAB:table:ModifiedAndSavedVarnames')
        stations = readtable(fullfile(funpath,stationfile),'Delimiter',',','Format',formatstr,'TextType','string','DateLocale','en_US');
        warning('on','MATLAB:table:ModifiedAndSavedVarnames')
        
        % Convert numeric fields
        stations.ELEV_M_ = str2double(stations.ELEV_M_);
        stations.LAT = str2double(stations.LAT);
        stations.LON = str2double(stations.LON);
        
        % Format dates
        stations.BEGIN.Format = 'yyyy-MM-dd''T''HH:mm:ss''z''';
        stations.BEGIN.TimeZone = 'UTC';
        stations.END.Format = 'yyyy-MM-dd''T''HH:mm:ss''z''';
        stations.END.TimeZone = 'UTC';
        
        % Filter to requested station ICAO code
        stationtable = stations(stations.ICAO == station,:);
        
        if height(stationtable) > 1
            % Reduce to single station
            stationtable(~(stationtable.BEGIN <= begindate & stationtable.END >= enddate),:) = [];
            [~,Idxlastest] = min(datetime('now','TimeZone',stationtable.END.TimeZone) - stationtable.END);
            stationtable = stationtable(Idxlastest,:);
            stationtable = stationtable(1,:);
        end
        
        % Check that hourly data is available for the requested dates from the
        % requested weather station
        assert(~isempty(stationtable),'grabNOAAWeatherData:findStationIdentifier:dataDateAvailablity', ... 
            'Requested station does not have data available for all requested dates.')
    end

    function convertValueQualityCodePair(vartmp)
        %%CONVERTVALUEQUALITYCODEPAIR parse and convert value quality pair
        scaleFactor = varTable.ScaleFactor(varTable.varName == string(vartmp));
        missingvalue = varTable.Missing(varTable.varName == string(vartmp));
        [weathertable.(vartmp),weathertable.([vartmp '_QC'])] = parseValueQC(string(weathertable.(vartmp)),scaleFactor,missingvalue);
        weathertable.([vartmp '_QC']) = categorical(weathertable.([vartmp '_QC']),string(QCTable.QualityCode));
        
        % Assign metadata
        weathertable.Properties.VariableUnits{string(weathertable.Properties.VariableNames) == vartmp} = char(varTable.Units(varTable.varName == string(vartmp)));
        weathertable.Properties.VariableDescriptions{string(weathertable.Properties.VariableNames) == vartmp} = char(varTable.varDescription(varTable.varName == string(vartmp)));
        weathertable.Properties.VariableDescriptions{string(weathertable.Properties.VariableNames) == [vartmp '_QC']} = char(varTable.varDescription(varTable.varName == string(vartmp)) + " quality code");
    end

    function convertCategorical(vartmp)
        %%CONVERTCATEGORICAL convert categorical variables to meaningful values
        weathertable.(vartmp) = categorical(string(weathertable.(vartmp)),string(varTable.AvailableCodes{varTable.varName == string(vartmp)}.(vartmp)));%,cellstr(varTable.AvailableCodes{varTable.varName == string(vartmp)}.([vartmp '_DESCR'])));
        weathertable = join(weathertable,varTable.AvailableCodes{varTable.varName == string(vartmp)});
        weathertable = standardizeMissing(weathertable,varTable.Missing(varTable.varName == string(vartmp)),'DataVariables',vartmp);
    end
        
end

%% Subfunctions
function [xvalue,xqc] = parseValueQC(xstr,scalefactor,missingvalue)
%% PARSEVALUEQC parces NOAA string to return data value and quality code
% 
% Syntax
% [xvalue,xqc] = parseValueQC(xstr)
% 
% Input
% xstr = cell array of character vectors or string array of observations returned by NOAA webservice legacy API
% scalefactor = scalar value data values multiplied by for encoding into the NOAA archive
% missingvalue = string denoting the characters used for missing entries 
% 
% Outputs
% xvalue = numeric value of the data point
% xqc = quality code string

% Convert to numeric values
xstr = split(xstr,",");
xstr(:,1) = replace(xstr(:,1),missingvalue,"");
xvalue = str2double(xstr(:,1))/scalefactor;
xqc = xstr(:,2);

end