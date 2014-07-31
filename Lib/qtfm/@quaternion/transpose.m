function t = transpose(a)
% .'  Transpose.
% (Quaternion overloading of standard Matlab function.)

% Copyright � 2005 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1) 

%t = overload(mfilename, a);

% Because transpose is such a fundamental operation, it is coded directly
% here rather than calling the overload function as in the original code
% above.

t = a;
t.w = transpose(t.w); % Transposing empty gives empty, so no harm if pure.
t.x = transpose(t.x);
t.y = transpose(t.y);
t.z = transpose(t.z);

% $Id: transpose.m,v 1.7 2013/04/04 17:20:07 sangwine Exp $
