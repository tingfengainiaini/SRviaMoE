function x = ess(q)
% Extracts the scalar component of a full quaternion. If q is a pure
% quaternion, an error is raised, since the scalar part of a pure
% quaternion should not be extracted.

% Copyright � 2005 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

% narginchk(1, 1), nargoutchk(0, 1)

error('Obsolete private function ess called.')

if isempty(q.w)
    error('The scalar part of a pure quaternion is not defined.');
end

x = q.w;

% $Id: ess.m,v 1.4 2013/04/04 17:20:08 sangwine Exp $
