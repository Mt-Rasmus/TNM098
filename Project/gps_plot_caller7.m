
% Program to look at driving patterns of employees.
% Saves data on when and where the employees have stopped their vehicles. 
% Also plots driving patterns for one employee at a time.

% Strucure of the program:
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

% Read data
%GPS = readtable('gps.csv');

GPS = readtable('GPSreduced.csv');
L = readtable('locations-v2.3.csv');
locIDs = readtable('LocationIDs.csv');
CA = readtable('car-assignments.csv');
CC = readtable('cc_data.csv');
ID = 16; % Picking out a car ID.

GPS_p = ismember(GPS.id, ID);
GPS_p = GPS(GPS_p,:); % All GPS data in person with certain ID.

AllDates = unique(day(GPS_p.Timestamp)); % All integer dates on which there is GPS data on this person

E = wgs84Ellipsoid('meter');

HITcount = 0;
presentDates = [];

theDates = {};
thePlace = {};
theDate = {};
occCell = {};
%%
tic


for i = 1:size(L) % Loops through all locations
%for i = 27:27 % Loops through all locations
    
    for d = 1:size(AllDates) % Loops through all dates
 %   for d = 12:22 % Loops through all dates

  %     theDate = {};
       oneDate = ismember(day(GPS_p.Timestamp), AllDates(d));
       oneDate = GPS_p(oneDate,:); % Pick one date (6-19 jan)
       [dateC, dateR] = size(oneDate);
       
       distArray = zeros(width(oneDate), 1);
       oneIndices = [];
       startInd = 0;
       stopInd = 0;
       startTimeFound = 0;
       endTimeFound = 0;
       
        for j = 1:size(oneDate)   
            
            times = {};   
            
            [arclen,~] = distance(oneDate(j,:).lat, oneDate(j,:).long, L(i,:).lat, L(i,:).long, E);
            distArray(j) = arclen < 75;
          
            if (distArray(j) == 1)
                
                if(startTimeFound == 0) % if a startTime has yet to be found, check if the current 1 is a startTime.
                 %   startTime = {};
                    if(j == 1)
                        startTime = oneDate(1,:);                          
                        startTime.Timestamp.Hour = 00;  
                        startTime.Timestamp.Minute = 00;
                        startTime.Timestamp.Second = 01;
                        startTimeFound = 1;
                    else
                        if(distArray(j-1) == 0)
                          startTime = oneDate(j,:);    
                          startTimeFound = 1;
                        end
                    end
                    
                end
                
                if(startTimeFound == 1 && endTimeFound == 0) % if a startTime has been found, check for a valid endTime!

                    if( j+1 <= dateC)

                        [arclenExtra,~] = distance(oneDate(j+1,:).lat, oneDate(j+1,:).long, L(i,:).lat, L(i,:).long, E);

                        nextCheck = arclenExtra < 75; % check whether the next sample is zero (end of a run)

                        if(nextCheck == 0) % marks the end of a run! Find correct endTime!

                            if(j==1) % if we start with a one
                               endTime = oneDate(1,:);
                               endTimeFound = 1;
                            else
                                
                                % if we are in the middle of the sequence 
                                if(distArray(j-1) == 0) % just one 1 in the run
                                    endTime = oneDate(j+1,:);
                                    endTimeFound = 1;
                                else % more than one 1 in the run
                                    endTime = oneDate(j,:);  
                                    endTimeFound = 1;
                                end
                                
                            end
                            
                        end
                        
                    else
                        if(j == dateC) % if we are at the end
                            endTime = oneDate(j,:);  
                            endTime.Timestamp.Hour = 23;  
                            endTime.Timestamp.Minute = 59;
                            endTime.Timestamp.Second = 59;  
                            endTimeFound = 1;
                        end                           
                    end
                
                    % NOW SAVE THE TIMES:
                    if(startTimeFound == 1 && endTimeFound == 1)
                        
                        startTimeFound = 0;
                        endTimeFound = 0;

                        if(startTime.Timestamp.Hour < endTime.Timestamp.Hour) % Check if employee was there for a certain amout of time
                            times{1} = startTime;
                            times{2} = endTime;
                            occCell = [occCell, times];
                  %          occCell{end+1} = startTime;
                    %        occCell{end+1} = endTime;
                            HITcount = HITcount + 1;                                   
                        end

                        if(startTime.Timestamp.Hour == endTime.Timestamp.Hour && ...
                        abs(endTime.Timestamp.Minute - startTime.Timestamp.Minute) > 6) % Check if employee was there for a certain amout of time

                            times{1} = startTime;
                            times{2} = endTime;
                            occCell = [occCell, times];
                    %        occCell{end+1} = startTime;
                      %      occCell{end+1} = endTime;
                            HITcount = HITcount + 1;                       
                        end
                        startTime = {};
                        endTime = {};
                    end
                    
                end

            end

        end 
        
        if(~isempty(occCell))
            %                         theDate{1,end+1} = occCell;
            %                         theDate{2,end} = r;
            theDate{end+1} = occCell;
        end  
        
        occCell = {};      
        
         if(~isempty(theDate))
            %theDates = [theDates, theDate];
            theDates{1,end+1} = theDate;
            theDates{2,end} = d+5;
            presentDates(end+1) = d+5;
         end        
         
         theDate = {};
         
        if(~isempty(theDates))
          %  thePlace = [thePlace, theDates];
          thePlace{1,end+1} = theDates;
          thePlace{2,end} = i;
        end
        
        theDates = {};
        
    end
    
