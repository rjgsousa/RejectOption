function d = intpoint_pr(a)
%INTPOINT Pattern Recognition Optimizer
%
%  creates an optimizer object with all basic settings installed
%  (sigfig etc.)

% File:        @intpoint_pr/intpoint_pr.m
%
% Author:      Alex J. Smola
% Created:     01/18/98
% Modified:    05/08/00
%
% This code is released under the GNU Public License
% Copyright by GMD FIRST and The Australian National University

d.name      = 'pattern_recognition';
d.verbose = 0;				% by default we're quiet
%
if nargin == 0
  d.sigfig  = 7;			% 7 significant figures -
                                        % very precise
  d.maxiter = 50;			% stop after 50 iterations
  d.margin = 0.05;			% get up to this much
                                        % closer to the constraints
  % THIS HAS NOTHING TO DO WITH THE MARGIN OF A CLASSIFIER, SO DON'T
  % SEND COMMENTS ASKING ABOUT THIS!
  d.bound = 10;				% clipping bound for the
                                        % variables (may have to
                                        % adjust that on a per
                                        % problem basis)
elseif (nargin == 1) & isa(a, 'char')
  token = read_token(a, 'sigfig');
  d.sigfig = str2num(token);
  token = read_token(a, 'maxiter');
  d.maxiter = str2num(token);
  token = read_token(a, 'margin');
  d.margin = str2num(token);
  token = read_token(a, 'bound');
  d.bound = str2num(token);
else
  error('wrong type of arguments');
end

d = class(d, 'intpoint_pr');		% make it a class
%d = class(d, 'intpoint_pr', intpoint);	% make it a class
%superiorto('intpoint');
