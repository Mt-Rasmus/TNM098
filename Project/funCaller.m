
% Read data

ccd = readtable('cc_data.csv');
lcd = readtable('loyalty_data.csv');

%%

sumArr = zeros(54,1);
lengthArr = zeros(54,1);
 for id = 1:54 % looping through all the names
    
    nameID = id;
    
    [ccDate, ccPlace, ccPrice, ccName] = cc_calc(ccd, nameID);

    [lcDate, lcPlace, lcPrice, lcName] = ld_calc(lcd, nameID);

    uniquePlacesCC = unique(ccPlace);
    uniqueDatesCC = unique(day(ccDate));
    uniquePricesCC = unique(ccPrice);

    uniquePlacesLC = unique(lcPlace);
    uniqueDatesLC = unique(day(lcDate));
    uniquePricesLC = unique(lcPrice);

    res = zeros(length(lcPrice), 1);
    lengthArr(id) = length(lcPrice);
    for i = 1:length(lcPrice)
        ey = ey + 1;
        if(ismember(lcPrice(i),ccPrice))
            res(i) = 0;
        else
            res(i) = 1;
        end
    end
    
    sumArr(id) = sum(res);

 end

cc_plot(ccDate, ccPlace, ccPrice, ccName, uniqueDatesCC, uniquePlacesCC);
disp(sum(sumArr));

% 320 instances of loyalty card use without cc use. Might be cash payment.
% Analysis:
% 1. Has someone used another employee's loyalty card?
% 2. Has someone used another employee's credit card?
% 3. Is there a pattern in people only using cc card / ld card ?
% 4. Is there a correlation between these discoveries and rare cc card / ld
% card usages?
% 5. Note: some payments are about zero (always for the same people, such as Adan Morlun). Why?



