function [primal, dual, how] = optimize_jiayuan(optimizer, c, H, A, b, l, ...
					u, Hnn)
%[PRIMAL, DUAL, HOW] = OPTIMIZE(optimizer, c, H, A, b, l, u)
%
%optimize solves the quadratic programming problem
%
%minimize   c' * primal + 1/2 primal' * H * primal
%subject to A*primal = b
%           l <= primal <= u
%
%returns primal and dual variables (i.e. primal and the Lagrange
%multipliers for A * primal <= b
%
%for additional documentation see 
%     R. Vanderbei 
%     LOQO: an Interior Point Code for Quadratic Programming, 1992

% File:        @intpoint/optimize.m
%
% Author:      Alex J. Smola
% Created:     12/12/97
% Updated:     08/05/00
%
% This code is released under the GNU Public License
% Copyright by GMD FIRST and The Australian National University

% gather some starting data
[m, n] = size(A); 

% this is done in order not to mess up H but only to tamper with H_x
if(nargin < 7 | nargin > 8) 
     error('wrong number of arguments')
elseif nargin == 7
  if (size(H,1) == size(H,2))
    smw = 0;
    hnn = 0;
  elseif (size(H,1) < size(H,2))
    smw = 1;
    hnn = 0; 
  end
elseif nargin == 8 
  smw = 1;
  hnn = 1;
end


% gather some starting data
[m, n] = size(A); 

if(size(H,1) ~= size(H,2) & size(H,1)> size(H,2))
  error('H matrix has to be symmetric or first dimension bigger than second')
	   
elseif(size(H,2) ~= n) 
  error('number of rows in A not compatible with H dimensions')
				   
elseif(size(b,1) ~=1 & size(b,1)~=m)
  error('rows of b not compatible with A')
  
elseif(size(b,2)~=1)
  error('b has to be a column vector')
  
 elseif(size(l,1)~= n)
   error('rows of l dont match problem')
   
elseif(size(u,1)~= n)
  error('rows of u dont match problem')
  
elseif(size(l,2)~=1)
  error('l has to be a column vector')
  
elseif(size(u,2)~=1)
  error('u has to be a column vector')
  
elseif(size(c,1)~=n)
  error('number of rows in c dont match problem')
  
elseif(size(c,2)~=1)
  error('c has to be a column vector')
  
end;




H_x    = H;
H_diag = diag(H);

b_plus_1 = 1;
c_plus_1 = norm(c) + 1;
one_x = -ones(n,1);
one_y = -ones(m,1);

% starting point

% starting point
if(smw == 0)
  for i = 1:n 
    H_x(i,i) = H_diag(i) + 1; 
  end;
elseif (smw == 1)
  smw_n = size(H, 1);
end;


H_y = eye(m);
c_x = c;
c_y = b;

% and solve the system [-H_x A'; A H_y] [x, y] = [c_x; c_y]
% solution
% y = (H_y - A^\top H_x^{-1} A)^{-1} (c_y - A^\top H_x^{-1} c_x)
% x = H_x^{-1} c_x - H_x^{-1} A y
if(smw == 0)    
R = chol(H_x);
a_r = A / R;
c_r = c_x'/ R;
H_tmp = a_r * a_r' + H_y;
y = H_tmp \ (c_y + a_r * c_r');
x = R \ (a_r' * y - c_r');
elseif (smw == 1)
  % this time it should be really clean (Alex)
  if(hnn == 0)
    V = eye(smw_n);
  elseif (hnn == 1)
    V = Hnn;
  end;
  smw_inner = chol(V + H * H'); % inner term in the
					 % SMW formula
  smw_a1 = A';			% takes care of diagonal 
  smw_c1 = c_x;			% no scaling (D = 1)
  smw_a2 = smw_a1 - (H' * (smw_inner \ (smw_inner' \ (H * smw_a1))));
  smw_c2 = smw_c1 - (H' * (smw_inner \ (smw_inner' \ (H * smw_c1))));
			 
  y = (A * smw_a2 + H_y) \ (c_y + A * smw_c2);
  x = smw_a2 * y - smw_c2;
