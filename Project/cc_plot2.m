
function [] = cc_plot2(xDate, xPlace, xPrice, name, uniqueDates, uniquePlaces, AllPlaces, AllDates, maxPrice, ccbool)

% This program plots purchase patterns for individuals.
% Plots the place, time of day and splits days into one graph per day in a
% single plot. Can plot both cc and lc history.

dateCells = {};
priceCells = {};
PlaceCells = {};
pInd = {};


for i = 1:length(uniqueDates)
    
    dateCells{i} = xDate(day(xDate)==uniqueDates(i)); % saving all seperate dates in cell arrays
    
    % pInd{i} = datefind(dateCells{i}, xDate);
  
    if(i > 1)
        pInd{i} = (max(pInd{i-1})+1):((max(pInd{i-1})) + length(dateCells{i}));
        
    else
        pInd{i} = 1:size(dateCells{i});
    end
    
    priceCells{i} = xPrice(pInd{i},:);
    PlaceCells{i} = xPlace(pInd{i},:);
    
end

PlaceIndices = {};

% assign correct index to all places in PlaceCells!
for c = 1:length(dateCells)
    
     for k = 1:length(dateCells{c})
         
        Lia = ismember(AllPlaces,PlaceCells{c}(k));
        placeInd = find(Lia);
        PlaceIndices{c}(k) = placeInd;       
     end

end

pntColor = hsv(length(uniqueDates));
%figure(1)

sc = 1:length(dateCells);

for j = 1:length(dateCells)

    sizeArray = [];
    sizeArray = priceCells{j}./maxPrice.*300;
    x = ones(1,length(dateCells{j}))*j;
    y = PlaceIndices{j}; 

    sc(j) =  scatter(x, y, sizeArray, pntColor(j,:),'filled', 'Marker','o');
  %  line(x,y, 'Color', pntColor(j,:));

    hold on
    
    set(gca, 'XTick', 1:length(AllDates), 'XTickLabel', AllDates);
    set(gca, 'Ytick', 1:length(AllPlaces), 'YTickLabel', AllPlaces);
    
    axis([0  length(AllDates) 0  length(AllPlaces)])
    xlabel('Date')
    
end

if(ccbool)
   titleString = strcat('Credit card histroy of ', {' '}, name);
else
   titleString = strcat('Loyalty card histroy of ', {' '}, name); 
end

title(titleString);

% labs = {};

% for c = 1:length(uniqueDates)
%     labs{c} = strcat(num2str(uniqueDates(c)), '/1');
% end
% 
% legend(sc, labs, 'Location','northwest');

end
