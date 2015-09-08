function a = subsasgn(a,s,b)
%    A = SUBSASGN(A,S,B) is called for the syntax A(I)=B, A{I}=B, or
%
%    A.I=B when A is an object.  S is a structure array with the fields:
%        type -- string containing '()', '{}', or '.' specifying the
%                subscript type.
%        subs -- Cell array or string containing the actual subscripts. 

% File:        @data/subasgn.m
%
% Author:      Gunnar R"atsch, Alex Smola
% Created:     02/11/98
% Updated:     02/21/98 05/08/00
%
% This code is released under the GNU Public License
% Copyright by GMD FIRST and The Australian National University

Q = 'a';

for i=1:length(s)
  if equal(s(i).type, '.')
    Q=[Q, '.', s(i).subs];
  elseif equal(s(i).type, '()')
    tmp = length(s(i).subs);
    Q=[Q, '('];
    for j=1:(tmp-1)
      Q=[Q, 's(', num2str(i), ').subs{', num2str(j), '}, '];
    end;
      Q=[Q, 's(', num2str(i), ').subs{', num2str(tmp), '})'];
  elseif equal(s(i).type, '{}')
    tmp = length(s(i).subs);
    Q=[Q, '{'];
    for j=1:(tmp-1)
      Q=[Q, 's(', num2str(i), ').subs{', num2str(j), '}, '];
    end;
    Q=[Q, 's(', num2str(i), ').subs{', num2str(tmp), '}}'];
  end ;
end;

Q = [Q, ' = b;'];

eval(Q) ;
