% possible methods: Color Coherence Vector (CCV), SIFT, color histogram

allImgs = {};
allCCV = {};
images ='images';
jpgfiles=dir(fullfile(images,'\*.jpg*'));
n=numel(jpgfiles);

coherentPrec = 1;
numberOfColors = 27;

for i = 1:n
    im=imread(fullfile(images,jpgfiles(i).name));
    allCCV{i} = getICCV(im,coherentPrec, numberOfColors);
    allImgs{i} = im;
    
end
test1 = allCCV{1};
test2 = allCCV{2};
test3 = allCCV{3};

sum(sum(test1(1:2,:)))
sum(sum(test2(1:2,:)))
sum(sum(test3(1:2,:)))
%ICCV = getICCV(im,coherentPrec, numberOfColors);