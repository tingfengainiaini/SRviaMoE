function prob = onedimgauss(mean, variance)
fact = mean.^2/variance;
prob = exp(-0.5*fact);
prob = prob./sqrt(2*pi*variance);