function flip
%FLIP	Start a flops counter
%	The sequence of commands
%	    FLIP
%	    any stuff
%	    FLOP
%	prints the flops required for the stuff.
%
%	See also FLOP, FLOPS.

%	Copyright (c) 97 by Alex Smola

% FLIP simply stores flops in a global variable.
global FLIPFLOP
FLIPFLOP = flops;
