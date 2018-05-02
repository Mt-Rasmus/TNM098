% possible methods: Color Coherence Vector (CCV), SIFT, color histogram,
% HOG features (Histogram of oriented gradients), Sobel edges, 
% viewpoint feature histogram (VFH), hough transform

images ='images';
jpgfiles=dir(fullfile(images,'\*.jpg*'));
n=numel(jpgfiles);

allImgs = {};
featureVector = {};
featureVectors = {};
allLAB = {};

for i = 1:n
    im=imread(fullfile(images,jpgfiles(i).name));
    allImgs{i} = im;  
    allLAB{i} = rgb2lab(im);
end

IDX = 2; % This is the image index that will be compared to all the other images in final result

%%

% Standard color histogram

for i = 1:n
    
    theImg = allImgs{i};

    % Color histgram

    [sortedDists, rankIndex, histDistAll, RGBhist] = colorHistogram( theImg, allImgs, n );

    featureVector{1} = RGBhist;
    
    % LAB mean values

    LABMean = 1:3;

    LMean = mean(mean(allLAB{i}(:,:,1)));
    AMean = mean(mean(allLAB{i}(:,:,2)));
    BMean = mean(mean(allLAB{i}(:,:,3)));

    LABMean = [LMean AMean BMean]; 
    featureVector{2} = LABMean;
    
    % RGB standard deviation
    
    STD = 1:3;

    RStd = std2(allImgs{i}(:,:,1));
    GStd = std2(allImgs{i}(:,:,2));
    BStd = std2(allImgs{i}(:,:,3));

    STD = [RStd GStd BStd]; 
 
    featureVector{3} = STD;
        
    featureVectors{i} = featureVector;
    featureVector = {};
        
end % END main for loop


%% Color histgram comparison

refImg = featureVectors{IDX};
intersectR = [];
intersectG = [];
intersectB = [];
histDiff = 1:n;

for j = 1:n
   
    modelImg = featureVectors{j};
    
    for i = 1:256
     
    intersectR(i) = min(refImg{1}{1}(i), modelImg{1}{1}(i));
    intersectG(i) = min(refImg{1}{2}(i), modelImg{1}{2}(i));
    intersectB(i) = min(refImg{1}{3}(i), modelImg{1}{3}(i));
    
    end
    
    [r, c] = size(allImgs{j});
    noPixels = r*c;
    
    histDiff(j) = sum((intersectR + intersectG + intersectB)./noPixels);
     
end

[histMaxVal, I1] = max(histDiff);

%%

LABdiff = 1:n;
STDdiff = 1:n;

for j = 1:n
    
        modelLab = featureVectors{j};
    
        % LAB comparison:
        
        LABref = refImg{2};
        LABmod = modelLab{2};
        LABdiff(j) = sqrt(sum((LABref - LABmod) .^ 2)); 
        
        % STD comparison
        
        STDref = refImg{3};
        STDmod = modelLab{3};
        STDdiff(j) = sqrt(sum((STDref - STDmod) .^ 2)); 

end

        LABdiff = LABdiff./max(LABdiff);
        STDdiff = STDdiff./max(STDdiff);
        

%% Final classification

w1 = 0.3;
w2 = 0.5;
w3 = 0.2;
vec = 1:n;
refIndex = IDX;
distVec = 1:n;

for i = 1:n
    vec(i) = w1 * (1-histDiff(i)) + w2 * LABdiff(i) + w3 * STDdiff(i);
end

refVal = vec(refIndex);

for j = 1:n
    
    distVec(j) = sqrt((refVal-vec(j))^2);
    
end

%% Sort and display

    [I, U] = sort(distVec);
    
    figure
     
    for s = 1:12
        sp = subplot(4, 3, s); image(allImgs{U(s)}, 'Parent', sp);
    end
  
