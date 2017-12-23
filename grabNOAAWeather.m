% NOAA Weather data
% NCDC = 



% API documentation page
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



% find all locations
findLocsURL = 'https://www.ncdc.noaa.gov/cdo-web/api/v2/locations';



opt = weboptions('KeyName','token','KeyValue','iGdztnFFxUfLOpDjBFylVdPCsnGaoaPS');



url = 'http://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=GHCND&locationid=ZIP:28801&startdate=2010-05-01&enddate=2010-05-01';

data = webread(url,opt);