function centroid = calcCentroid(points)

    [nrClusterPoints,~]  = size(points);
    centroid = sum(points)/nrClusterPoints;

end