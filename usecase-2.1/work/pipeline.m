function pipeline(options)

% PIPELINE to compute some averages over participants using the data
% in the participants.tsv file from a BIDS dataset.
%
% Use as
%   pipeline(options)
% where the options input argument is a structure with the following fields
%   options.inputdir  = string
%   options.outputdir = string
%   options.verbose   = boolean
%   options.start_idx = number, can be empty
%   options.stop_idx  = number, can be empty
%
% See also BIDSAPP

% Copyright (C) 2024, Robert Oostenveld

if options.version
  disp('version = unknown')
  return
end

if options.verbose
  fprintf('options =\n');
  disp(options);
end

if strcmp(options.level, 'participant')
  % there is nothing to do at the participant level
  return
end

inputfile  = fullfile(options.inputdir, 'participants.tsv');
outputfile = fullfile(options.outputdir, 'results.tsv');

participants = readtable(inputfile, 'FileType', 'text', 'Delimiter', '\t', 'VariableNamingRule', 'preserve');

if options.verbose
  fprintf('data contains %d participants\n', size(participants, 1));
end

% select participants
if ~isempty(options.stop_idx)
  participants = participants(1:options.stop_idx,:);
end
if ~isempty(options.start_idx)
  participants = participants(options.start_idx:end,:);
end

if options.verbose
  fprintf('selected %d participants\n', size(participants, 1));
end

averagedage  = mean(participants.age, 'omitnan');
averagedHeight = mean(participants.Height, 'omitnan');
averagedWeight = mean(participants.Weight, 'omitnan');

% put the results in a table
result = table(averagedage, averagedHeight, averagedWeight);

if options.verbose
  disp(result);
end

writetable(result, outputfile, 'FileType', 'text', 'Delimiter', '\t', 'WriteVariableNames', false);
