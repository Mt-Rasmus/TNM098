M = dlmread('data.csv', ';');

[R,C] = size(M);
zeroCountMat = zeros(R,1);
successorRank = zeros(R,1);
N_runs = zeros(R,1);

zerosTot = 0;
onesTot = 0;

for i = 1:R
    for j = 1:C
        
        if(M(i,j) == 0)
            zerosTot = zerosTot+1;
            zeroCountMat(i,:) = zeroCountMat(i,:) + 1;
        else
            onesTot = onesTot+1;
        end
        
        if(j>1 && (M(i,j-1) == M(i,j)))
            successorRank(i,:) = successorRank(i,:) + 1;
        end  
        
    end
end

% Idea: the human will have larger reoccurring sequences

% The "runs-test":

% n1 is number of zeros, n2 is number of ones (in each sample)
n1 = zeroCountMat;
n2 = zeros(R,1);
n2(:,:) = 200 - n1;
R_runs = zeros(R,1);
Z = zeros(R,1);
Zc = 1.96; % critical testm value with significance level alpha = 0.05
sR = zeros(R,1);
index = 0;
I = [];

for r = 1:R

    % Calculate the number of runs in each sample:
    
    N_runs(r) = nnz(diff(M(r,:)))+1;

    % Calculate number of expected runs (R_runs):
    
    R_runs(r) = (2*n1(r)*n2(r))/(n1(r)+n2(r)) + 1;

    % Calculate standard deviation of number of runs:
    
    sR(r) = sqrt(2*n1(r)*n2(r)*(2*n1(r)*n2(r)-n1(r)-n2(r))...
          / (((n1(r)+n2(r))^2)*(n1(r)+n2(r)-1)));

    % Calculate test statistic:
    
    Z(r) = (N_runs(r) - R_runs(r)) / sR(r);
    
    % Check if the test statistics is rejected by the null hypothesis:
    
    if (abs(Z(r)) > Zc)

        index = index + 1;
        I(index) = r;

    end

end

[RI, CI] = size(I);
M2 = zeros(CI,C);
M2 = M(I,:); % storing all the "failed" sequences

% possible correlations:
% runs-test (above)
% number of runs

% Logical assumptions:
% a human will have a larger amount of runs because they might feel forced
% to change sign more frequently to simulate randomness. A computer does
% not have this issue.

