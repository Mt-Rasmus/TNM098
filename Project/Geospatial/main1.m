
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

%%
% [~,c1] = size(closest_positions);
% 
% 
% for m = 1:c1
%    
%     [~,c2] = size(closest_positions{m});
%     latsum = 0;
%     longsum = 0;
%     
%     for n = 1:c2
%        
%         latsum = latsum + closest_positions{m}{n}(:,3);
%         longsum = longsum + closest_positions{m}{n}(:,4);
%             
%         
%     end
%     
%     latmean = latsum/c2;
%     longmean = longsum/c2;
%     
%     
% end

positions = {};
%%Find the optimal eps for DBSCAN
%http://iopscience.iop.org/article/10.1088/1755-1315/31/1/012012/pdf
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



%%

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

hold on


% plot(lat,lon, 'r.-', 'LineWidth', 1, 'MarkerSize', 1);
%surface([lat';lat'],[lon';lon'],[col';col'], 'LineWidth', 5, 'MarkerSize', 1, 'facecol', 'no', 'edgecol', 'interp', 'linew', 2);

[~,nrClusters] = size(clusters);
pntColor = distinguishable_colors(nrClusters);
hold on
for C = 1:nrClusters
    
    scatter(clusters{C}(:,2),clusters{C}(:,1), 10, pntColor(C,:),'filled', 'Marker','o');
    
end

legend(foundLocations, 'FontSize', 5, 'Location', 'northeast');




