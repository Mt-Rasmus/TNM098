function [] = cc_plot(xDate, xPlace, xPrice, name, uniqueDates, uniquePlaces)

% This program plots purchase patterns for individuals.
% Plots the place, time of day and splits days into one graph per day in a
% single plot

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

% legs = 1:length(dateCells);
% legs = num2str(legs);
% legs = strsplit(legs,' ');

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

end
