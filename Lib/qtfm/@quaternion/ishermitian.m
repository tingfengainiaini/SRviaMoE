function tf = ishermitian(A, tol)
% ISHERMITIAN  True if the given matrix is Hermitian to within the tolerance
% given (optionally) by the second parameter.

% Copyright � 2005 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 2), nargoutchk(0, 1)

if nargin == 1
    tol = 4 .* eps; % The tolerance was not specified, supply a default.
end

[r, c] = size(A);

if r ~= c
    error('Cannot test whether a non-square matrix is Hermitian.');
end

% Note that we use the ctranspose here, so the definition of Hermitian is
% intimately dependent on the correct definition of ctranspose (which is
% not so trivial for a biquaternion matrix).

tf = ~any(any(abs(vector(A - A')) ./ max(max(abs(A))) > tol));

% $Id: ishermitian.m,v 1.4 2013/06/14 10:05:43 sangwine Exp $
