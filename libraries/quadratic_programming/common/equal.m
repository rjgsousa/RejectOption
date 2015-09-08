function x = equal(label1, label2)
% EQUAL(LABEL1, LABEL2) tests LABEL1 and LABEL2 for equality
% we need a special function as the two labels may be of different
% length and '==' might exit telling that the matrix dimensions don't agree
%
% returns 1 if true and 0 if false

% Copyright (c) 1997  GMD Berlin
% --- All Rights Reserved ---
% THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF 
% GMD Berlin and Lucent Technologies
% The copyright notice above does not evidence any
% actual or intended publication of this work.
%
% Authors: Alex J. Smola
% Date   : 04/18/97
%

if (length(label1) == length(label2))
	tmp = label1 == label2;
	x = (sum(tmp) == length(tmp));
else
	x = 0;
end