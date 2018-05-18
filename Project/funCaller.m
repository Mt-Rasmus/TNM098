
% Read data

ccd = readtable('cc_data.csv');
lcd = readtable('loyalty_data.csv');

AllPlacesCC = unique(ccd.location);
AllDatesCC = unique(day(ccd.timestamp));
AllNamesCC = unique(ccd(:,4:5));

AllPlacesLC = unique(lcd.location);
AllDatesLC = unique(day(lcd.timestamp));
AllNamesLC = unique(lcd(:,4:5));

%%

sumArr = zeros(54,1);
lengthArr = zeros(54,1);

% for id = 1:54 % looping through all the names
    
    id = 32;
    nameID = id;

    [ccDate, ccPlace, ccPrice, ccName] = cc_calc(ccd, nameID);

    [lcDate, lcPlace, lcPrice, lcName] = ld_calc(lcd, nameID);

    uniquePlacesCC = unique(ccPlace);
    uniqueDatesCC = unique(day(ccDate));
    uniquePricesCC = unique(ccPrice);
    maxPriceCC = max(uniquePricesCC);

    uniquePlacesLC = unique(lcPlace);
    uniqueDatesLC = unique(day(lcDate));
    uniquePricesLC = unique(lcPrice);
    maxPriceLC = max(uniquePricesLC);

    res = zeros(length(lcPrice), 1);
    lengthArr(id) = length(lcPrice);
    
    for i = 1:length(lcPrice)
        %ey = ey + 1;
        
        if(ismember(lcPrice(i),ccPrice))
            res(i) = 0;
        else
            res(i) = 1;
        end
    end
    
    sumArr(id) = sum(res);

 % end

figure(1)
ccbool = true;
cc_plot2(ccDate, ccPlace, ccPrice, ccName, uniqueDatesCC, uniquePlacesCC, AllPlacesCC, AllDatesCC, maxPriceCC, ccbool);
figure(2)
ccbool = false;
cc_plot2(lcDate, lcPlace, lcPrice, lcName, uniqueDatesLC, uniquePlacesLC, AllPlacesLC, AllDatesLC, maxPriceLC, ccbool);

%disp(sum(sumArr));

% 320 instances of loyalty card use without cc use. Might be cash payment.
% Analysis:
% 1. Has someone used another employee's loyalty card?
% 2. Has someone used another employee's credit card?
% 3. Is there a pattern in people only using cc card / ld card ?
% 4. Is there a correlation between these discoveries and rare cc card / ld
% card usages?