end;
g = max(abs(x - l), optimizer.bound);
z = max(abs(x), optimizer.bound);
t = max(abs(u - x), optimizer.bound);
s = max(abs(x), optimizer.bound);

mu = (z' * g + s' * t)/(2 * n);

% set some default values
sigfig = 0;				% number of significant figures
counter = 0;				% iteration counter
alfa = 1;				% scaling factor

if (optimizer.verbose > 0)	% print at least one status report
  report = sprintf(['Iter \tPrimalInf \tDualInf \tSigFigs ' ...
		    '\tRescale \tPrimalObj \tDualObj']); 
  disp(report);
end

while (counter < optimizer.maxiter),

  %update the iteration counter
  counter = counter + 1;
  
  %central path (predictor)
  if(smw == 0)
  for i = 1:n 
    H_x(i,i) = H_diag(i); 
  end;
end;
  if (smw == 0)
  H_dot_x = H * x;  
  elseif (smw == 1)
    if(hnn == 0)
      H_dot_x = (H' * (H * x));
    elseif(hnn == 1)
       H_dot_x = (H' * (inv(Hnn) * (H * x)));
    end;
  end;
  
  
 
  
  rho = - A * x + b;
  nu = l - x + g;
  tau = u - x - t;
  sigma = c - A' * y - z + s + H_dot_x;
  
  gamma_z = - z;
  gamma_s = - s;
  
  % instrumentation
  x_dot_H_dot_x = x' * H_dot_x;
  
  primal_infeasibility = norm([tau; nu; rho]) / b_plus_1;
  dual_infeasibility = norm([sigma]) / c_plus_1;
  
  primal_obj = c' * x + 0.5 * x_dot_H_dot_x;
  dual_obj = b' * y - 0.5 * x_dot_H_dot_x + l' * z - u' * s;
  
  old_sigfig = sigfig;
  sigfig = max(-log10(abs(primal_obj - dual_obj)/(abs(primal_obj) + 1)), 0);
  
  if (sigfig >= optimizer.sigfig) break; end;
  if (optimizer.verbose > 1)			% final report
    report = sprintf('%i \t%e \t%e \t%e \t%e \t%e \t%e', ...
		     counter, primal_infeasibility, dual_infeasibility, ...
		     sigfig, alfa, primal_obj, dual_obj);    
    disp(report);
  end

  % some more intermediate variables (the hat section)
  hat_nu = nu + g .* gamma_z ./ z;
  hat_tau = tau - t .* gamma_s ./ s;
  
  % the diagonal terms
  d = z ./ g + s ./ t;
  
  % initialization before the big cholesky
  if (smw ==0)
    for i = 1:n H_x(i,i) = H_diag(i) + d(i); end;
  end;
  H_y = 0;
  c_x = sigma - z .* hat_nu ./ g - s .* hat_tau ./ t;
  c_y = rho;

  % and solve the system [-H_x A'; A H_y] [delta_x, delta_y] = [c_x; c_y]
if(smw == 0)    
  R = chol(H_x);
  a_r = A / R;
  c_r = c_x'/ R;
  H_tmp = a_r * a_r' + H_y;
  delta_y = H_tmp \ (c_y + a_r * c_r');
  delta_x = R \ (a_r' * delta_y - c_r');
  
elseif (smw == 1)[]
  if(hnn == 0)
    V = eye(smw_n);
  elseif (hnn == 1)
    V = Hnn;
  end;
  smw_inner = chol(V + chunkmult(H, 2000, d));
%  smw_innerold = chol(eye(smw_n) + chunkmultold(H, 2000, d));
 % norm(smw_inner - smw_innerold)
  % inner term in the SMW formula

  smw_a1 = A';			
  % and scale it
  for i=1:m
    smw_a1(:,i) = smw_a1(:,i) ./ d;
  end;
  smw_c1 = c_x ./ d;			

  smw_a2 = A' - (H' * (smw_inner \ (smw_inner' \ (H * smw_a1))));
  % and scale it
  for i=1:m
    smw_a2(:,i) = smw_a2(:,i) ./ d;
  end;
  smw_c2 = (c_x - (H' * (smw_inner \ (smw_inner' \ (H * smw_c1)))))./d;

  delta_y = (A * smw_a2 + H_y) \ (c_y + A * smw_c2);
  delta_x = smw_a2 * delta_y - smw_c2;
  end;
  
  %backsubstitution
  delta_s = s .* (delta_x - hat_tau) ./ t;
  delta_z = z .* (hat_nu - delta_x) ./ g;
  
  delta_g = g .* (gamma_z - delta_z) ./ z;
  delta_t = t .* (gamma_s - delta_s) ./ s;
  
  %compute update step now (sebastian's trick)
  alfa = - (1-optimizer.margin) / min([delta_g ./ g; delta_t ./ t;
                    delta_z ./ z; delta_s ./ s; -1]);
  newmu = (z' * g + s' * t)/(2 * n);
  newmu = mu * ((alfa - 1) / (alfa + 10))^2;  
  
  %central path (corrector)
  gamma_z = mu ./ g - z - delta_z .* delta_g ./ g;
  gamma_s = mu ./ t - s - delta_s .* delta_t ./ t;
  
  % some more intermediate variables (the hat section)
  hat_nu = nu + g .* gamma_z ./ z;
  hat_tau = tau - t .* gamma_s ./ s;
  
  % the diagonal terms
  %d = z ./ g + s ./ t;
  
  % initialization before the big cholesky
  %for i = 1:n H_x(i,i) = H_diag(i) + d(i);
  %H_y = 0;
  c_x = sigma - z .* hat_nu ./ g - s .* hat_tau ./ t;
  c_y = rho;
  
  % and solve the system [-H_x A'; A H_y] [delta_x, delta_y] = [c_x; c_y]
  %R = chol(H_x);
  %a_r = A / R;
  if (smw == 0) 
    c_r = c_x'/ R;
    H_tmp = a_r * a_r' + H_y;
    delta_y = H_tmp \ (c_y + a_r * c_r');
    delta_x = R \ (a_r' * delta_y - c_r');
  elseif (smw == 1)
    smw_c1 = c_x ./ d;			
    smw_c2 = (c_x - (H' * (smw_inner \ (smw_inner' \ (H * smw_c1)))))./d;
      
    delta_y = (A * smw_a2 + H_y) \ (c_y + A * smw_c2);
    delta_x = smw_a2 * delta_y - smw_c2;
  end;
  %backsubstitution
  
  delta_s = s .* (delta_x - hat_tau) ./ t;
  delta_z = z .* (hat_nu - delta_x) ./ g;
  
  delta_g = g .* (gamma_z - delta_z) ./ z;
  delta_t = t .* (gamma_s - delta_s) ./ s;
  
  %compute the updates
  alfa = - 0.95 / min([delta_g ./ g; delta_t ./ t;
                    delta_z ./ z; delta_s ./ s; -1]);
  
% $$$   mu = (z' * g + s' * t)/(2 * n);
% $$$   mu = mu * ((alfa - 1) / (alfa + 10))^2;
  mu = newmu;
  
  x = x + delta_x * alfa;
  g = g + delta_g * alfa;
  t = t + delta_t * alfa;
  y = y + delta_y * alfa;
  z = z + delta_z * alfa;
  s = s + delta_s * alfa;
  
end

if (optimizer.verbose > 0)			% final report
  report = sprintf('%i \t%e \t%e \t%e \t%e \t%e \t%e', ...
		   counter, primal_infeasibility, dual_infeasibility, ...
		   sigfig, alfa, primal_obj, dual_obj);    
  disp(report);
end

% repackage the results
primal = x;
dual   = y;

if ((sigfig > optimizer.sigfig) & (counter < optimizer.maxiter))
  how    = 'converged';
else					% must have run out of counts
  if ((primal_infeasibility > 10e5) & (dual_infeasibility > 10e5))
    how    = 'primal and dual infeasible';
  elseif (primal_infeasibility > 10e5)
    how    = 'primal infeasible';
  elseif (dual_infeasibility > 10e5)
    how    = 'dual infeasible';
  else					% don't really know
    how    = 'slow convergence, change bound?';
  end;
end



