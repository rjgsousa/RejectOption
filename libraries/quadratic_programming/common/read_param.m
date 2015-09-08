function ob = read_param(p, ob, varlist, defaults)
%
% reads parameters from object calls 
%
%
%
% File:        @data/data.m
%
% Author:      Alexandros Karatzoglou
% Created:     27/11/02
% Updated:     27/11/02
% 
% Copyright (c) 2002 Australian National University
% This code is released under the GNU Public License

if (~isempty(varlist) & ~isempty(defaults))
  if ~(length(varlist) == length(defaults))      % just check
    disp('default values dont match given parameter list')
  else 
    ob = cell2struct(defaults, varlist, 2);
  end;
end;

if  isempty(p)  | (iscell(p) & isempty(p{1}) & length(p)==1 ) 
  return;                                      % do nothing

  
  
  
elseif iscell(p) & isa(p{1}, 'char') & length(p)==1          % we have a char (parse it)
  if fexist(p{1})                                            % the format string describes a file name -> load it
    load(p{1});
    ob = svlab_data;	     		                     % from file
    clear svlab_data;
    
  elseif ~isempty(findstr('=',p{1}))                        %  we have a '=' entry format
                                                                                           
    h=p{1}; ex=[]; extra=[];
    if h(length(h))==';' 
      h=h(1:length(h)-1); 
    end;
                                                              % split
    f = find(h==';');  
    f = [0 f length(h)+1 ];
    for i=1:length(f)-1
      ex{i}=h(f(i)+1:f(i+1)-1); 
    end
    p{1} = ex{1};
    a1=extra; 
    if ~isempty(a1) a1=make_cell(a1); 
    end;
    a2=ex(2:length(ex)); 
    if ~isempty(a2) a2=make_cell(a2); 
    end;
    extra=[a1 a2];   
    
    if ~isempty(extra)
      p=[p extra];
    end; 
   
    for j=1:length(p)
      if iscell(p{j}) p{j}=p{j}{1};  
      end;                                                     %  add '=1' if no equals 
      if ischar(p{j})                
	if isempty(findstr('=',p{j}))  
	  p{j}=[p{j} '=1'];
	end
      end
    end
    for i=1:size(p,2)
      value=p{i};
      if ischar(value) 
	value(find(value=='"'))=char(39);                   
      end
      if exist('evalobject') & evalobject==0
	eval([value ';']);
      else
	eval(['ob.',value,';']); 
      end
    end;     
 
 
  
else
  
    paramstring = p{1};		                % that's what it really is
    for i = 1:length(varlist)
      ob = setdata(ob, paramstring, varlist{i});
    end;
  end;
  
%elseif (nargin == 1)
%  d.info = varargin;
elseif (length(p) == length(varlist))
  ob = cell2struct(p, varlist, 2); 
else
  disp('something wrong with the parameters in @data/data.m');
end;



function data = setdata(data, d_token, d_string)

if isempty(read_token(d_token, d_string)) == 0
  eval(['data.',d_string,'= str2num(read_token(d_token, d_string));']);
end;
