function tf = isempty(q)
% ISEMPTY True for empty matrix.
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2005 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

% narginchk(1, 1), nargoutchk(0, 1)

% It is sufficient to check the x component, because if x is empty so must
% be the y and z components. We must not check the scalar component,
% because this is empty for a non-empty pure quaternion.
     
tf = isempty(q.x); 

% $Id: isempty.m,v 1.5 2013/04/04 17:20:07 sangwine Exp $

