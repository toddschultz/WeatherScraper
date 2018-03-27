function weathertable = GrabWeatherData(weatherlocation,begindate,enddate)
%% GRABWEATHERDATA imports weather data from wunderground.com using ICAO
% Reads weather data from the wunderground.com website using the urlread 
%   command in MATLAB for all days in the incluseive date range specified. 
%   The dates should be in one of the standard formats described in the 
%   help for the datestr function. The ICAO code for Boeing Field is
%   'KBFI' and for Sea-Tac is 'KSEA'. A complete listing of ICAO codes can
%   be found at <http://weather.noaa.gov/data/nsd_cccc.txt> or also see 
%   <http://en.wikipedia.org/wiki/ICAO_airport_code>. 
%   
%   This function uses the table feature available beginning in MATLAB 
%   R2013b, the datetime data type available beginning in MATLAB R2014b and
%   time tables available beginning in MATLAB R2016b. 
%
% See also DATETIME, TIMETABLE, DATESTR
% 
% Syntax
% weathertable = GrabWeatherData(weatherlocation,begindate,enddate)
% 
% Inputs
% weatherlocation = four letter string for location's ICAO code, e.g. 'KBFI'
% begindate = begining date of range of interest in datestr format, e.g. '01-Jan-2016'
% enddate = end date of range of interest in datestr format, e.g. '26-Jan-2017'
%
% Outputs
% weathertable = time table of weather data

% Copyright 2009 - 2011
% Written by Richard Willey
% Copyright 2014-2016
% Written by Todd Schultz

%% Validate inputs and outputs
narginchk(3,3);
nargoutchk(1,1);

% weatherlocation
validateattributes(weatherlocation,{'char'},{'nonempty'})

%% Convert date strings to datetime
try
    begindate = datetime(begindate);
    enddate = datetime(enddate);
catch err
    error('GrabWeatherData:datetime','Unable to convert input dates using datetime')
end

% force that endate > begindate
assert(enddate > begindate,'GrabWeatherData:dateOrderError','Begin date is not later then end date.')

% find duration in days
dt = days(enddate - begindate);

%% Loop through dates, scraping daily data and adding to the dataset array
%weathertable = table;
wcell = cell(dt+1,1);

parfor idate = 0:dt
    try
        wcell{idate+1} = ScrapeDailyWeather(begindate + idate*duration(24,0,0),weatherlocation);
    catch
        disp(['Error gathering or joining data from url at ' char(begindate + idate*duration(24,0,0))])
    end
end
weathertable = vertcat(wcell{:});

end

%% Subfunction
function w = ScrapeDailyWeather(passdate,WeatherLocation)
%Scrapes web site for daily weather and saves to dataset array
%   This function is used with the Weather demo.  It demonstrates data 
%   input by scrapping web sites with daily weather data.  
%   The url used is:
%       'http://www.wunderground.com/history/airport/KBOS/2015/1/1/
%                                               DailyHistory.html?format=1'
%   This function formats the url with the date and location passed as
%   arguments.

% Copyright The MathWorks, Inc. 2009
% Copyright 2016 Todd Schultz
 
% Convert date from datetime to string of yyyy/mm/dd format
passdatestr = [num2str(passdate.Year) '/' num2str(passdate.Month) '/' num2str(passdate.Day)];

% Create and read the url
urlhead = 'https://www.wunderground.com/history/airport/';
urltail = '/DailyHistory.html?format=1';
url = [urlhead WeatherLocation '/' passdatestr urltail]; 

s = urlread(url);

% Remove leading and trailing white space
s = strtrim(s);

% Split header from data
expr = '<(.*?)>';
idx = regexp(s, expr);

header = s(1:idx(1)-1);
s = s(idx(1):end);

% Check data present (commas present)
if isempty(regexp(s, ',', 'once'))
    w = table;
    return;
end

% Remove newlines
expr = '\n';
header = regexprep(header, expr, '');
s = regexprep(s, expr, '');

% Remove html tags
expr = '<(.*?)>';
header = regexprep(header, expr, '');
s = regexprep(s, expr, ',');
 
% Remove leading commas
loop = 0;
while strcmp(',',header(1)) && loop < 10
    loop = loop + 1;
    header = header(2:end);
end

loop = 0;
while strcmp(',',s(1)) && loop < 10
    loop = loop + 1;
    s = s(2:end);
end

% Remove trailing commas
loop = 0;
while strcmp(',',header(end)) && loop < 10
    loop = loop + 1;
    header = header(1:end-1);
end

loop = 0;
while strcmp(',',s(end)) && loop < 10
    loop = loop + 1;
    s = s(1:end-1);
end
 
% Convert to cell array
expr = ',';
header = regexp(header, expr, 'split');
nItems = length(header);

tok = regexp(s, expr, 'split');
tok = reshape(tok,nItems,[])';

% Prep for date table
vnames = matlab.lang.makeValidName(header);
% change local time variable header from downloaded to 'LocalTime' to
% prevent different variable names due dates crossing time change due to
% day light savings time, i.e. 'TimePDT' to 'TimePST'. This will avoid
% errors when joining the tables together. 
Idx = cellfun(@(x) ~isempty(strfind(x,'Time')),vnames);
vnames{Idx} = 'LocalTime';
% ensure variable name of 'TimeUTC' for the UTC date/time column
Idx = cellfun(@(x) ~isempty(strfind(x,'UTC')),vnames);
vnames{Idx} = 'TimeUTC';

% add date to time
time = tok(:,1);
daten = cellfun(@(x)[datestr(passdate) ' ' x],time,'UniformOutput', false);
tok(:,1) = daten;

% Convert to data table
w = cell2table(tok,'VariableNames',vnames);

% Convert data typs
w.LocalTime = datetime(w.LocalTime,'TimeZone','');
w.TimeUTC = datetime(w.TimeUTC,'TimeZone','UTC');
w.(vnames{2}) = str2double(w.(vnames{2}));
w.(vnames{3}) = str2double(w.(vnames{3}));
w.(vnames{4}) = str2double(w.(vnames{4}));
w.(vnames{5}) = str2double(w.(vnames{5}));
w.(vnames{6}) = str2double(w.(vnames{6}));
w.(vnames{8}) = str2double(w.(vnames{8}));
w.(vnames{9}) = str2double(w.(vnames{9}));
w.(vnames{10}) = str2double(w.(vnames{10}));
w.(vnames{13}) = str2double(w.(vnames{13}));

% Convert table to time table using TimeUTC as the time key
w = table2timetable(w,'RowTimes','TimeUTC');

end