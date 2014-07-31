function r = fftflip(x)
% FFTFLIP  Interchange elements to effect time reversal/frequency reversal.

% Copyright � 2013 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

% This code implements a type of flip operation, in which the first element
% of the array remains unchanged and the rest reverse their order. Given an
% even length array indexed by 1:n, the result is indexed 1 n n-1 ... 2. An
% odd length array is dealt with in the same way. Expressed in terms of
% frequency coefficients of an FFT, the DC term stays put, the Nyquist term
% stays put (even length only), and the positive and negative frequency
% terms swap places.

% If the input is a matrix, this function operates on the columns.

% Reference:
%
% Ell, T. A., Le Bihan, N. and Sangwine, S. J.,
% Quaternion Fourier Transforms for Signal and Image Processing,
% Wiley-ISTE, ISBN 978-1-84821-478-1, 140pp. Chapter 3.
% In press, publication expected June 2014.

if length(size(x)) > 2
    error('Input must be a vector or matrix.')
end

if isvector(x)
    r = x([1, fliplr(2:end)]);
else
    r = x([1, fliplr(2:end)], :);
end

end

% $Id$