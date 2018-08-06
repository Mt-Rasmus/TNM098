
% Read data

M = readtable('gps.csv');
S = shaperead('Abila.shp');
[Msort, idx] = sortrows(M,{'id'}); % sorting table by car id

%%
cc_data = readtable('cc_data.csv');



employee_data = readtable('car-assignments-v2.csv');

%% Finding the coordinates for the diffeent locations in cc_data

locations = unique(cc_data.location);

l = size(locations);

loc_trans = {};

M.Properties.VariableNames{'id'} = 'CarID';
M.Properties.VariableNames{'Timestamp'} = 'timestamp';

closest_positions = {};

%%

tic

for i = 1:l

t = ismember(cc_data.location, locations{i});
loc_trans{i} = cc_data(t,:);

[r,~] = size(loc_trans{i});


most_recent_pos = {};
no_id_idx = [];

for j = 1:r
    

person_idx = ismember(employee_data(:,1:2), loc_trans{i}(j,4:5));
car_id = employee_data(person_idx,3);



 if ~isnan(car_id.CarID)
     


timeStamp = loc_trans{i}(j,1).timestamp;


car_idx = ismember(M(:,2),car_id);

car_pos = M(car_idx,:);

[rows,~] = size(car_pos);

   
timediff = abs(car_pos.timestamp - timeStamp);
    
[nearest, nIDX] = min(timediff);
cell = {};
cell{1} = car_pos(nIDX,:);
%most_recent_pos{j} = car_pos(nIDX,:);
 most_recent_pos = [most_recent_pos, cell];

 else
     no_id_idx = [i,j];
     %most_recent_pos{j} = {};
     

 end

end


closest_positions{i} = most_recent_pos;


end

toc

%%

[~,c1] = size(closest_positions);
location_coord = {};


for m = 1:c1
   
    [~,c2] = size(closest_positions{m});
    coord = [];
    
    
    for n = 1:c2
       
        p = closest_positions{m}(:,n);
        
        coord(n,:) = table2array(p{1}(:,2:4));
%         if ~isempty(p{1})
%             
%             coord = [coord,p];
%  
%         end
%             

    end
    
    location_coord{m} = coord;
    
    
    
end

%%

% [~,col] = size(coord);
% 
% longitude = [];
% latitude = [];
% 
% for s = 1:col
%     
%     longitude(s,:) = coord{s}.long;
%     latitude(s,:) = coord{s}.lat;
%     
% end

%% Find the optimal eps for DBSCAN


positions = {};
%%http://iopscience.iop.org/article/10.1088/1755-1315/31/1/012012/pdf
for v = 1:c1
    
    [length, ~] = size(location_coord{v});
    if ~isempty(location_coord{v})
    
    for o = 1:length
        
        positions = [positions,location_coord{v}(o,2:3)];
        
        
    end
    
    end
end

positions = cat(1,positions{:});

[IDX,D] = knnsearch(positions,positions, 'K',5);

%%

sorted = sort(D,2);

nearestNeighborDist = sort(sorted(:,5));

[nr_points,~] = size(nearestNeighborDist);

x = 1:nr_points;

figure

scatter(x,nearestNeighborDist);
%[X,Y] = getpts; %To zoom: comment this line and run it in command window after zooming 



%% Create clusters for each location

clusters = {};
noClustersIdx = [];
foundLocations = [];
locationIDX = 1;

for v = 1:c1
    
   if ~isempty(location_coord{v})
       
       pos = location_coord{v}(:,2:3);
        
        [clusterIDX, isnoise] = DBSCAN(pos, 0.00015, 3);
        
        clusterIDX = logical(clusterIDX);
        
        pos = pos(clusterIDX,:);
        
        if ~isempty(pos)
        
        %clusters = [clusters,pos];
        clusters{locationIDX} = pos;
        foundLocations{locationIDX} = locations{v};
        locationIDX = locationIDX + 1;
        
        else
            noClustersIdx = [noClustersIdx, v];
        
        end
        
    end
    
    
end

%% Determine coordinates for each location 
%  by calculaing the centriod for each cluster

[~,clustersize] = size(clusters);
centroids = [clustersize,2];

for c = 1:clustersize
    

    centroids(c,:) = calcCentroid(clusters{c});

end

%% Create CSV file with location coords
foundLocations = reshape(foundLocations, [28,1]);

centroidTable = table(foundLocations, centroids(:,1), centroids(:,2),'VariableNames', {'location','lat','long'});

%writetable(centroidTable,'locations-v2.csv');

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

%lon=[samples(:,2)]; % X=long 
%lat=[samples(:,3)]; % Y=lat

%col = lon;
Color = distinguishable_colors(35);
pntColor = distinguishable_colors(height(locationsV3));


hold on


% plot(lat,lon, 'r.-', 'LineWidth', 1, 'MarkerSize', 1);
%surface([lat';lat'],[lon';lon'],[col';col'], 'LineWidth', 5, 'MarkerSize', 1, 'facecol', 'no', 'edgecol', 'interp', 'linew', 2);

% [nrCentroids,~] = size(centroids);
% pntColor = distinguishable_colors(nrCentroids);
% hold on
% for C = 1:nrCentroids
%     
%     scatter(centroids(C,2),centroids(C,1), 500, pntColor(C,:),'filled', 'Marker','o');
%     
% end
% 
% foundLocations = reshape(foundLocations, [28,1]);
% 
% legend(foundLocations, 'FontSize', 20, 'Location', 'northeast');
hold on
for k = 1:height(locationsV3)
scatter(locationsV3(k,:).long, locationsV3(k,:).lat, 500, pntColor(k,:), 'filled', 'Marker','o');
end


