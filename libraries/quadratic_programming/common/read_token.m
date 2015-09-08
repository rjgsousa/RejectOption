function x = read_token(string, token, separator);
%	X = READ_TOKEN(STRING, TOKEN, SEPARATOR)
%	read_token returns the entry following TOKEN (separated
%	by '_') in STRING. if TOKEN occurs several times READ_TOKEN
%	returns the first one
%       By default SEPARATOR is '_' 

% File:        common/read_token.m
%
% Author:      Alex J. Smola
% Created:     02/07/98
% Updated:     05/08/00
% 
% This code is released under the GNU Public License
% Copyright by GMD FIRST and The Australian National University

if (nargin==2) 
  separator = '_';
end;

head = '';
while ((equal(head, token) ~= 1) & (isempty(string) ~= 1))
	[head, string] = strtok(string, separator);
end;
x = strtok(string, separator);







