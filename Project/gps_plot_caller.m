

%%
% Plot

% Program to look at driving patterns of employees.
% Saves data on when and where the employees have stopped their vehicles. 
% Calls a plot function which plots driving patterns for one employee at a time.

% Read data
%GPS = readtable('gps.csv');
GPS = readtable('GPSreduced.csv');
L = readtable('locations-v2.csv');
CA = readtable('car-assignments.csv');
CC = readtable('cc_data.csv');

% Pick out all cc purchases:

%%

ID = 1; % Picking out a car ID.

name = CA(ID,:);

nameMatches = ismember(CC(:,4:5), name(:,1:2));

Purchases = CC(nameMatches, :);

%%

% 1. Pick a person, and extract all that persons GPS data
% 2. Loop:
% 2.1. Pick a location.
% 2.1. Pick a date.
% 2.2. See if the employee has entered the radius of
% that place on that date. If he/she has, check how long the visit was. If
% it was too short, look for another time. If none is found, go to the next
% date. If a longer duration visit is found, save the start time and end
% time (When a radius was first entered and last left).

% Data stucture:
% two (or four or six etc..) times are saved
% saved for specific day and place.
% Person - place - day - occurrences - start+end time

GPS_p = ismember(GPS.id, ID);
GPS_p = GPS(GPS_p,:);

AllDates = unique(day(GPS_p.Timestamp));
minRadius = 0.001;

GGvalue = 0;
GGvalue2 = 0;
HITcount = 0;
HITcount2 = 0;
twoCount = 0;
stInd = 0;
enInd = 0;
rn = 0;
tester = {};
dateInds = {};

tic

thePlace = {};

 for i = 1:size(L) % Loops through all locations
     
    currLoc = L(i,:);
  % theDate = {}; % 2
    dateInd = {};
    theDates = {};
    
    for d = 1:size(AllDates) % Loops through all dates
        
       theDate = {}; % 2 
       oneDate = ismember(day(GPS_p.Timestamp), AllDates(d));
       oneDate = GPS_p(oneDate,:); % Pick one date (6-19 jan)
       
       distArray = zeros(width(oneDate), 1);
       
     %  occCell = {}; % 3
    
       for j = 1:size(oneDate)    
              distArray(j) = (pdist2([oneDate(j,:).lat, oneDate(j,:).long], [L(i,:).lat, L(i,:).long]) < minRadius);    
       end
       
            N_runs = nnz(diff(distArray))+1; % count the number of times vehicle has entered vicinity of location  
            numRunVals = diff(find([1,diff(distArray'),1])); % saves nr of values in each run.
            
            all = 0;
            
            if (N_runs == 2)
                twoCount = twoCount + 1;
            end
            
            if(N_runs > 2)
                
                if(mod(N_runs,2))               
                    oneRuns = ceil(N_runs - N_runs/2 - 1); % Odd nr of runs                
                else
                    oneRuns = N_runs - N_runs/2; % Even nr of runs
                end 
                
                for r = 1:oneRuns % runs as many times as there are runs of 1 ("visits").
                    
                    occCell = {};
                    times = {};
                    rn = rn + r;
                    
                    %OBS: case not covered: 111100001111 (more one runs that zeros)
                    % 111 0000 111
                    
                    if(distArray(1) == 0 && rn < length(numRunVals))

                        stInd = all + numRunVals(rn)+1;
                        startTime = oneDate(stInd,:);

                        enInd = stInd + numRunVals(rn+1) - 1;     
                        endTime = oneDate(enInd,:);

                        all = enInd;

                        rn = r;

                        if(startTime.Timestamp.Hour < endTime.Timestamp.Hour) % Check if employee was there for a certain amout of time
                            times{1} = startTime;
                            times{2} = endTime;
                            occCell = [occCell, times];
                            HITcount = HITcount + 1;                                   
                        end

                        if(startTime.Timestamp.Hour == endTime.Timestamp.Hour && ...
                                abs(endTime.Timestamp.Minute - startTime.Timestamp.Minute) > 10) % Check if employee was there for a certain amout of time

                            times{1} = startTime;
                            times{2} = endTime;
                            occCell = [occCell, times];
                            HITcount = HITcount + 1;                       
                        end

                    else
                        asd = {};
                        asds = {};
                        asd{1} = distArray(1);
                        asd{2} = distArray(length(distArray));
                        asd{3} = N_runs;
                        asds = [asds, asd];
                        tester = [tester, asds];
                        GGvalue = GGvalue + 1;
                    end
                    if(distArray(1) == 1 && rn < length(numRunVals))
                       
                        stInd = all + 1;
                        startTime = oneDate(stInd,:);
                      
                        enInd = stInd + numRunVals(rn) - 1; 
                        endTime = oneDate(enInd,:);

                        all = enInd + numRunVals(rn+1);

                        rn = r;
                        
                        HITcount2 = HITcount2 + 1;   

                    end
                    
                  theDate{r} = occCell;
                    
                end
                
            end
            
            stInd = 0;
            enInd = 0;
            rn = 0;
            all = 0;
        
         %   theDates = [theDates, theDate];
            theDates{d} = theDate;
            
    end
        thePlace{i} = theDates;
 end

 toc

%%
% Plot

tic

pntColor = hsv(length(AllDates));

figure(1)

sc = 1:length(AllDates);

%for d = 12:12 % 14 times (6/1 - 19/1)
for d = 1:length(AllDates) % 14 times (6/1 - 19/1)
    
    currDate = AllDates(d);
    x = [];
    y = [];

    for p = 1:height(L) % Loops through all locations in thePlace (28 times)
        
             for d2 = 1:length(AllDates) % 14 times (6/1 - 19/1)
           %  for d2 = 12:12 % 14 times (6/1 - 19/1)  
                 
                if(~isempty(thePlace{p}{1,1}))
                    
                    for o = 1:length(thePlace{p}{1,d2}) % Loops through all occurences
                        
                        if(~isempty(thePlace{p}{1,d2}{1,o}))
                            
                            currSamp = thePlace{p}{1,d2}{1,o}{1,1};

                            if(currSamp.Timestamp.Day == currDate)

                                beginTime = thePlace{p}{1,d2}{1,o}{1,1}.Timestamp;
                                beginTime = hour(beginTime) + minute(beginTime)/60;
    
                                endTime = thePlace{p}{1,d2}{1,o}{1,2}.Timestamp;
                                endTime = hour(endTime) + minute(endTime)/60;
    
                                x = [x, beginTime];
                                x = [x, endTime];
    
                                y = [y, p];
                                y = [y, p]; 

                            end
                         
                        end

                    end
                    
                end
                
                sc(d) =  scatter(x, y, 15, pntColor(d,:),'Marker','o');
                line(x,y, 'Color', pntColor(d,:));

                hold on

                set(gca, 'XTick', [0:2:24], 'XTickLabel', rem([0:2:24],24));
                set(gca, 'Ytick', 1:length(L.location), 'YTickLabel',L.location);

                axis([1  24    0  length(L.location)])
                xlabel('Time (Hr)')

            end
            
    end
    

end

name = 'some dude';

titleString = strcat('Credit card histroy of ', {' '}, name);

title(titleString);

labs = {};

for c = 1:length(AllDates)
    labs{c} = strcat(num2str(AllDates(c)), '/1');
end

legend(sc, labs, 'Location','northwest');

toc

%%
