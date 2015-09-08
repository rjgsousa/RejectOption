function t = flop
%FLOP	Read the flops counter.
%	FLOP, by itself, prints the flops since FLIP was used.
%	t = FLOP; saves the flops in t, instead of printing it out.
%
%	See also FLIP, FLOPS.

%	Copyright (c) 1997 by Alex Smola

% FLIP uses flops and the value of FLIPFLOP saved by FLIP.
global FLIPFLOP
new_flop = flops;
if nargout < 1
   elapsed_flops = new_flop - FLIPFLOP;
   fprintf(1,'flops used: %i\n', elapsed_flops);
else
   t = new_flop - FLIPFLOP;
end
% compensate for the two flops during resetting
FLIPFLOP = FLIPFLOP + 2;
