function bidsapp(varargin)

% BIDSAPP is a wrapper for a MATLAB-based BIDS application.
%
% It is implemented for the MATLAB-based pipelines in SIESTA and follows
% https://doi.org/10.1371/journal.pcbi.1005209. Each MATLAB-based pipeline should
% have its own copy of this function, adapted to the specific requirements. The main
% task of this wrapper is to parse the input arguments consistently and then to call
% the actual code that implements the participant- or group-level analysis.
%
% Use as
%   bidsapp [options] inputdir outputdir level
%
% The inputdir must be a directory containing a BIDS dataset.
% The outputdir must be a directory that will contain the result.
% The level must be 'participant' or 'group'.
%
% Supported options
%   -h,--help         show this help and exit
%   -v,--verbose      show more verbose information for debugging
%   --version         show the version and exit
%   --start-idx <num> index of the first participant to include, one-offset
%   --stop-idx <num>  index of the last participant to include, one-offset
%
% See also INPUTPARSER, ARGUMENTS, FT_GETOPT

% Copyright (C) 2024, Robert Oostenveld

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parse the command-line options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the last three arguments must be inputdir, outputdir and level
if nargin<3
  error('not enough input arguments')
end

inputdir  = varargin{end-2};
outputdir = varargin{end-1};
level     = varargin{end}; % participant or group

% the last three arguments must be strings
if ~isa(inputdir, 'char') && ~isa(inputdir, 'string')
  error('incorrect specification of inputdir');
elseif ~isa(outputdir, 'char') && ~isa(outputdir, 'string')
  error('incorrect specification of inputdir');
elseif ~isa(level, 'char') && ~isa(level, 'string')
  error('incorrect specification of inputdir');
end

if ~strcmpi(level, 'participant') && ~strcmpi(level, 'group')
  error('level should either be ''participant'' or ''group''');
end

if ~exist(inputdir, 'dir')
  error('input directory does not exist');
end

if ~exist(outputdir, 'dir')
  warning('creating output directory');
  [success, message] = mkdir(outputdir);
  if ~success
    error(message);
  end
end

% the last three arguments have been dealt with
varargin = varargin(1:end-3);

% store all options in a structure
options.inputdir  = inputdir;
options.outputdir = outputdir;
options.level     = level;

% optional arguments can be "flags" that come by themselves, like '-h' or '--help'
% optional arguments can also have values, like '--species {human,rat}'

% flags are represented as true/false
options.version    = false;
options.help       = false;
options.verbose    = false;
% other options each have their own value, either a string or a number
options.start_idx  = [];
options.stop_idx   = [];

% deal with the flags
isflag = false(size(varargin));
for i=1:numel(varargin)
  switch varargin{i}
    case {'--version'}
      options.version = true;
      isflag(i) = true;
    case {'-h', '--help'}
      options.help = true;
      isflag(i) = true;
    case {'-v', '--verbose'}
      options.verbose = true;
      isflag(i) = true;
  end % switch
end % for

% deal with the remaining optional arguments
varargin = varargin(~isflag);
clear isflag

isoption = false(size(varargin));
for i=1:2:numel(varargin)
  switch varargin{i}
    case {'--start-idx'}
      options.start_idx = str2double(varargin{i+1});
      isoption(i) = true;
    case {'--stop-idx'}
      options.stop_idx = str2double(varargin{i+1});
      isoption(i) = true;
  end % switch
end % for

isoption(2:2:end) = true;
if ~all(isoption)
  % find and show the first incorrect option
  incorrect = find(isoption==false, 1, 'first');
  error('unsupported option ''%s''', varargin{incorrect});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% call the actual code to execute the pipeline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% we want the help of the BIDS app to be shown, not the pipeline code
if options.help
  help(mfilename);
  return
end

participants_tsv = fullfile(options.inputdir, 'participants.tsv');
participants = readtable(participants_tsv, 'FileType','text', 'Delimiter', '\t');

if ~isfield(options, 'start_idx') || isempty(options.start_idx)
  options.start_idx = 1;
end
if ~isfield(options, 'stop_idx') || isempty(options.stop_idx)
  options.stop_idx = size(participants,1);
end

if options.start_idx<1 || options.start_idx>size(participants, 1)
  error('invalid start_idx');
end
if options.stop_idx<1 || options.stop_idx>size(participants, 1)
  error('invalid stop_idx');
end
if options.stop_idx<options.start_idx
  error('invalid start_idx or stop_idx');
end

% select the desired participants
fprintf('selected %d out of the %d participants\n', options.stop_idx-options.start_idx+1, size(participants, 1));
participants = participants(options.start_idx:options.stop_idx,:);

% FIXME, the ERP_Core_WB should be updated to allow for only participant/group level analysis
warning('ignoring the level "%s" and running all analyses', options.level);

% ensure that dependencies are installed
ERP_Core_WB_install;

% call the analysis pipeline specific MATLAB code, using the options structure that was parsed above.
ERP_Core_WB(options.inputdir, options.outputdir, 'sublist', participants.participant_id);
