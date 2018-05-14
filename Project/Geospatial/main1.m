
% Read data

M = readtable('gps.csv');
S = shaperead('Abila.shp');
[Msort, idx] = sortrows(M,{'id'}); % sorting table by car id

%%
cc_data = readtable('cc_data.csv');



employee_data = readtable('car-assignments.csv');

%% Finding the coordinates for the diffeent locations in cc_data

locations = unique(cc_data.location);

l = size(locations);

loc_trans = {};

M.Properties.VariableNames{'id'} = 'CarID';
M.Properties.VariableNames{'Timestamp'} = 'timestamp';

closest_positions = {};

%%

tic

for i = 10:12

t = ismember(cc_data.location, locations{i});
loc_trans{i} = cc_data(t,:);

[r,~] = size(loc_trans{i});




for j = 1:r
    

person_idx = ismember(employee_data(:,1:2), loc_trans{i}(j,4:5));
car_id = employee_data(person_idx,3);

most_recent_pos = {};

 if ~isnan(car_id.CarID)
     


timeStamp = loc_trans{i}(j,1).timestamp;


car_idx = ismember(M(:,2),car_id);

car_pos = M(car_idx,:); 

tupper = timeStamp + minutes(5);
tlower = timeStamp - minutes(10);

nearest_t = isbetween(car_pos.timestamp, tlower,tupper);

most_recent_pos = car_pos(nearest_t,:);


 else
     most_recent_pos{j} = {};
     

 end

end

closest_positions{i} = most_recent_pos;


end

toc


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
