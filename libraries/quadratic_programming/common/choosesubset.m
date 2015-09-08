function S = choosesubset(N,M);
% function S = choosesubset(N,M);
% This just produces a randomly selected and randomly ordered
%   subset of the integers 1 .. M, which has N members

% File:        common/choosesubset.m
%
% Author:      Ben O'Loghlin
% Created:     03/05/01
% Updated:     03/05/01
%
% This code is released under the GNU Public License
% Copyright by The Australian National University

% Currently this is implemented via the Matlab function "randperm",
% which is in turn implemented by the built-in function
% "sort". This is not a very efficient way to do it, O(M) instead
% of O(N). Should fix it soon; for the moment this implementation
% will do.

randomindex = randperm(M);
S = randomindex(1:N);









