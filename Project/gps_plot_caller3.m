

%%
% Plot

% Program to look at driving patterns of employees.
% Saves data on when and where the employees have stopped their vehicles. 
% Also plots driving patterns for one employee at a time.

% Read data
%GPS = readtable('gps.csv');
% % 
GPS = readtable('GPSreduced.csv');
L = readtable('locations-v2.2.csv');
CA = readtable('car-assignments.csv');
CC = readtable('cc_data.csv');

% Pick out all cc purchases:

%%

ID = 16; % Picking out a car ID.

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
%minRadius = 0.0005;
%minRadius = 0.001;
minRadius = 0.00075;

GGvalue = 0;
GGvalue2 = 0;
HITcount = 0;
HITcount2 = 0;
twoCount = 0;
stInd = 0;
enInd = 0;
rn = 1;
tester = {};
dateInds = {};
presentDates = [];
homeTohome = 0;
homeor = 0;
homeCount = 0;
homeDays1 = 0;
homeDays2 = 0;
homeDays3 = 0;
DistArrayOne = {};
allDistArrays = {};
var1 = 0;
HITcountROFL = 0;
HITcountlol = 0;
HITcountlol2 = 0;
HITcountlol3 = 0;
occCell = {};
lastones = 0;
lastones1 = 0;
lastones2 = 0;
lastones3 = 0;
oddRNs = 0;




%%
tic

E = wgs84Ellipsoid('meter');

thePlace = {};

 for i = 1:size(L) % Loops through all locations
%    i = 27;
     if i == 27
        homeor = 1; 
     else
        homeor = 0;    
     end
     
    currLoc = L(i,:);
  % theDate = {}; % 2
    dateInd = {};
    theDates = {};
    odd = 0;
    even = 0;    
    for d = 1:size(AllDates) % Loops through all dates
       
       
       theDate = {}; % 2 
       oneDate = ismember(day(GPS_p.Timestamp), AllDates(d));
       oneDate = GPS_p(oneDate,:); % Pick one date (6-19 jan)
       
       distArray = zeros(width(oneDate), 1);
       
     %  occCell = {}; % 3
    
       for j = 1:size(oneDate)    
                [arclen,~] = distance(oneDate(j,:).lat, oneDate(j,:).long, L(i,:).lat, L(i,:).long, E);
                distArray(j) = arclen < 75;            
