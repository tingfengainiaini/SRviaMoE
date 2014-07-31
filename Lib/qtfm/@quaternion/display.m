function display(q)
% DISPLAY Display array.
% (Quaternion overloading of standard Matlab function.)

% Copyright � 2005, 2008 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

if isempty(inputname(1))
    
    name = 'ans';
    
    % TODO It would be good if we could update ans to have the value of q,
    % but even the standard Matlab display function doesn't do this.
    % For example, try: display(2 * pi). The result is:
    %
    % ans =
    % 
    %     6.2832
    %
    % but the variable ans is not modified if it exists, and not created if
    % it doesn't exist. So although what happens here is not ideal, it does
    % at least match what Matlab does.
else
    name = inputname(1);
end

% The test for Matlab on the next line is a crude hack to make this code
% work under Octave, since Octave (3.2.4 at least) does not recognise the
% FormatSpacing parameter.
if ismatlab && isequal(get(0,'FormatSpacing'),'compact')
  disp([name ' =']);
  disp(q);
else
  disp(' ');
  disp([name ' =']);
  disp(' ');
  disp(q);
  disp(' ');
end
end

function TF = ismatlab
% Returns true if the code is running under Matlab.

S = ver('Matlab');
TF = ~isempty(S);
end

% $Id: display.m,v 1.7 2011/05/24 15:48:52 sangwine Exp $
