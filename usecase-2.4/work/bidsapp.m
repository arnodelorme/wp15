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
%   bidsapp -h 
%   bidsapp -v
%   bidsapp InputDataset OutputLocation AnalysisLevel [options]
%
% -h,--help       shows this help and exit
% -v,--version    shows the eeglab and limo versions and exit
% The InputDataset must be a directory containing a BIDS dataset.
% The OutputLocation must be a directory that will contain the result.
% The AnalysisLevel must be 'participant' or 'group'.
%
% Supported options
%         'TaskLabel',{'name1,'name2'} is a cell-array with TaskLabel name to analyze
%                (by default it is {'ERN','MMN','N170','N2pc','N400','P3'})
%         'SubjectLabel',{'sub-001','sub-002','sub-003','sub-005','sub-006','sub-009'}
%                  is a cell-array with subject identifiers to run for a subset of subjects only
%                  (at least 6 subjects to run the paired t-test)
%          high_pass - filter value (0.5Hz default) in pop_clean_rawdataset as [value-0.25 value+0.25]
%          ICAname - name of the algorithm to use in runica (picard as default)
%          epoch_window - start and end time points in seconds of each epoch
%                         a 1*2 vector or 6*2 matrix for each of the ERP
%                         Core TaskLabels {'ERN','MMN','N170','N2pc','N400','P3'}
%                         defaults follow the ERP Core descriptor
%          baseline_window - start and end time points in seconds for baseline correction
%                         a 1*2 vector or 6*2 matrix for each of the ERP
%                         Core TaskLabels {'ERN','MMN','N170','N2pc','N400','P3'}
%          analysis_window - start and end time points in seconds for 1st AnalysisLevel analysis
%                         a 1*2 vector or 6*2 matrix for each of the ERP
%                         Core TaskLabels {'ERN','MMN','N170','N2pc','N400','P3'}
%          estimation - the LIMO procedure to estimate the models' parameters
%                       'WLS' (default) or 'OLS'
%          nboot - the number of boostrap to execute for the 2nd level
%                  analysis (default 1000, set to 0 for none)
%          tfce - 1 (default) or 0 to additionally compute tfce for the 2nd
%                 level analysis
%
% See also INPUTPARSER, ARGUMENTS, FT_GETOPT

% Copyright (C) 2024, Robert Oostenveld

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parse the command-line options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(nargin)
  error('not enough input arguments, use bidsapp -h for help on inputs')
end

% iterate through varargin
if nargin == 1
    % basic help/version request
    if any(strcmpi(varargin,{'-h','--help'}))
        help bidsapp
        return
    elseif any(strcmpi(varargin,{'-v','--version'}))
        fprintf('EEGLAB version %s\n',eeg_getversion())
        limo_eeg(2)
        return
    else
        error('expected argument -h or -v')
    end
else % at least 3 imputs
    if nargin < 3 
        error('at least 3 arguments in needed, InputDataset, OutputLocation, AnalysisLevel')
    else
        InputDataset   = varargin{1};
        OutputLocation = varargin{2};
        AnalysisLevel  = varargin{3}; % participant or group
        % everything else is now key-value pairs
        isoption = false(numel(varargin)/2);
        for i=1:2:numel(varargin)
            if contains(varargin{opt},'TaskLabel','IgnoreCase',true)
                options.TaskLabel = varargin{i+1};
                isoption(i) = true;
            elseif contains(varargin{opt},'SubjectLabel','IgnoreCase',true)
               options.SubjectLabel = varargin{i+1};
               isoption(i) = true;
            elseif contains(varargin{opt},'high_pass','IgnoreCase',true)
                options.high_pass = varargin{i+1};
               isoption(i) = true;
            elseif contains(varargin{opt},'ICAname','IgnoreCase',true)
                options.ICAname = varargin{i+1};
               isoption(i) = true;
            elseif contains(varargin{opt},'epoch_window','IgnoreCase',true)
                options.epoch_window = varargin{i+1};
               isoption(i) = true;
            elseif contains(varargin{opt},'baseline_window','IgnoreCase',true)
                options.baseline_window = varargin{i+1};
               isoption(i) = true;
            elseif contains(varargin{opt},'analysis_window','IgnoreCase',true)
                options.analysis_window = varargin{i+1};
               isoption(i) = true;
            elseif contains(varargin{opt},'estimation','IgnoreCase',true)
                options.estimation = varargin{i+1};
               isoption(i) = true;
            elseif contains(varargin{opt},'nboot','IgnoreCase',true)
                options.nboot = varargin{i+1};
               isoption(i) = true;
            elseif contains(varargin{opt},'tfce','IgnoreCase',true)
               options.tfce = varargin{i+1};
               isoption(i) = true;
            end
        end % for inputs/options
    end % nargin 3 and above
end

% check arguments data type  
if ~isa(InputDataset, 'char') && ~isa(InputDataset, 'string')
  error('incorrect specification of InputDataset');
elseif ~isa(OutputLocation, 'char') && ~isa(OutputLocation, 'string')
  error('incorrect specification of OutputLocation');
elseif ~isa(AnalysisLevel, 'char') && ~isa(AnalysisLevel, 'string')
  error('incorrect specification of AnalysisLevel');
end

if ~strcmpi(level, 'participant') && ~strcmpi(level, 'group')
  error('AnalysisLevel should either be ''participant'' or ''group''');
end

if ~exist(InputDataset, 'dir')
  error('input directory does not exist');
end

if ~exist(OutputLocation, 'dir')
  warning('creating output directory');
  [success, message] = mkdir(OutputLocation);
  if ~success
    error(message);
  end
end

isoption(2:2:end) = true;
if ~all(isoption)
  % find and show the first incorrect option
  incorrect = find(isoption==false, 1, 'first');
  error('unsupported option ''%s''', varargin{incorrect});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% call the actual code to execute the pipeline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ERP_Core_WB(InputDataset,OutputLocation,AnalysisLevel,options)
