% This script compiles Matlab's MEX interfaces for LIBQP solvers.
%

mex libqp_splx_mex.c ../lib/libqp_splx.c
mex libqp_gsmo_mex.c ../lib/libqp_gsmo.c

