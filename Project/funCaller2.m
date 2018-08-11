
% Read data

ccd = readtable('cc_data.csv');
lcd = readtable('loyalty_data.csv');

%%

sumArr = zeros(54,1);
lengthArr = zeros(54,1);

ccPriceAll = {};
lcPriceAll = {};
ccNamesAll = strings(54,1);
lcNamesAll = strings(54,1);

%%

 for id = 1:54 % looping through all the names
    
    nameID = id;
    
    [ccDate, ccPlace, ccPrice, ccName] = cc_calc(ccd, nameID);

    [lcDate, lcPlace, lcPrice, lcName] = ld_calc(lcd, nameID);
    
    ccPriceAll{id} = ccPrice;
    ccDateAll{id} = ccDate;
    ccPlaceAll{id} = ccPlace;
    
    lcPriceAll{id} = lcPrice;
    lcDateAll{id} = lcDate;
    lcPlaceAll{id} = lcPlace;
    
    ccNamesAll(id) = ccName{1};
    lcNamesAll(id) = lcName{1};
    
 end
 
%%
 
% Has anyone employee paid with his/her cc and used someone elses lc?
% 1. Check if any prices matches in cc match lc buys (for different employees).
% 2. Check if the dates and places match for these instances.
% Goal: print which names matched, the time and location.
% Most interesting index: 18 (15 out of 22 full matches).
% 18 is Elsa Orilla, matches 15 times with Kanon Herrero (nr 32)
% There are a total of 21 matches including all people compares to
% eachother

Lia = {};
matchCount = 1:54;
ind = 18; % choose index to check matches for (1-54)
disp(lcNamesAll(ind));

for j = 1:54
    
    Lia{j} = ismember(lcPriceAll{ind},ccPriceAll{j}); % Which lc purchases (indices) in charCells{ind} matched with the other cc purchases?
    matchCount(j) = sum(Lia{j}); % How many lc purchases matched in each of the 54 files of each persons cc purchases?
                                                            
end

matchCount(ind) = 0; % remove match with itself
totMatches = sum(matchCount);
disp(totMatches);
tm = 0;

matchIdx = find(matchCount); % Saving all indices of people ind matched with
matchesWithPeople = zeros(length(matchIdx), 1);
compCell = lcPriceAll{ind};
compDate = lcDateAll{ind};
compPlace = lcPlaceAll{ind};
commonPlaces = {};
commonTimes(25) = datetime;
lengths = 1:length(matchIdx);
% matchIdx = find(matchCount);
hej = 0;

for k = 1:length(matchIdx) % runs as many times as there are matching people
    
    currPriceCell = ccPriceAll{matchIdx(k)};
    currDateCell = ccDateAll{matchIdx(k)};
    currPlaceCell = ccPlaceAll{matchIdx(k)};
    
    lengths(k) = length(currPriceCell);
    
    priceMatchIdx = find(Lia{matchIdx(k)}); % pick out index/indices of purchases in compCell that matched with curr person.
    
    for l = 1:length(priceMatchIdx) % runs as many times as there are matches with one person

        currPrice = compCell(priceMatchIdx(l)); % pick out the particular price
        
        for m = 1:length(currPriceCell) % runs through one persons entire cc record

              if(currPrice == currPriceCell(m) && ...
                     strcmp(compPlace(priceMatchIdx(l)),currPlaceCell(m)) && ...
                     day(compDate(priceMatchIdx(l))) == day(currDateCell(m)))
                 if k==4
                     hej = hej + 1;
                 end
                if (k==2) 
                     tm = tm + 1;
                     matchesWithPeople(k) = matchesWithPeople(k) + 1;
                     commonPlaces(1, l) = currPlaceCell(m);
                     commonPlaces{2, l} = currDateCell(m);
                     commonTimes(l) = currDateCell(m);
                end
              end
        
        end
        
    end
        
end

disp(tm);