%                 DistArrayOne{1} = distArray;
%                 allDistArrays{j} = DistArrayOne;
             % distArray(j) = (pdist2([oneDate(j,:).lat, oneDate(j,:).long], [L(i,:).lat, L(i,:).long]) < minRadius);    
       
       end
       
            N_runs = nnz(diff(distArray))+1; % count the number of times vehicle has entered vicinity of location  
        %    runarr = [ runarr, N_runs];
            numRunVals = diff(find([1,diff(distArray'),1])); % saves nr of values in each run.
            
                    if(distArray(1) == 1 && distArray(end) == 1)
                        DistArrayOne{1} = distArray;
                        allDistArrays{end+1} = DistArrayOne;
                        lastones = lastones + 1;
                        odd = 1;
                    end       
                    if(distArray(1) == 1 && distArray(end) == 0 || distArray(1) == 0 && distArray(end) == 1 )
                        DistArrayOne{1} = distArray;
                        allDistArrays{end+1} = DistArrayOne;
                        lastones = lastones + 1;
                        even = 1;
                        
                    end              
                    
            all = 0;
            
            if (N_runs == 2)
                twoCount = twoCount + 1;
            end
            
          %  test = numRunVals(rn) > 1;
            
            if(N_runs > 2)

                if(mod(N_runs,2))               
                   % oneRuns = ceil(N_runs - N_runs/2 - 1); % Odd nr of runs  
                    oneRuns = floor(N_runs/2 + 1); % Odd nr of runs   
                else
                    oneRuns = N_runs - N_runs/2; % Even nr of runs
                end 
                rn = 1;
                for r = 1:oneRuns % runs as many times as there are runs of 1 ("visits").
                    
           %         occCell = {};
                    times = {};
                    if (r ~= 1)
                         rn = rn + 2;
                    end
                    
                    if(mod(rn,2) == 1)
                        oddRNs = oddRNs + 1;
                    end
                    
                    if(rn == length(numRunVals))
                        lastones1 = lastones1 + 1;
                    end
%                 rn = rn + r;

                    if(distArray(1) == 0 && rn < length(numRunVals))
                        
                        var1 = var1 + 1;
                        stInd = all + numRunVals(rn)+1;
                        startTime = oneDate(stInd,:);

                        enInd = stInd + numRunVals(rn+1) - 1;     
                        endTime = oneDate(enInd,:);

                        all = enInd;

                      %  rn = r;
                      %  rn = rn + 2;
                        % disp(endTime.Timestamp.Minute - startTime.Timestamp.Minute);
                                    
                    if(distArray(end) == 1)
                        disp('1. rn = ')
                        disp(rn)
                        disp('2. length(numRunVals) = ')
                        disp(length(numRunVals))
                    end    
                        
                        if(even)
                            if(rn == length(numRunVals)-1 && distArray(end) == 1) % last run and its ones (home)      
                                        endTime.Timestamp.Hour = 23;  
                                        endTime.Timestamp.Minute = 59;
                                        endTime.Timestamp.Second = 59; 
                                        HITcountlol3 = HITcountlol3 + 1;                                   
                            end                            
                        else
                            if(rn == length(numRunVals) && distArray(end) == 1) % last run and its ones (home)      
                                        endTime.Timestamp.Hour = 23;  
                                        endTime.Timestamp.Minute = 59;
                                        endTime.Timestamp.Second = 59; 
                                        HITcountlol3 = HITcountlol3 + 1;                                   
                            end
                        end
                        
                        if(startTime.Timestamp.Hour < endTime.Timestamp.Hour) % Check if employee was there for a certain amout of time
                           times{1} = startTime;
                           times{2} = endTime;
                           occCell = [occCell, times];
                           occCell{end+1} = startTime;
                           occCell{end+1} = endTime;
                            HITcount = HITcount + 1;                                   
                        end

                        if(startTime.Timestamp.Hour == endTime.Timestamp.Hour && ...
                                abs(endTime.Timestamp.Minute - startTime.Timestamp.Minute) > 6) % Check if employee was there for a certain amout of time

                           times{1} = startTime;
                           times{2} = endTime;
                           occCell = [occCell, times];
                            occCell{end+1} = startTime;
                            occCell{end+1} = endTime;
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
                        
                    if(distArray(end) == 1)
                        lastones2 = lastones2 + 1;
                    end    
                                            
                %       disp(rn)
               %        stInd = all + 1;
                       
                       if(homeor == 1)
                            homeTohome = homeTohome + 1;
                       end      
                       
                       if(r == 1) % first run of ones (starts at distArray(1))
                           
                           if (numRunVals(rn) > 1)
                               
                               HITcountROFL = HITcountROFL + 1;
                               % stInd = 1;
                               homeDays1 = homeDays1 + 1;
                               startTime = oneDate(1,:); % arbitrary index

                               startTime.Timestamp.Hour = 00;  
                               startTime.Timestamp.Minute = 00;
                               startTime.Timestamp.Second = 01;

                  %           stInd = all + 1;
                                %disp( numRunVals(rn))
                                
                              %  enInd = numRunVals(1); 
                               enInd = numRunVals(rn); 
                               endTime = oneDate(enInd,:);
                               all = numRunVals(1);
                                
                           else
                               HITcountlol = HITcountlol + 1;
                               startTime = oneDate(1,:); % arbitrary index                               
                               startTime.Timestamp.Hour = 00;  
                               startTime.Timestamp.Minute = 00;
                               startTime.Timestamp.Second = 01;
                            %   endTime = oneDate(2,:);
                               enInd = 1;
                               endTime = oneDate(1,:);
                               all = 1;
                               
                           end 
                           
                            if(even)
                                if(rn == length(numRunVals)-1 && distArray(end) == 1) % last run and its ones (home)      
                                            endTime.Timestamp.Hour = 23;  
                                            endTime.Timestamp.Minute = 59;
                                            endTime.Timestamp.Second = 59; 
                                            HITcountlol3 = HITcountlol3 + 1;                                   
                                end                            
                            else
                                if(rn == length(numRunVals) && distArray(end) == 1) % last run and its ones (home)      
                                            endTime.Timestamp.Hour = 23;  
                                            endTime.Timestamp.Minute = 59;
                                            endTime.Timestamp.Second = 59; 
                                            HITcountlol3 = HITcountlol3 + 1;                                   
                                end
                            end  
                              
                       else % not first run
                           
                         if(distArray(end) == 1)
                            lastones3 = lastones3 + 1;
                         end                              
                                HITcountlol2 = HITcountlol2 + 1;
                                stInd = all + numRunVals(rn-1) + 1;

                  %           stInd = all + 1;

                                startTime = oneDate(stInd,:);

                                if (numRunVals(rn) > 1)
                                    enInd = stInd + numRunVals(rn) - 1;     
                                else
                                    if(rn == length(numRunVals)) % last run and its ones 
                                      enInd = stInd;
                                    else
                                      enInd = stInd + 1;
                                    end
                                end

                                endTime = oneDate(enInd,:);

                                all = enInd;     
                                
                                if(even)
                                    if(rn == length(numRunVals)-1 && distArray(end) == 1) % last run and its ones (home)      
                                                endTime.Timestamp.Hour = 23;  
                                                endTime.Timestamp.Minute = 59;
                                                endTime.Timestamp.Second = 59; 
                                                HITcountlol3 = HITcountlol3 + 1;                                   
                                    end                            
                                else
                                    if(rn == length(numRunVals) && distArray(end) == 1) % last run and its ones (home)      
                                                endTime.Timestamp.Hour = 23;  
                                                endTime.Timestamp.Minute = 59;
                                                endTime.Timestamp.Second = 59; 
                                                HITcountlol3 = HITcountlol3 + 1;                                   
                                    end
                                end  
                            
                       end

%                    stInd = all + 1;
%                    startTime = oneDate(stInd,:);
%                             
%                    enInd = stInd + numRunVals(rn) - 1; 
%                    endTime = oneDate(enInd,:);

                 %      all = enInd + numRunVals(rn);
                          

                   %    rn = r; 
                    %    rn = rn + 2;     
                        if(startTime.Timestamp.Hour < endTime.Timestamp.Hour) % Check if employee was there for a certain amout of time
                            times{1} = startTime;
                            times{2} = endTime;
                            occCell = [occCell, times];
                            occCell{end+1} = startTime;
                            occCell{end+1} = endTime;
                            HITcount2 = HITcount2 + 1;                                   
                        end

                        if(startTime.Timestamp.Hour == endTime.Timestamp.Hour && ...
                                abs(endTime.Timestamp.Minute - startTime.Timestamp.Minute) > 6) % Check if employee was there for a certain amout of time
                            times{1} = startTime;
                            times{2} = endTime;
                            occCell = [occCell, times];
                            occCell{end+1} = startTime;
                            occCell{end+1} = endTime;
                            HITcount2 = HITcount2 + 1;  
                        end     
                             
                    end
                        
%                    rn = rn + 2;     
                    
                end
                    
                %  theDate{r} = occCell;
                
                   if(~isempty(occCell))
%                         theDate{1,end+1} = occCell;
%                         theDate{2,end} = r;
                        theDate{end+1} = occCell;
                   end 
                   
                   occCell = {};
                   
                end
                
            stInd = 0;
            enInd = 0;
    %       rn = 1;
            all = 0;
            
            if(~isempty(theDate))
            	%theDates = [theDates, theDate];
                theDates{1,end+1} = theDate;
                theDates{2,end} = d+5;
                presentDates(end+1) = d+5;
            end
      %     theDates{d} = theDate;
            
    end
            if(~isempty(theDates))
              %  thePlace = [thePlace, theDates];
              thePlace{1,end+1} = theDates;
              thePlace{2,end} = i;
            end
      %      thePlace{i} = theDates;
 end

 toc
 
%%
% Plot travel patterns of employees

tic

uniqueDs = unique(presentDates);

pntColor = hsv(length(uniqueDs));

figure(1)

sc = zeros(1,length(uniqueDs));


for d = 1:length(uniqueDs) % as many times as visitation dates (at most 6/1 - 19/1)
    
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
                                          
                                            x = [x, beginTime];
                                            x = [x, endTime];

                                            y = [y, cell2mat(thePlace(2,p))];
                                            y = [y, cell2mat(thePlace(2,p))]; 

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
    
    sc(d) =  scatter(x2, y2, 250, pntColor(d,:), 'Marker','o', 'LineWidth', 1);
    line(x2,y2, 'Color', pntColor(d,:), 'LineWidth', 2);
    
    %     x2 = [];
    %     y2 = [];
    
    hold on

%     set(gca, 'XTick', [0:2:24], 'XTickLabel', rem([0:2:24],24));
%     set(gca, 'Ytick', 1:length(L.location), 'YTickLabel',L.location);
% 
%     axis([1  24    0  length(L.location)])
    
    set(gca, 'XTick', [0:1:24], 'XTickLabel', rem([0:1:24],24));
    set(gca, 'Ytick', 1:length(L.location), 'YTickLabel',L.location);

    axis([0  24    0  length(L.location)])    
    
    
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
