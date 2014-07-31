function q = mtimes(l, r)
% *   Matrix multiply.
% (Quaternion overloading of standard Matlab function.)
 
% Copyright � 2005, 2009, 2010 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

% TODO This code avoids using the constructor (for good reason - to avoid
% time-costly error checks which we don't need) but it makes the mistake of
% doing this by copying one of the input parameters. Since this is a matrix
% multiplication, this can result in an initial value for q which is of
% incorrect size. Once assignments are made to q this will be fixed, but
% the change of size may also be costly. This requires study and a careful
% decision made whether to change it. Any proposed change will require
% execution time checks on the test code since this is such a core function
% within the toolbox. NB The same considerations do not apply to the
% elementwise product in times.m, since in that case the input parameters
% and the result must have the same size.

ql = isa(l, 'quaternion');
qr = isa(r, 'quaternion');

if ql && qr
    
    % Both arguments are quaternions. There are four cases to handle,
    % dependent on whether the arguments are pure or full.
    
    pl = isempty(l.w);
    pr = isempty(r.w);
    
    if pl
        if pr
            % Both arguments are pure quaternions.
            q = l; % Create a result by copying one of the arguments. This
                   % avoids a costly call to the constructor.
            q.w = -(l.x * r.x + l.y * r.y + l.z * r.z);
            q.x =               l.y * r.z - l.z * r.y;
            q.y = - l.x * r.z             + l.z * r.x;
            q.z =   l.x * r.y - l.y * r.x;
        else
            % The right argument is full, but the left is pure.
            q = r;
            q.w = -(l.x * r.x + l.y * r.y + l.z * r.z);
            q.x =   l.x * r.w + l.y * r.z - l.z * r.y;
            q.y = - l.x * r.z + l.y * r.w + l.z * r.x;
            q.z =   l.x * r.y - l.y * r.x + l.z * r.w;
        end
    else
        if pr
            % The left argument is full, but the right is pure.
            q = l;
            q.w = - l.x * r.x - l.y * r.y - l.z * r.z;
            q.x =   l.w * r.x             + l.y * r.z - l.z * r.y;
            q.y =   l.w * r.y - l.x * r.z             + l.z * r.x;
            q.z =   l.w * r.z + l.x * r.y - l.y * r.x;
        else
            % Both arguments are full quaternions. The full monty.
            q = l;
            q.w =  l.w * r.w - (l.x * r.x + l.y * r.y + l.z * r.z);
            q.x =  l.w * r.x +  l.x * r.w + l.y * r.z - l.z * r.y;
            q.y =  l.w * r.y -  l.x * r.z + l.y * r.w + l.z * r.x;
            q.z =  l.w * r.z +  l.x * r.y - l.y * r.x + l.z * r.w;
        end
    end
   
else
    % One of the arguments is not a quaternion. If it is numeric, we can
    % handle it.
    
    if ql && isa(r, 'numeric')
        q = l; % The left operand is a quaternion, so use it for the result
               % to avoid calling the constructor.     
        if ~isempty(l.w), q.w = q.w * r; end
        q.x = q.x * r; q.y = q.y * r; q.z = q.z * r;
    elseif isa(l, 'numeric') && qr
        q = r; % The right operand is a quaternion, so use it for the
               % result to avoid calling the constructor.  
        if ~isempty(r.w), q.w = l * q.w; end
        q.x = l * q.x; q.y = l * q.y; q.z = l * q.z;
    else
        error('Matrix multiplication of a quaternion by a non-numeric is not implemented.')
    end
end

% $Id: mtimes.m,v 1.11 2013/03/26 15:42:39 sangwine Exp $
