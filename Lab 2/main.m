
M = readtable('data2.csv');
x = table2array(M(:,5:6));

[IDX, isnoise] = DBSCAN(x,20.5,5); % takes about 10 seconds

% [ clusters ] = dbscan( M, Eps, minPts)

max1 = max(IDX(:,1));

x = x((IDX~=0),:);

IDX = IDX((IDX~=0),:);

MT = M((IDX~=0),:);
MT = table2array(MT);
MT2 = table2array(M);
% gscatter(x(:,1),x(:,2),IDX);
% xlim([0,1500]);
% ylim([0,1500]);

class = 1:max1;
pntColor = hsv(length(class));

figure,hold on

h = animatedline;


 %Plot ALL points
% for idx = 1:size(MT2)
%     pointsize = MT2(idx,3)/3;
%     %clusterNr = IDX(idx);
%     %addpoints(h,MT2(idx,5),MT2(idx,6));
%     
%      scatter(MT2(idx,5), MT2(idx,6), pointsize, pntColor(clusterNr,:),'Marker','o');
%     hold on
%     %drawnow
%     xlim([100,1700]);
%     ylim([100,1100]);
% end
% 
% figure(2)
% plot clusters
for idx = 1:size(x)
    pointsize = MT(idx,3)/3;
    clusterNr = IDX(idx);
    addpoints(h,x(idx,1),x(idx,2));
    
    scatter(x(idx,1), x(idx,2), pointsize, pntColor(clusterNr,:),'Marker','o');
    
     
    pause(MT(idx,3)/7000);
    
    drawnow
    xlim([100,1700]);
    ylim([100,950]);
end




