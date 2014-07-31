function n = norm(A, p)
% NORM   Matrix or vector norm.
% (Quaternion overloading of standard Matlab function, with some limitations.)

% Copyright � 2005 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 2), nargoutchk(0, 1) 

% We have to handle two different cases, depending on whether A is a vector
% or a matrix. The limiting case of a vector (a single quaternion) is handled
% using the vector case.

if nargin == 1
    n = norm(A, 2);
    return
end

[r,c] = size(A);

if isvector(A)
    % A is a vector.
    switch p
    case 1
        n = sum(abs(A));
    case 2
        n = sqrt(sum(normq(A)));
    % case other integer values of p are not supported, although the
    % standard Matlab norm function does handle them.
    case inf
        n = max(abs(A));
    case -inf
        n = min(abs(A));
    otherwise
        error('Illegal second parameter to quaternion vector norm.')
    end
elseif ismatrix(A)
    % A is a matrix.
    switch p
    case 1
        n = max(sum(abs(A)));
    case 2
        t = svd(A);
        n = t(1);
    case inf
        n = max(sum(abs(A')));
    case 'fro'
        % This is coded more or less as defined for the standard Matlab norm
        % function, but it is necessary to take the scalar part of the diagonal
        % vector, because the result is quaternion-valued. A more efficient
        % coding would compute the column norms directly.
        n = sqrt(sum(s(diag(A'*A))));
    otherwise
        error('Illegal second parameter to quaternion matrix norm.')
    end
else
    % A must have more than two dimensions.
    error('Cannot compute norm of arrays with more than two dimensions.')
end

% $Id: norm.m,v 1.6 2013/04/04 16:54:09 sangwine Exp $
