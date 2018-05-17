
% Read data

M = readtable('gps.csv');
S = shaperead('Abila.shp');
[Msort, idx] = sortrows(M,{'id'}); % sorting table by car id

%%
cc_data = readtable('cc_data.csv');
employee_data = readtable('car-assignments.csv');

%%

uniqueCCnames = unique(cc_data(:,4:5));

specials = ismember(uniqueCCnames, employee_data(:,1:2));
specIdx = find(specials ~= 1);
uniqueCCnames = uniqueCCnames(specIdx,1:2);

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

% find places that are only visited by people with carID:s 101, 103-107:
% pick out all GPS coord for carID 101 and plot the locations at times
% listed for a place in loc_trans.
% Pick out the times in 101 that are closest to the time that the place has
% been visited. Plot them and see if they are close to the target place.

% carNR = [];
% carNR(1) = 101;

% 1, 2, 9, 12, 26, 27, 28, 33 % places that only truck drivers went to.
% 4, 12
% truck_drivers contains all truck driver names

clc

truck_drivers = employee_data(36:44, 1:2);
placeList = table2array(cc_data(:,2));
placeList = unique(placeList);
tr_idx = [1, 2, 9, 12, 26, 27, 28, 33];
trucker_places = placeList(tr_idx);

% Results:
% Trucker identities:
% 101 - Albina (ID 5 and 6)
% 104 - Henk (ID 1)
% 105 - Valeria (placeIND 3 (Carlyle Chemical Inc.) (Valeria/Cecilia placeIND 8 (Nationwide Refinery))
% 106 - Dylan (ID 1 and 2 and 7)
% 107 - Irene (ID 5 and 6)

currID = 106;
carNR = array2table(currID);
carNR.Properties.VariableNames{'currID'} = 'CarID';

car_idx_nans = ismember(M(:,2),carNR);
car_pos_nans = M(car_idx_nans,:); % pick out all GPS samples for current carID

% ver 2

    % Missing locations: 5 (Kronos Pipe and Irrigation) (look car ID 107 (Irene) and Albina ID 5)                  
    %                    8 (Stewart and Sons Fabrication) (look  car 106 (Dylan))
    
    tr_idx_idx = 7; % 1-8 Change this to pick new location!
    locIdx = tr_idx(tr_idx_idx); % Pick one place index
    currCellLoc = loc_trans{locIdx}; % Pick one place cell in loc_trans
    disp(currCellLoc(1,:).location);
    uniqueNames = unique(currCellLoc.FirstName);

% 

% The plot answers:
% where was carID nr X at the time of these peoples transactions
% Notes: there are 9 truck drivers, but only 6 trucker IDs.
% Identify these truck drivers, and look at the behaiviour of the remaining 3.

pINDS = {};
clusters = {};
namesVec = [];

for p = 1:size(uniqueNames) % loop as many times as there are unique names in location table
    
    currName = uniqueNames(p); % pick first name
    personIDX = [];
    
    for p2 = 1:size(currCellLoc) % find all samples with current name
       
       namestring = loc_trans{locIdx}(p2,4);
       namestring = namestring.FirstName{1};
       
       if (strcmp(namestring, currName))
           personIDX = [personIDX, p2]; % extracting all indices of current name
       end
        
    end
    
    pINDS{p} = personIDX;
    currNameSamples = loc_trans{locIdx}(personIDX,:); % Extract all samples from chosen person

    % Find all och the closest times in cc_data to currNameSamples
    sizeCurrNameSamples = size(currNameSamples);
    nrIDX = zeros(sizeCurrNameSamples(:,1), 1);
    
    for s = 1:size(currNameSamples)

        timeStamp1 = currNameSamples(s,:).timestamp;
        timediff1 = abs(car_pos_nans.timestamp - timeStamp1);
        [~, nrIDX(s)] = min(timediff1);
       
    end
    
        clusters{p} = car_pos_nans(nrIDX,:);
    
end

% Plot

cluster_plot(clusters, uniqueNames);

% Results:
% Trucker identities:
% 101 - Albina (ID 5 and 6)
% 104 - Henk
% 105 - Valeria (placeIND 3 (Carlyle Chemical Inc.) (Valeria/Cecilia placeIND 8 (Nationwide Refinery))
% 106 - Dylan (ID 1 and 2 and 7)
% 107 - Irene (ID 5 and 6)

% UKNOWNS:
% Benito Hawelon
% Claudio
% Adan Morlun
% Cecilia
% Varro Awelon - NOT TRUCK DRIVER. not in car assignments / GPSdata
