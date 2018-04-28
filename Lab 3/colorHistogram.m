function [ I, U, histDist ] = colorHistogram( theImg, allImgs, n )

histDist = [];

for i = 1:n
    
    %Split into RGB Channels
    R1 = theImg(:,:,1);
    G1 = theImg(:,:,2);
    B1 = theImg(:,:,3);
    
    %Get histValues for each channel
    [IR1, x1] = imhist(R1);
    [IG1, y1] = imhist(G1);
    [IB1, z1] = imhist(B1);
    
    R2 = allImgs{i}(:,:,1);
    G2 = allImgs{i}(:,:,2);
    B2 = allImgs{i}(:,:,3); 
    
    [IR2, x2] = imhist(R2);
    [IG2, y2] = imhist(G2);
    [IB2, z2] = imhist(B2);
    
    histDist(i) = pdist2(IR1', IR2') + pdist2(IG1', IG2') + pdist2(IB1', IB2');
    
end


    [I, U] = sort(histDist);
    
    figure
    
    for s = 1:12
        sp = subplot(4, 3, s); image(allImgs{U(s)}, 'Parent', sp);
    end
    

end