legend(locationsV3(:,:).location, 'FontSize', 20, 'Location', 'northeast');

% Plot locaions for each employee at the end of the day


% for k = 1:length(employeeHome)
%    
%     scatter(homecentroids(k,2), homecentroids(k,1), 2000, Color(k,:));
%     
% end
 
  %  scatter(GASCentroid(2), GASCentroid(1), 500,'filled','Marker','o');
   

%% Finding coordinates for each employees home

[nrEmployees,~] = size(employee_data);

% nighthours = hours(1:5);
% 
% night = M(:,:).timestamp.Hour >= 1 & M(:,:).timestamp.Hour <= 5;
% 
% nightpos = M(night,:);
employeeHome = {nrEmployees};
empIDs = zeros(nrEmployees-9,1);
noonPositions = {35};

for q = 1:nrEmployees - 9
    
    % Start and end time
    h1 = 7;
    h2 = 12;
    
    
    empID = employee_data(q,:).CarID;
    empIDs(q) = empID;
    
    cIDX = M(:,:).CarID == empID;
    carPos = M(cIDX, :);
    
    %Pick out the positions for the employee ------->
    indices = carPos.timestamp.Hour >= h1 & carPos.timestamp.Hour <= h2;
    POS = carPos(indices,:);
    [x, ~] = size(POS);
    noonPos = zeros(x,2);
    noonPos(:,1) = POS.lat;
    noonPos(:,2) = POS.long;
    noonPositions{q} = POS; % <---------
    
    days = unique(carPos(:,:).timestamp.Day);
    [nrdays, ~] = size(days);
    endOfDayPos = zeros(nrdays,2);
     
    
    for d = 1:nrdays
        
        
        carPosIDX = carPos(:,:).timestamp.Day == days(d,:);
        CP = carPos(carPosIDX,:);
        [n,~] = size(CP);
        carPosDate = zeros(n,2);
        
        carPosDate(:,1) = CP.lat; 
        carPosDate(:,2) = CP.long;
        endOfDayPos(d,:) = carPosDate(end,:);
        
    
    end
    
    employeeHome{q} = endOfDayPos;
    
end

%% Use DBSCAN in order to find centroids

clusterPoints = {};

for c = 1:length(employeeHome)

[clusterIndex, isNoise] = DBSCAN(employeeHome{c},0.00015, 3);

clusterIndex = logical(clusterIndex);

clusterPoints{c} = employeeHome{c}(clusterIndex,:);


end

%%
[~,NrClusters] = size(clusterPoints);
homecentroids = [NrClusters,2];

for p = 1:NrClusters
    
    homecentroids(p,:) = calcCentroid(clusterPoints{p});

end

%%

homeTable = table(empIDs, homecentroids(:,1), homecentroids(:,2),'VariableNames', {'location','lat','long'});

%% Find GasTech coord

[~,L] = size(noonPositions);

lastPosB4Work = {L};

tic

for j = 1:L
    
    
    uDays = unique(noonPositions{j}(:,:).timestamp.Day);
    [nrDays, ~] = size(uDays);
    endOfDayPos = zeros(nrDays,2);
    
    %for z = 1:zSize-1
    
    for z = 1:nrDays
        
    carIDX = noonPositions{j}(:,:).timestamp.Day == uDays(z,:);
    datePos = noonPositions{j}(carIDX,:);
    
    [Size,~] = size(datePos);
    
    max = duration(0,0,0);
    
    if Size > 1
    
    for y = 1:Size-1
    
    diff = abs(datePos(y,:).timestamp - datePos(y+1,:).timestamp);
    
    
    if diff > max
        max = diff;
        index = y;
    end
   
    end
       
    endOfDayPos(z,1) = datePos(index,:).lat;
    endOfDayPos(z,2) = datePos(index,:).long;

    else
        endOfDayPos(z,1) = datePos(:,:).lat;
        endOfDayPos(z,2) = datePos(:,:).long;
    end
    
    end
    
   lastPosB4Work{j} = endOfDayPos;
       
    
end

toc


%% 
GASPos = [];

 for p = 1:length(lastPosB4Work)
     
    [S, ~] = size(lastPosB4Work{p});
    
    for v = 1:S
       
        GASPos = [GASPos, lastPosB4Work{p}(v,:)];
        
    end
     
 end

%%

GASPos = [];

 for p = 1:length(lastPosB4Work)
     
    [S, ~] = size(lastPosB4Work{p});
    
    for v = 1:S
       
        ey = lastPosB4Work{p}(v,:);
     %   GASPos = [GASPos, lastPosB4Work{p}(v,:)];
        GASPos(end+1,1) = ey(1);
        GASPos(end,2) = ey(2);
        
    end
     
 end
 
 
 %% Calc GAS centroid
 
     
     [GASIDX, noise] = DBSCAN(GASPos,0.00015,3);
        
     clusterIDX = logical(GASIDX);
     
     GASCluster = GASPos(clusterIDX,:);
     
     
     GASCentroid = calcCentroid(GASCluster);
 
%% Add GAStech coordinates to locations table
st = {'GAStech'};

t2 = table(st, GASCentroid(1), GASCentroid(2),'VariableNames', {'location','lat','long'});

locationsV3 = [centroidTable; t2];
%%

     
writetable(locationsV3,'locations-v3.csv');

