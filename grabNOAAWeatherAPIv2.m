% NOAA Weather data
% NCDC = 



% APIv2 documentation page
% https://www.ncdc.noaa.gov/cdo-web/webservices/v2
%   NCDC's Climate Data Online (CDO) offers web services that provide 
%   access to current data. This API is for developers looking to create 
%   their own scripts or programs that use the CDO database of weather and 
%   climate data. An access token is required to use the API, and each 
%   token will be limited to five requests per second and 10,000 requests 
%   per day.

% Site to request token
% token is required to be in the header of the request
% https://www.ncdc.noaa.gov/cdo-web/token

% base url
% https://www.ncdc.noaa.gov/cdo-web/api/v2/{endpoint}

% Endpoints

coopID = 457473; % KSEA
% coopID = 305811; % KLGA

%% NOAA token
funname = mfilename('fullpath');
[funpath,funname] = fileparts(funname);

tokenfname = 'NOAAtoken.txt';
token = readtable(fullfile(funpath,tokenfname),'TextType','string');

opt = weboptions('KeyName','token','KeyValue',token.token,'Timeout',120);

%% Find station information
findStationURL = ['https://www.ncdc.noaa.gov/cdo-web/api/v2/stations/COOP:' num2str(coopID)];
station = webread(findStationURL,opt);

%% Query available weather datasets
findWeatherURL = 'https://www.ncdc.noaa.gov/cdo-web/api/v2/datasets/';
weather = webread(findWeatherURL,'stationid',['COOP:' num2str(coopID)],opt);
