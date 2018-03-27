Weather Scraper Project

This project contains MATLAB functions to import historical hourly weather 
observations from internet sources into MATLAB as a table. The original 
data source was the Weather Underground at <www.wunderground.com>. However, 
the Weather Underground has gone through changes in ownership and now 
requires a paid subscription for access to most of its data. Thus a search 
was conducted in 2017 through 2018 to find a suitable replacement and NOAA 
was discoverd to have all of the desired data through its webservices at 
<https://www.ncdc.noaa.gov/data-access>. A new function, grabNOAAWeatherData, 
was created replace the old function, GrabWeatherData, using the new data 
source. 

Again, the ICAO codes are used to identify the desired weather station to 
pull the data from. However, the new function requires an external file to 
convert the ICAO codes into the alphanumeric USAF/WBAN station identifers 
used by the legacy webservice hosted by NOAA at <https://www.ncei.noaa.gov/support/access-data-service-api-user-documentation>.

List of important files
* GrabWeatherData.m - original MATLAB function using the Weather Underground 
        as the data source. This function no longer works due to changes in 
        the Weather Underground changes.
* grabNOAAWeatherData.m - replacement MATLAB function using NOAA as the data
        source. 
* cleanNOAAWeatherData.m - MATLAB function to remove rows with missing values 
        from valiarbles of interest such as temperature, dew point temperature,
        and atmospheric pressure.
* NOAASupportData - MATLAB function with metadata, constriants, and other information
        about the allowable values for each of the variables. 
* legacyNOAAAPI.mlx - a MATLAB live script demonstrating how to use the legacy 
        webservice API offered by NOAA.
* isd-history.csv - text file from NOAA ftp site that contains a listing of 
        the weather stations with both USAF/WBAN identifiers and their ICAO
        codes. <ftp://ftp.ncdc.noaa.gov/pub/data/noaa/>

NOTE:
A bug was discovered in the libraries MATLAB was using for connecting to 
RESTful API in versions R2016a through R2017b when using a Proxy server. The 
issue has been fixed in MATLAB R2018a. The functions also use the time table 
feature in MATLAB, which was introduced in R2016a. Thus, the funcitons provide 
require MATLAB R2018a or newer to work properly on the Boeing network. 
