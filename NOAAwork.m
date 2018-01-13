%% find all locations
findLocsURL = 'https://www.ncdc.noaa.gov/cdo-web/api/v2/locations';
locs = webread(findLocsURL,opt);

findStaiontsURL = 'https://www.ncdc.noaa.gov/cdo-web/api/v2/stations';
stations = webread(findStaiontsURL,opt);

findLocCatURL = 'https://www.ncdc.noaa.gov/cdo-web/api/v2/locationcategories?limit=1000';
locCat = webread(findLocCatURL,opt);


findSEAStationURL = 'https://www.ncdc.noaa.gov/cdo-web/api/v2/stations/COOP:457473';
SEAstation = webread(findSEAStationURL,opt);

findSEAStationURL = 'https://www.ncdc.noaa.gov/cdo-web/api/v2/stations/ICAO:KSEA';
SEAstation = webread(findSEAStationURL,opt);

url = 'http://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=GHCND&locationid=ZIP:28801&startdate=2010-05-01&enddate=2010-05-01';
data = webread(url,opt);

