function whitelist_limo_outputs(direction,filetype)

% routine used to either vectorize limo_outputs (direction is 
% matrix 2 vector, m2v) or reformat a vectorized output into
% the expected limo file (vector 2 matrix, v2m). This is used 
% for differentially privatize data (the pipeline acts on long
% vectors, concatenating results)
%
% FORMAT whitelist_limo_outputs(direction,filetype)
%
% INPUT direction is either 'm2v' to vectorize a limo result file
%                 or 'v2m' to reverse the proces
