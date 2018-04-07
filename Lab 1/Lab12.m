% Frequency stability property

function [maxIndex, I2] = Lab12(M)

[R,~] = size(M);

comb4 = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1;
         1 1 0 0; 0 1 1 0; 0 0 1 1; 1 0 1 0; 0 1 0 1; 1 0 0 1;
         0 1 1 1; 1 0 1 1; 1 1 0 1; 1 1 1 0; 
         0 0 0 0; 1 1 1 1];
 
[R4,~] = size(comb4);

occurM4 = zeros(R,R4);
stDevM4 = zeros(R,1);

% Nr = strfind(M(1,:), comb4(1,:));
% [~,C41] = size(Nr);

for i = 1:R
    for j = 1:R4
        occInd = strfind(M(i,:), comb4(j,:)); % saves indices where subsequence occurs
        [~,tempColsize] = size(occInd);    
        occurM4(i,j) = tempColsize; % saving number of occurences of each subsequence
    end
    stDevM4(i,:) = std(occurM4(i,:)); % Calculating standard diviation
end

[RI, CI] = sort(stDevM4, 'descend');
maxIndex = CI(1:12);
maxIndex = sort(maxIndex);
mean4 = mean(stDevM4)
I2 = [];
index = 0;

for r = 1:R
    if(stDevM4(r,:) > mean4*1.1)
        index = index + 1;
        I2(index) = r;
    end
end

