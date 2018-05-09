
% Read data

M = readtable('gps.csv');
S = shaperead('Abila.shp');
[Msort, idx] = sortrows(M,{'id'}); % sorting table by car id


%% Extract samples based on car ID and day.

xd = table2array(Msort(:,1));
x = table2array(Msort(:,2:4));

carID = 3;
theday = 7;

IDidx = find((x(:,1)==carID)); % Saves all indices of certain ID

IDxd = xd(IDidx); % Pick out all the dates that have the chosen ID

IDidxDate = find(day(IDxd)==theday); % Pick out all indices in IDxd of a certain date. What index nrs do they have in x?

finalInds = IDidx(IDidxDate); % Now find the date indices in the ID index list

samples = x(finalInds,:); % get samples with chosen ID and date


%% Plot

figure

mapshow(S);

lon=[samples(:,2)]; % X=long 
lat=[samples(:,3)]; % Y=lat
col = lon;

hold on

% plot(lat,lon, 'r.-', 'LineWidth', 1, 'MarkerSize', 1);
surface([lat';lat'],[lon';lon'],[col';col'], 'LineWidth', 5, 'MarkerSize', 1, 'facecol', 'no', 'edgecol', 'interp', 'linew', 2);
