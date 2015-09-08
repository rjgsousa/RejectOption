function x = display(d)
%DISPLAY Basic template for the optimizer routines of the interior point family
%	
%	X = DISPLAY(D) when called with an output argument prints out
%	the parameter setting which can be used with a logfile

% File:        @intpoint/display.m
%
% Author:      Alex J. Smola
% Created:     01/18/98
% Updated:     05/08/00
%
% This code is released under the GNU Public License
% Copyright by GMD FIRST and The Australian National University

if nargout == 0
  tmp = sprintf(['Interior Point Optimizer\n' ...
		 'Type       \t: %s\n' ...
		 'Verbosity  \t: %d\n' ...
		 'Sigfig     \t: %d\n' ...
		 'Maxiter    \t: %d\n' ...
		 'Margin     \t: %d\n' ...
		 'Bound      \t: %d'], ...
		d.name, d.verbose, d.sigfig, d.maxiter, d.margin, d.bound);
  disp(tmp);
else
  x = sprintf('%s_sigfig_%d_maxiter_%d_margin_%d_bound_%d', ...
	      d.name, d.sigfig, d.maxiter, d.margin, d.bound);
end
