function [] = cluster_plot(clusters, uniqueNames)

% The plot answers:
% where was carID nr X at the time of these peoples transactions

S = shaperead('Abila.shp');

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
totNrSamps = 0;

hold on

for C = 1:nrClusters
    
    x = 1:size(clusters{C});
    y = 1:size(clusters{C});
    
    for C2 = 1:size(clusters{C})
    
        xSamp = clusters{C}(C2,4);
        xSamp = xSamp.long;
        x(C2) = xSamp;
        totNrSamps = totNrSamps + 1;
        
        ySamp = clusters{C}(C2,3);
        ySamp = ySamp.lat;
        y(C2) = ySamp;
    
    end
    
    scatter(x, y, 100, pntColor(C,:), 'Marker','o');
    
    x = [];
    y = [];
    
end

disp(totNrSamps);

legend(uniqueNames, 'FontSize', 10, 'Location', 'northeast');

end
