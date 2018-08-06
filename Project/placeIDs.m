
%function A = placeIDs(placeArr)

ccdata = readtable('cc_data.csv');

placeList = table2array(ccdata(:,2));
placeList2 = unique(placeList);

%end
