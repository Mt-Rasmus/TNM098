
% Aim: plot cc combined cc history for each date and place.

cc_data = readtable('cc_data.csv');

%% Finding the coordinates for the diffeent locations in cc_data

locations = unique(cc_data.location);
l = size(locations);
loc_trans = {};

% Saving one cell per location
for i = 1:l % loops through each cell in loc_trans, representing visited places.
    t = ismember(cc_data.location, locations{i});
    loc_trans{i} = cc_data(t,:);  
end

% Go through each cell in loc_trans and add split the cell into
% as many parts as there are different dates and add the price in those
% dates.

bool1 = true;
totPrice = 0;
cashDayPairCell = {};
bigCell = {};

for j = 1:length(loc_trans) % run for each location
    
    ind = 1;
    % save unique days:
    uniqueDays = unique(day(loc_trans{j}.timestamp));
    
    for k = 1:length(uniqueDays) % run for each unique day at the location
        
        bool1 = true;
        currDay = uniqueDays(k);
        dayIDX = [];
        
        theSize = size(loc_trans{j});
        
        while (bool1 == true && ind < theSize(1)) % run as many times as there are purchases at one place
        
            oneDay = loc_trans{j}(ind,1);
            oneDay = day(oneDay.timestamp);
            
            if(currDay == oneDay)
               ind = ind + 1;
               currprice = loc_trans{j}(ind,3);
               currprice = currprice.price;
               totPrice = totPrice + currprice;
            else
                bool1 = false; % end while, next day
            end    
              
        end
             cashDayPair = [];
             cashDayPair(1) = totPrice;
             cashDayPair(2) = currDay;
             cashDayPairCell = [cashDayPairCell, cashDayPair];
    end
             bigCell{j} = cashDayPairCell;
             cashDayPairCell = {};
end


%% plot

dateCells = {};
pInd = {};

% for i = 1:size(uniqueDatesCC)
%     dateCells{i} = ccDate(day(ccDate)==uniqueDatesCC(i)); % saving all seperate dates in cell arrays
% end

for i = 1:size(uniqueDates)
    
    dateCells{i} = xDate(day(xDate)==uniqueDates(i)); % saving all seperate dates in cell arrays
    
    pInd{i} = datefind(dateCells{i}, xDate);

end

pntColor = hsv(length(uniqueDates));
figure(1)

sc = 1:length(dateCells);

for j = 1:length(dateCells)

    aDay = dateCells{j};
    times = zeros(length(aDay),1);

    for d = 1:length(aDay)
        times(d) = hour(aDay(d)) + minute(aDay(d))/60;
    end

    x = times;
    y = 1:length(aDay); 
    yString = xPlace(pInd{j}); % now translate the names into numbers using a new function
 
    for d1 = 1:length(yString) 
        
        place = yString(d1);  
        
        for d2 = 1:length(uniquePlaces)   
            
            if(strcmp(place, uniquePlaces(d2)))
                y(d1) = d2;
            end
        end
    end
    
    sc(j) =  scatter(x, y, 15, pntColor(j,:),'Marker','o');
    line(x,y, 'Color', pntColor(j,:));
    
    hold on
    
    set(gca, 'XTick', [0:2:24], 'XTickLabel', rem([0:2:24],24));
    set(gca, 'Ytick', 1:length(uniquePlaces), 'YTickLabel',uniquePlaces);
    
    axis([1  24    0  length(uniqueDates)])
    xlabel('Time (Hr)')

end

labs = {};

for c = 1:length(uniqueDates)
    labs{c} = strcat(num2str(uniqueDates(c)), '/1');
end

legend(sc, labs, 'Location','northwest');



