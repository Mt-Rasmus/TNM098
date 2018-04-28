% possible methods: Color Coherence Vector (CCV), SIFT, color histogram,
% HOG features (Histogram of oriented gradients), Sobel edges, 
% viewpoint feature histogram (VFH)

images ='images';
jpgfiles=dir(fullfile(images,'\*.jpg*'));
n=numel(jpgfiles);

allImgs = {};
allCCV = {};

for i = 1:n
    im=imread(fullfile(images,jpgfiles(i).name));
    allImgs{i} = im;  
end

%imshow(allImgs{14});

%% Standard color histogram
theImg = allImgs{5};

[sortedDists, rankIndex, histDistAll] = colorHistogram( theImg, allImgs, n );

%%

vectest = [70, 1, 10, 999]
[I1, U1] = sort(vectest);

%%

testImg = allImgs{13};
ssimval = [];

for u = 1:n

    ssimval(u) = ssim(testImg,allImgs{u});

end

%% HOG feature extraction
% https://se.mathworks.com/help/vision/ref/extracthogfeatures.html
% https://www.researchgate.net/post/HOG_for_images_of_different_sizes2

X = allImgs{13};
X2 = allImgs{28};

minRows = 99999;
minCols = 99999;

for j = 1:n
    [rows,cols] = size(allImgs{j});
    if(cols < minCols)
        minCols = cols;
    end
    if(rows < minRows)
        minRows = rows;
    end
end

%[featureVector,hogVisualization] = extractHOGFeatures(double(X),[50 50]);
[featureVector,hogVisualization] = extractHOGFeatures(double(X),'CellSize',[8 8], 'Blocksize', [4,4]);
[featureVector2,hogVisualization2] = extractHOGFeatures(double(X2),'CellSize',[8 8], 'Blocksize', [4,4]);

hej = mean(featureVector);

corners   = detectFASTFeatures(rgb2gray(X));

% figure;
% imshow(X); 
% hold on;
% plot(corners);

%% regular edge detection

edge_det_pic1 = edge(rgb2gray(X),'prewitt');

%%applying edge detection on second picture
%so that we obtain white and black points and edges of the objects present
%in the picture.

edge_det_pic2 = edge(rgb2gray(X2),'prewitt');

%% Standard deviation
stds = 1:n;

% cellmat(A,B,C,D,v) takes four integer values and one scalar value v, 
% and returns an A-by-B cell array of C-by-D matrices of value v. 
% If the value v is not specified, zero is used.

for s = 1:n
    [H S V] = rgb2hsv(allImgs{s});
    stds(s) = std2(V);
    
end
imshow(V);
[Q, Q1] = sort(stds);
