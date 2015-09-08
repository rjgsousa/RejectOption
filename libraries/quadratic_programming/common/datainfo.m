function x = datainfo(format, problemtype, filename, loadpath, ...
    savepath, standardize, permute, pca) 
% X = DATAINFO(FORMAT, PROBLEMTYPE, FILENAME, LOADPATH, SAVEPATH, STANDARDIZE,
% PERMUTE, PCA)
% constructs an object containing all information necessary for a data
% object. the nice point is that this information can be stored
% seperately without having to save the whole matrix again
%
% FORMAT       = {matlab, sn} (dataformat on disk)
% PROBLEMTYPE = {twoclass, multiclass, regression}
% FILENAME
% LOADPATH      where to load the data
% SAVEPATH      also important for the data generated after training
% STANDARDIZE    flag (if set it checks if standardization already
%                happened, if not, does it)
% PERMUTE        flag (permute data)

x.format = 'matlab';			% standard save format
x.problemtype = 'twoclass';		% binary classifier
x.name = 'noname';
x.filename = 'noname';
x.loadpath = '';
x.savepath = '';
x.standardize = 0;			% we won't standardize unless
% we're asked to
x.permute = 0;				% nor will we permute the data
x.pca = 0;				% pca neither

if nargin == 1				% we'll do parsing
  x.format = get_token(format, 'format');
  x.problemtype = get_token(format, 'problemtype');
  x.name = get_token(format, 'name');
  x.filename = get_token(format, 'filename');
  x.loadpath = get_token(format, 'loadpath');
  x.savepath = get_token(format, 'savepath');
  x.standardize = str2num(get_token(format, 'standardize'));
  x.permute = str2num(get_token(format, 'permute'));
  x.pca = str2num(get_token(format, 'pca'));
elseif nargin == 9
  if isempty(format) == 0
    x.format = format;
  end;
  if isempty(problemtype) == 0
    x.problemtype = problemtype;
  end;
  if isempty(name) == 0
    x.name = name;
  end;
  if isempty(filename) == 0
    x.filename = filename;
  else
    x.filename = x.name;
  end;
  if isempty(loadpath) == 0
    x.loadpath = loadpath;
  end;
  if isempty(savepath) == 0
    x.savepath = savepath;
  else
    x.savepath = x.loadpath;
  end;
  if isempty(standardize) == 0
    x.standardize = standardize;
  end;
  if isempty(permute) == 0
    x.permute = permute;
  end;
  if isempty(pca) == 0
    x.pca = pca;
  end;
end;

