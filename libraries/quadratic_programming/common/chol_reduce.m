function [ Tk, pivots, diag_residues, maxresiduals ] ... 
    = chol_reduce( data, kernel, tol, max_iter, verbose )

% Usage: 
% 
% [ Tk, pivots, diag_residues, maxresiduals ] ... 
% = chol_reduce( data, kernel, tol, max_iter, verbose )
% 
% Description:
% 
% Find the incomplete Cholesky decomposition of the kernel matrix
% 
% Assume:
%
% Data stored as column vectors (i.e rows = dim of data ) 
% No labels appended to the data
% 
% Parameters:
% 
% data      : 
% kernel    : svlab object
% tol       : algo stops when remaining pivots < tol 
% max_iter  : maximum number of colums in Tk
%
% Return:
% 
% Tk     : K \approx Tk * Tk'
% pivots : Indices on which we pivoted
% diag_residues : Residuals left on the diagonal
% maxresiduals  : Residuals we picked for pivoting
% 
% Authors : S.V.N. Vishwanathan / Alex Smola
%

% For aggressive memory allocation
BLOCKSIZE = 50;

% Begin initialization

if( nargin < 3 )
  
  tol = 1e-3;
  
end

if( nargin < 4 )
  
  max_iter = size( data, 2 );
  
end

if( nargin < 5 )
  
  verbose = false;
  
end

Tk = [];
T = [];
pivots = [];
maxresiduals = [];
padded_veck = [];

counter = 0;

% End initialization

m = size( data, 2 );

% Compute the diagonal of kernel matrix

diag_residues = zeros( m, 1 );

for i = 1:m				
  
  diag_residues( i ) = full( sv_dot( kernel, data( :, i ) ) );
  
end

% Choose first pivot

[ residue, index ] = max( diag_residues );


dot_squarex = sum( data.^2, 1 )';

while ( ( residue > tol ) && ( counter < max_iter ) )
  
  % Aggressively allocate memory and don't depend on Matlab to do
  % it in a brain dead way for you
  
  if( mod( counter, BLOCKSIZE ) == 0 )
    
    Tk = [ Tk, zeros( m, BLOCKSIZE ) ];
    
    T = [ T, zeros( counter, BLOCKSIZE ); ...
	  zeros( BLOCKSIZE, counter ), eye( BLOCKSIZE, BLOCKSIZE )];
    
    padded_veck = [ padded_veck; zeros( BLOCKSIZE, 1 ) ];
    
    pivots = [ pivots; zeros( BLOCKSIZE, 1 ) ];
    
    maxresiduals = [ maxresiduals; zeros( BLOCKSIZE, 1 ) ];
    
  end
  
  veck = full( sv_dot_fast( kernel, data, data( :, index ), dot_squarex ));
  
  if counter == 0
    
    % No need to compute t here
    tau = sqrt( veck( index ) );
    
    % Update T
    T(1, 1) = [tau];
    
    % Compute the update for Tk
    update = ( 1/tau ) * ( veck );
    
  else
    
    padded_veck( 1:counter ) = veck( pivots( 1:counter ) );
    
    % First compute t
    t = ( padded_veck'/T )';
    
    % Now compute tau
    tau = sqrt( veck( index ) - t'*t );
    
    % Update T
    T( 1:counter, counter+1 ) = t( 1:counter );
    T( counter + 1, counter + 1 ) = tau;
    
    % Compute the update for Tk
    update = ( 1/tau ) * ( veck - Tk * t );
    
  end
  
  % Update Tk
  Tk( :, counter + 1 ) = update;
  
  % Update diagonal residuals
  diag_residues = diag_residues - update.^2;			
  
  % Update pivots
  pivots( counter + 1 )  = index;
  
  % Monitor residuals
  maxresiduals( counter + 1 ) = residue; 
  
  % Choose next candidate
  [ residue, index ] = max( diag_residues );

  % Update counter
  counter = counter + 1;
  
  % Report progress to the user
  if( mod( counter, 50 ) == 0 && ( verbose == true ) )
    
    fprintf( 1, '%d   %f\n', counter, residue );
    
  end
  
end

% Throw away extra columns which we might have added
Tk = Tk(:, 1:counter); 

pivots = pivots( 1:counter );

maxresiduals = maxresiduals( 1:counter );