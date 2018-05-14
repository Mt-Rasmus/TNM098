% This program picks filters loyalty card data by name

function [xDate, xPlace, xPrice, name] = ld_calc(M, nameID);

%% Extract samples based on car ID and day.

xDate = table2array(M(:,1));
xPlace = table2array(M(:,2));
xPrice = table2array(M(:,3));

Name = table2array(M(:,4:5));
fn = char(Name{1:size(Name),1});
ln = char(Name{1:size(Name),2});

names = cat(2, fn, ln);
names = cellstr(names); % All name instances concatinated to separate strings (full names)
namesArr = strings(size(names));

for i = 1:size(names)
    namesArr(i) = names{i,1};
end

uniqueNames = unique(names);

name = uniqueNames(nameID); % Pick one name (index between 1 and 53)
% disp(name);

%%

nameIdxArr = find((namesArr==name)); % Saves all indices of certain name
indices = 1:size(names); 
indices(nameIdxArr) = []; % Pick out all indices without that name

xDate(indices) = []; % delete these, saving only the elements with that name
xPlace(indices) = [];
xPrice(indices) = [];

uniquePlaces = unique(xPlace);
uniqueDates = unique(day(xDate));

% dateCells = {};
% 
% for i = 1:size(uniqueDates)
%     dateCells{i} = xDate(day(xDate)==uniqueDates(i)); % saving all seperate dates in cell arrays
% end


end





