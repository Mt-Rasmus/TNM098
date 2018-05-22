% GPS data reduction

% Read data
GPS = readtable('gps.csv');

%%

GPSreduced = GPS(1:2:end,:);
GPSreduced = GPSreduced(1:2:end,:);
GPSreduced = GPSreduced(1:2:end,:);

writetable(GPSreduced,'GPSreduced.csv');

