function Y = asin(X)
% ASIN    Inverse sine.
% (Quaternion overloading of standard Matlab function.)

% Copyright � 2006 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

if isreal(X)
    
    % X is a real quaternion, and we compute the inverse sine of an
    % isomorphic complex number using the standard Matlab asin function,
    % then construct a quaternion with the same axis as the original
    % quaternion.
    
    Y = isoquaternion(asin(isocomplex(X)), X);
else
    
    % X is a complex quaternion, and therefore we cannot use the method
    % above for real quaternions, because it is not possible to construct
    % an isomorphic complex number.
    
    error('quaternion/asin is not yet implemented for complex quaternions');
end;

% $Id: asin.m,v 1.3 2013/04/04 17:20:07 sangwine Exp $

