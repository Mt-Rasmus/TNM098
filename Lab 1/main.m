% main
M = dlmread('data.csv', ';');

I = Lab1(M);
[I2, I3] = Lab12(M);

numel(intersect(I,I3))
