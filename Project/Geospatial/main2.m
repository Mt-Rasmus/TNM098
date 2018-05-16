
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



for i = 1:l % loops through each cell in loc_trans, representing visited places.
    t = ismember(cc_data.location, locations{i});
    loc_trans{i} = cc_data(t,:);  
end


 %% 
 % connect trucker drivers and IDs and find missing places
 % only they have traveled to.

% GPS has           time, place and carID 101-107
% loc_trans has     time, place and name
% cc_data has       time, place and name
% employee_data has name and carID (1-35) i.e. not 101-107

% find places that are only visited by people with carID:s 101-107:
% pick out all GPS coord for carID 101 and plot the locations at times
% listed for a place in loc_trans.
% Pick out the times in 101 that are closest to the time that the place has
% been visited. Plot them and see if they are close to the target place.

% carNR = [];
% carNR(1) = 101;

% 1, 2, 9, 12, 26, 27, 28, 33 % places that only truck drivers went to.
% 4, 12
% truck_drivers contains all truck driver names

truck_drivers = employee_data(36:44, 1:2);
placeList = table2array(cc_data(:,2));
placeList = unique(placeList);
tr_idx = [1, 2, 9, 12, 26, 27, 28, 33];
trucker_places = placeList(tr_idx);

currID = 101;
carNR = array2table(currID);
carNR.Properties.VariableNames{'currID'} = 'CarID';

car_idx_nans = ismember(M(:,2),carNR);
car_pos_nans = M(car_idx_nans,:); % pick out all GPS samples for current carID

clusters = {};
nearIDX = [];

%%

for p = 1:length(tr_idx)

    locIdx = tr_idx(p); % Pick one name
    currCellLoc = loc_trans{locIdx}; % Pick one location cell in loc_trans
    currName = currCellLoc(1,4:5);

    personIDX = ismember(loc_trans{locIdx}(:,4:5), loc_trans{locIdx}(1,4:5));
    currNameSamples = loc_trans{locIdx}(personIDX,:); % Extract all samples from chosen person

    % Find all och the closest times in cc_data to currNameSamples
    for s = 1:size(currNameSamples)

        timeStamp1 = currNameSamples(s,:).timestamp;
        timediff1 = abs(car_pos_nans.timestamp - timeStamp1);
        [~, nrIDX] = min(timediff1(:));
        nearIDX(s) = nrIDX;
    end

        clusters = [clusters, car_pos_nans(nearIDX,:)];
    
end

%%
tic

for i = 1:l % loops through each cell in loc_trans, representing visited places.

    t = ismember(cc_data.location, locations{i});
    loc_trans{i} = cc_data(t,:);

    [r,~] = size(loc_trans{i});

    most_recent_pos = {};

        for j = 1:r % loops through each element in loc_trans{j} (times a certain place has been visited)

            person_idx = ismember(employee_data(:,1:2), loc_trans{i}(j,4:5));
            car_id = employee_data(person_idx,3); % car ID for particlar person

            if ~isnan(car_id.CarID)

                timeStamp = loc_trans{i}(j,1).timestamp;

                car_idx = ismember(M(:,2),car_id);

                car_pos = M(car_idx,:); % pick out all positions for current carID

                [rows,~] = size(car_pos);

                timediff = abs(car_pos.timestamp - timeStamp);

                [nearest, nIDX] = min(timediff);

                most_recent_pos{j} = car_pos(nIDX,:); % saves the positions from GPS that are closest to cc buy time

                % tupper = timeStamp + minutes(5);
                % tlower = timeStamp - minutes(10);
                % 
                % nearest_t = isbetween(car_pos.timestamp, tlower,tupper);
                % 
                % 

            else
                most_recent_pos{j} = {};

            end

        end

    closest_positions{i} = most_recent_pos;

end

toc

%%

[~,c1] = size(closest_positions);
coord = {};

for m = 1:c1 % loops through all locations
   
    [~,c2] = size(closest_positions{m});
    
    for n = 1:c2 % loops through all the GPS coords closest to cc buy times.
       
        p = closest_positions{m}(:,n); % a single sample (time and place and carID)
           
        if ~isempty(p{1})
            
            coord = [coord,p]; % saves all these samples
 
        end
            
    end
        
end

%%

[~,col] = size(coord);

longitude = [];
latitude = [];

for s = 1:col
    
    longitude(s,:) = coord{s}.long;
    latitude(s,:) = coord{s}.lat;
    
end


%% Extract samples based on car ID and day.

% xd = table2array(Msort(:,1));
% x = table2array(Msort(:,2:4));
% 
% carID = 3;
% theday = 7;
% 
% IDidx = find((x(:,1)==carID)); % Saves all indices of certain ID
% 
% IDxd = xd(IDidx); % Pick out all the dates that have the chosen ID
% 
% IDidxDate = find(day(IDxd)==theday); % Pick out all indices in IDxd of a certain date. What index nrs do they have in x?
% 
% finalInds = IDidx(IDidxDate); % Now find the date indices in the ID index list
% 
% samples = x(finalInds,:); % get samples with chosen ID and date


%% Plot

figure

mapshow(S);

% lon=[samples(:,2)]; % X=long 
% lat=[samples(:,3)]; % Y=lat
% 
% col = lon;

hold on

% plot(lat,lon, 'r.-', 'LineWidth', 1, 'MarkerSize', 1);
%surface([lat';lat'],[lon';lon'],[col';col'], 'LineWidth', 5, 'MarkerSize', 1, 'facecol', 'no', 'edgecol', 'interp', 'linew', 2);
scatter(longitude, latitude);
