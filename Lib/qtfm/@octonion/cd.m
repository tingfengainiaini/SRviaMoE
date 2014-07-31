function [A, B] = cd(o)
% CD: returns two quaternions which are the Cayley-Dickson components
% of the octonion.

% Copyright � 2011 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(2, 2)

A = o.a; % The octonion is actually represented in this form, so the coding
B = o.b; % is trivial.

% $Id: cd.m,v 1.2 2013/04/04 17:20:07 sangwine Exp $