end

toc

%%
% Plot travel patterns of employees

tic

uniqueDs = unique(presentDates);

pntColor = hsv(length(uniqueDs));

figure(1)

sc = zeros(1,length(uniqueDs));

%beginTime = {};
%endTime = {};

%for d = 1:length(uniqueDs) % as many times as visitation dates (at most 6/1 - 19/1)
for d = 1:length(uniqueDs)    
    currDate = uniqueDs(d);
    
    x = [];
    y = [];

%    for p = 1:length(thePlace) % Loops through all locations in thePlace (from 1-28)
    for p = 1:length(thePlace) % Loops through all locations in thePlace (from 1-28)
                  
            [row,col] = size(thePlace{1,p});
            
            ifdate = cell2mat(thePlace{1,p}(2,1:col));

            Lia = find(ifdate==currDate); % contains indices of matching dates

            if(~isempty(Lia)) % looking for dates in order. Only pick places with the current date.
        
                 for d2 = 1:length(Lia)

                        for o = 1:length(thePlace{1,p}{1,Lia(d2)}) % Loops through all occurences

                                    beginTime = thePlace{1,p}{1,Lia(d2)}{1,o}{1,1}.Timestamp;
                                    beginTime = hour(beginTime) + minute(beginTime)/60;

                                    endTime = thePlace{1,p}{1,Lia(d2)}{1,o}{1,2}.Timestamp;
                                 	endTime = hour(endTime) + minute(endTime)/60;
                       %             endTime = endTime.Hour + endTime.Minute/60;
                                          
                                            x = [x, beginTime];
                                            x = [x, endTime];
                                            
                                            placeClass = L(cell2mat(thePlace(2,p)),4);
                                            placeClass2 = placeClass{1,1};
                                     %       y = [y, cell2mat(thePlace(2,p))];
                                     %       y = [y, cell2mat(thePlace(2,p))];
                                            y = [y, placeClass2];
                                            y = [y, placeClass2];                                           

                        end
                        
                end
            
            end
            
    end
    
    % sort x:
    [xs, xsInd] = sort(x(1:2:end));  
    [xe, xeInd] = sort(x(2:2:end)); 
    [ys, ysInd] = sort(y(1:2:end));  
    [ye, yeInd] = sort(y(2:2:end)); 
    
    x2 = [];
    y2 = [];
    
    for u = 1:length(xs)

        x2 =  [x2, xs( u )];
        x2  = [x2, xe( u )];
        y2 = [y2, ys( xsInd( u ))];
        y2 = [y2, ys( xsInd( u ) )];
        
    end
    
    sc(d) =  scatter(x2, y2, 250, pntColor(d,:), 'Marker','o', 'LineWidth', 2);
    line(x2,y2, 'Color', pntColor(d,:), 'LineWidth', 2);
    
    %     x2 = [];
    %     y2 = [];
    
    hold on

%     set(gca, 'XTick', [0:2:24], 'XTickLabel', rem([0:2:24],24));
%     set(gca, 'Ytick', 1:length(L.location), 'YTickLabel',L.location);
% 
%     axis([1  24    0  length(L.location)])
    
yLength = 5;

%     set(gca, 'XTick', [0:1:24], 'XTickLabel', rem([0:1:24],24));
%     set(gca, 'Ytick', 1:length(L.location), 'YTickLabel',L.location);
    

    set(gca, 'XTick', [0:1:24], 'XTickLabel', rem([0:1:24],24));
    set(gca, 'Ytick', 1:yLength, 'YTickLabel', locIDs.LocationKey2);

    axis([0  24    0  yLength])    
    
    
    xlabel('Time (Hr)')
    
    

end

lname = CA(ID,1);
lname = lname.LastName;

fname = CA(ID,2);
fname = fname.FirstName;

fullname = strcat(fname, {' '}, lname);

titleString = strcat('Travel patterns of ', {' '}, fullname);

title(titleString);

labs = {};

for c = 1:length(uniqueDs)
    labs{c} = strcat(num2str(uniqueDs(c)), '/1');
end

legend(sc, labs, 'Location','northwest');

toc
























