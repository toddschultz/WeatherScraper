function weathertableclean = cleanNOAAWeathertable(weathertableclean)
%%CLEANNOAAWEATHERTABLE cleans NOAA weathertable by removing spurious rows
% Cleans the weather data table from the NOAA API source, typically from
%   the grabNOAAWeatherData function. This function removes any
%   observations with a report type of bogus, or with missing values or 
%   values with a failing quality code. The NOAA data source uses a numeric
%   value with all digits of '9' to represent missing or bogus values for 
%   each numeric data entry. 
%   
% Syntax
% weathertableclean = cleanNOAAWeathertable(weathertable)
% 
% Inputs
% weathertable = time table of weather hourly observation data from grabNOAAWeatherData
%
% Outputs
% weathertableclean = clean weather table
%
%   Example
%      weathertableclean = cleanNOAAWeathertable(weathertable)
% 
%   See also GRABNOAAWEATHERDATA, TIMETABLE, DATETIME

% Reference
% National Climatic Data Center (2016). Federal climate complex data 
%   documentatoin for integrated surface data. Asheville, NC: NOAA. 
%   (<https://www.ncdc.noaa.gov/isd>).

% Copyright 2018
% Written by Todd Schultz

%% Validate inputs and outputs
narginchk(1,1);
nargoutchk(1,1);

% weather station
validateattributes(weathertableclean,{'timetable'},{'nonempty'},mfilename,'weathertable')

%% Variables to removing missing from
% The ceiling and visibility parameters are ignored for removing rows wtih
% missing varables. Only the wind type missing value is considered for the
% wind parameters. 
varRemove = {'REPORT_TYPE','WND_TYPE','TMP','SLP','DEW'};

%% Read NOAA support data
% The support data provide in the function NOAASupportData comes from the
% NOAA report referenced in the header of this function. 
% [varTable,QCTable] = NOAASupportData();

%% Quality Codes
% Quality codes that correspond to failed quality checks, see QCTable
QCfail = categorical(["3"; "7"]);

%% Standardize missing values for each variable
% Note that variables with numeric values had their missing values
% standardized from '999...' to NaN as part of the conversion from text to
% numeric values. 

% SOURCE
% Ignoring the SOURCE field for missing data. The source isn't critical for
% the typical applications the data is used for. 

% REPORT-TYPE
% Standardize BOGUS, SOD (Summary of Day), SOM (Summary of Month) report
% types to missing as only the hourly data was requrested from the 
% grabNOAAWeatherData function. 
weathertableclean = standardizeMissing(weathertableclean,{'BOGUS','SOD','SOM'},'DataVariables','REPORT_TYPE');

% WND_DIR (wind direction)
vartmp = 'WND_DIR';
weathertableclean(ismember(weathertableclean.([vartmp '_QC']),QCfail),:) = [];

% WND_SPEED (wind speed)
vartmp = 'WND_SPEED';
weathertableclean(ismember(weathertableclean.([vartmp '_QC']),QCfail),:) = [];

% VIS_DIST (Visibility distance)
vartmp = 'VIS_DIST';
weathertableclean(ismember(weathertableclean.([vartmp '_QC']),QCfail),:) = [];

% CIG_HEIGHT (ceiling height)
vartmp = 'CIG_HEIGHT';
weathertableclean(ismember(weathertableclean.([vartmp '_QC']),QCfail),:) = [];

%% Remove missing values
% Remove any row with a missing value for any variable using MATLAB default
% representations of missing values. 
weathertableclean = rmmissing(weathertableclean,'DataVariables',varRemove);

end