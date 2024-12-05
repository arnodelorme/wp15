function ERP_Core_WB(source, destination, varargin)
% ERP Core - whole brain analysis
% Matlab function calling the EEGLAB toolbox and LIMO MEEG (master from
% Github)
% 
% FORMAT ERP_Core_WB(source, destination, [sublist])
%
% INPUTS  - source is the folder where the ERPCore data are located
%         - destination (optional) is the folder where all results are saved
%           if not specified, results are in source/derivatives
%         - options as key-value pairs (for debugging purposes)
%         'tasklist',{'ERN,'MMN'} is a cell-array with task name to analyze
%                (by default it is {'ERN','MMN','N170','N2pc','N400','P3'}) 
%         'sublist',{'sub-001','sub-002','sub-003','sub-005','sub-006','sub-009'}
%                  is a cell-array with subject identifiers to run for a subset of subjects only 
%                  (at least 6 subjects to run the paired t-test)
%          
% OUTPUT the function does not return any variable, all results are saved
%        on drive
%
% Usage example: 
%         source = '/indirect/staff/cyrilpernet/ERP_CORE_BIDS_Raw_Files'
%         destination = fullfile(source,'derivatives'); mkdir(destination);
%         sublist = {'sub-001','sub-002','sub-003','sub-010','sub-011','sub-012','sub-030','sub-031'};
%         ERP_Core_WB(source, destination, 'task',{'ERN'},'sublist',sublist)
%
% Cyril Pernet, during the spring of 2024 
% + various updates by Marcel and Jan-Mathijs
%
% This code is shared under the CC0 license
%
% Copyright (C) 2024, SIESTA workpackage 15 team

if nargin<2
  error('required arguments are missing')
end

% arguments that could be made optional epoch_window, baseline_window, analysis_window, ICAname

% start eeglab and check plugins
rng('default');
ALLEEG = eeglab('nogui'); %#ok<NASGU>

if ~exist('pop_importbids','file')
    plugin_askinstall('bids-matlab-tools', 'bids_export', true);
end
if ~exist('pop_zapline_plus','file')
    plugin_askinstall('zapline-plus','pop_zapline_plus',true);
end
if ~exist('pop_loadbv','file')
    plugin_askinstall('bva-io','pop_loadbv',true);
end
if ~exist('eegplugin_firfilt','file')
    plugin_askinstall('Firfilt', 'firfilt', true);
end
if ~exist('pop_clean_rawdata','file')
    plugin_askinstall('clean_rawdata', 'eegplugin_clean_rawdata', true);
end
if ~exist('picard','file')
    plugin_askinstall('PICARD', 'picard', true);
end
if ~exist('pop_iclabel','file')
    pplugin_askinstall('IClabel', 'eegplugin_iclabel', true);
end
if ~exist('ft_prepare_neighbours','file')
    plugin_askinstall('Fieldtrip-lite', 'ft_defaults', true);
end

if ~exist('pop_importbids.m','file') || ...
        ~exist('pop_zapline_plus.m','file') || ...
        ~exist('pop_loadbv.m','file') || ...
        ~exist('eegplugin_firfilt.m','file') || ...
        ~exist('pop_clean_rawdata.m','file') || ...
        ~exist('picard.m','file') || ...
        ~exist('pop_iclabel.m','file') || ...
        ~exist('ft_prepare_neighbours.m','file') || ...
        ~exist('limo_eeg.m','file')
    error('1 or more of the necessary plugins is not found');
end

% prevent Unrecognized function or variable 'eeglab2fieldtrip'
ftpath = fileparts(which('ft_defaults'));
addpath(fullfile(ftpath, 'external', 'eeglab'))

% check options
if nargin == 1
    destination = fullfile(source,'derivatives');
    if ~exist('destination','dir')
        mkdir(destination)
    end
end

if nargin>2
    for opt =1:length(varargin)
        if contains(varargin{opt},'task','IgnoreCase',true)
            task = varargin{opt+1};
        elseif contains(varargin{opt},'sublist','IgnoreCase',true)
            sublist = varargin{opt+1};
        end
    end
end

if ~exist('sublist','var')
    sublist = {};
end

if ~exist('task','var')
    task = {'MMN','N170','N2pc','N400','P3','ERN'};
end

all_sub = dir(fullfile(source,'sub-*'));
if isempty(sublist)
  sublist = 1:numel(all_sub);
else
  sublist = find(ismember({all_sub.name}', sublist))';  
end

% edit participants.tsv checking the same subjects are present
participants = readtable(fullfile(source,'participants.tsv'), 'FileType', 'text', ...
    'Delimiter', '\t', 'TreatAsEmpty', {'N/A','n/a'}); N = size(participants,1);
for p=length(participants.participant_id):-1:1
    name_match(:,p) = arrayfun(@(x) strcmpi(x.name,participants.participant_id{p}),all_sub);
end
if ~isempty(find(sum(name_match,1)==0))
    participants(find(sum(name_match,1)==0),:) = [];
    warning('mismatch between files and participants.tsv -%g subject(s)',N-size(participants,1))
    writetable(participants, fullfile(source,'participants.tsv'), 'FileType', 'text', 'Delimiter', '\t');    
end

% edit events.tsv files 
% should we correct epoching +26ms for stimuli from events.tsv files? as opposed to eeg channels

% edit events.tsv files for meaningful epoching for N170
if any(contains(task,'N170'))
    for sub = 1:size(all_sub,1)
        root   = fullfile(all_sub(sub).folder,[all_sub(sub).name filesep 'ses-N170' filesep 'eeg']);
        file   = [all_sub(sub).name,'_ses-N170_task-N170_events.tsv'];
        events = readtable(fullfile(root,file), 'FileType', 'text', ...
            'Delimiter', '\t', 'TreatAsEmpty', {'N/A','n/a'});
        for s = size(events,1):-1:1
            if events.value(s) <= 40
                event{s} = 'faces';
            elseif (events.value(s) >= 41) && (events.value(s) < 101)
                event{s} = 'cars';
            elseif (events.value(s) >= 101) && (events.value(s) < 141)
                event{s} = 'scrambled_faces';
            else
                event{s} = 'scrambled_cars';
            end
        end
        t = table(events.onset,events.duration,events.sample,events.trial_type,event',events.value,...
            'VariableNames',{'onset', 'duration', 'sample', 'trial_type', 'event', 'value'});
        writetable(t, fullfile(root,file), 'FileType', 'text', 'Delimiter', '\t');
        clear event events t
    end
end

% define task and task parameters
% ERN
epoch_window(1,:)      = [-0.6 0.4];  % in sec for pop_epoch
baseline_window(1,:)   = [-400 -200]; % std_precomp
analysis_window(1,:)   = [-200 400];  % pop_limo
% MMN
epoch_window(2,:)      = [-0.2 0.8];
baseline_window(2,:)   = [-200 0];
analysis_window(2,:)   = [-200 600];
% all others
epoch_window(3:6,:)    = repmat([-0.2 0.8],4,1);
baseline_window(3:6,:) = repmat([-200 0],4,1);
analysis_window(3:6,:) = repmat([-200 600],4,1);

% loop by task
for t = 1:length(task)

    %% IMPORT
    outdir = fullfile(destination,['task-' task{t}]);
    if ~exist(outdir,'dir')
        mkdir(outdir)
    end

    if strcmpi(task{t},'N170')
        [STUDY, ALLEEG] = pop_importbids(source, 'bidsevent','on','bidschanloc','on', ...
        'bidstask',task{t},'eventtype', 'event', 'outputdir' ,outdir, 'studyName',task{t}, 'subjects', sublist);
    else
        [STUDY, ALLEEG] = pop_importbids(source, 'bidsevent','on','bidschanloc','on', ...
        'bidstask',task{t},'eventtype', 'value', 'outputdir' ,outdir, 'studyName',task{t}, 'subjects', sublist);
    end
    ALLEEG = pop_select( ALLEEG, 'nochannel',{'HEOG_left','HEOG_right','VEOG_lower'});
    STUDY = pop_statparams(STUDY, 'default');
    [~,~,AvgChanlocs] = std_prepare_neighbors(STUDY, ALLEEG, 'force', 'on');
    % remove connections 8-9/3 ie P7-P9/F7, 26-27/19 ie P8-P10/F8 and 7-25/22 ie P3-P4/Cz
    pairs(1,:) = [3 8];   pairs(2,:) = [3 9];
    pairs(3,:) = [19 26]; pairs(4,:) = [19 27];
    pairs(5,:) = [7 22];  pairs(6,:) = [25 22];
    for p=1:6
        AvgChanlocs.channeighbstructmat(pairs(p,1),pairs(p,2)) = 0;
        AvgChanlocs.channeighbstructmat(pairs(p,2),pairs(p,1)) = 0;
    end
    save(fullfile(outdir, 'AvgChanlocs.mat'),'AvgChanlocs')

    %% Pre-processing
    % for each subject, downsample, clean 50Hz, remove bad channels,
    % interpolate, re-reference to the average, run ICA to remove
    % eye and muscle artefacts, delete bad segments

    EEG = ALLEEG;
    for s=1:size(ALLEEG,2)
        try
            % downsample
            if EEG(s).srate ~= 250
                EEG(s) = pop_resample(EEG(s), 250);
            end
            % line freq removal
            EEG(s) = pop_zapline_plus(EEG(s),'noisefreqs','line',...
                'coarseFreqDetectPowerDiff',4,'chunkLength',30,...
                'adaptiveNremove',1,'fixedNremove',1,'plotResults',0);
            % remove bad channels
            EEG(s) = pop_clean_rawdata(EEG(s),'FlatlineCriterion',5,'ChannelCriterion',0.8,...
                'LineNoiseCriterion',4,'Highpass',[0.25 0.75] ,...
                'BurstCriterion','off','WindowCriterion','off','BurstRejection','off',...
                'Distance','Euclidian','WindowCriterionTolerances','off' );
            % interpolate missing channels and reference
            [~,idx] = setdiff({AvgChanlocs.expected_chanlocs.labels},{EEG(s).chanlocs.labels});
            if ~isempty(idx)
                EEG(s) = pop_interp(EEG(s), AvgChanlocs.expected_chanlocs(idx), 'sphericalKang');
            end

            % ICA cleaning
            EEG(s) = pop_runica(EEG(s), 'icatype','picard','maxiter',500,'mode','standard','concatcond','on','options',{'pca',EEG(s).nbchan-1});
            EEG(s) = pop_iclabel(EEG(s), 'default');
            EEG(s) = pop_icflag(EEG(s),[NaN NaN;0.8 1;0.8 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
            EEG(s) = pop_subcomp(EEG(s),[],0);

            % clear data using ASR - just the bad segment
            EEG(s) = pop_clean_rawdata(EEG(s),'FlatlineCriterion','off','ChannelCriterion','off',...
                'LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,...
                'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian',...
                'WindowCriterionTolerances',[-Inf 7] );

            % re-reference
            EEG(s) = pop_reref(EEG(s),[],'interpchan','off');
            EEG(s) = pop_saveset(EEG(s),'savemode','resave');
        catch pipe_error
            error_report{s} = pipe_error.message; %#ok<AGROW>
        end
    end

    % Save study
    if exist('error_report','var')
        mask = cellfun(@(x) ~isempty(x), error_report); % which subject/session
        if all(mask)
          error('there has been a processing issue with all included datasets, cannot proceed');
        else
          STUDY = std_rmdat(STUDY, EEG, 'datinds', find(mask));
          EEG(mask) = [];
        end
    end
    ALLEEG = EEG;

    %% Statistics
    % Extract data epochs (windowing as per ERP core github)
    if strcmpi(task{t},'ERN')
        EEG = pop_epoch(ALLEEG,{'111','112','121','122','211','212','221','222'},...
            epoch_window(t,:) ,'epochinfo','yes');
    elseif strcmpi(task{t},'MMN')
        EEG = pop_epoch(ALLEEG,{'80','70'},...
            epoch_window(t,:) ,'epochinfo','yes');
    elseif strcmpi(task{t},'N170')
        EEG = pop_epoch(ALLEEG,{'faces','cars','scrambled_faces','scrambled_cars'},...
            epoch_window(t,:) ,'epochinfo','yes');
    elseif strcmpi(task{t},'N2pc')
        EEG = pop_epoch(ALLEEG,{'111','112','121','122','211','212','221','222'},...
            epoch_window(t,:) ,'epochinfo','yes');        
    elseif strcmpi(task{t},'N400')
        EEG = pop_epoch(ALLEEG,{'111','112','121','122','211','212','221','222'},...
            epoch_window(t,:) ,'epochinfo','yes');        
    elseif strcmpi(task{t},'P3')
        EEG = pop_epoch(ALLEEG,{'11','12','13','14','15','21','22','23','24','25',...
            '31','32','33','34','35','41','42','43','44','45','51','52','53','54','55'},...
            epoch_window(t,:) ,'epochinfo','yes');         
    end

    EEG    = eeg_checkset(EEG);
    EEG    = pop_saveset(EEG, 'savemode', 'resave');
    if any(strcmpi(task{t},{'ERN','N170'}))
        [STUDY, EEG] = std_editset(STUDY, EEG, 'commands',{{'remove',4}},'updatedat','on','rmclust','on');
    elseif any(strcmpi(task{t},{'P3'}))
        [STUDY, EEG] = std_editset(STUDY, EEG, 'commands',{{'remove',4},{'remove',35}},'updatedat','on','rmclust','on');
    end

    % Create study design
    STUDY  = std_checkset(STUDY, EEG);
    STUDY  = std_makedesign(STUDY, EEG, 1, 'name',task{t}, ...
        'delfiles','off','defaultdesign','off','variable1','type','values1',{});

    % Precompute ERP measures
    [STUDY, EEG] = std_precomp(STUDY, EEG, {}, 'savetrials','on','interp','on','recompute','on',...
        'erp','on','erpparams', {'rmbase' baseline_window(t,:)}, ...
        'spec','off','ersp','off','itc','off');

    % 1st level analysis
 
    [STUDY, ~, files] = pop_limo(STUDY, EEG, 'method','WLS','measure','daterp',...
        'timelim',analysis_window(t,:),'erase','on','splitreg','off','interaction','off');
    if isempty(STUDY.filepath) % this seems to happen no unknown reason
        STUDY.filepath = outdir;
    end

    if strcmpi(task{t},'ERN')
        % ERN and CRN components are epoched for correct and errors
        % irrespective of the stimulus - make contrasts but check
        % designs, some subject are  missing 'errors'
        % "111": "Response - left, compatible flankers, target left",
        % "112": "Response - left, compatible flankers, target right",
        % "121": "Response - left, incompatible flankers, target left",
        % "122": "Response - left, incompatible flankers, target right",
        % "211": "Response - right, compatible flankers, target left",
        % "212": "Response - right, compatible flankers, target right",
        % "221": "Response - right, incompatible flankers, target left",
        % "222": "Response - right, incompatible flankers, target right"
        ERN = [0 1 0 1 1 0 1 0];
        CRN = [1 0 1 0 0 1 0 1];
        [~,~,LFiles] = limo_get_files([],[],[],...
            fullfile(files.LIMO,'LIMO_files_ERN_ERN_GLM_Channels_Time_WLS.txt'));
        [~,R,BFiles] = limo_get_files([],[],[],...
            fullfile(files.LIMO,'Beta_files_ERN_ERN_GLM_Channels_Time_WLS.txt'));

        for s=1:length(LFiles)
            index   = strfind(LFiles{s},'sub-'); % get subject start
            name    = R{s}(index:index+6); % name
            s_value = find(arrayfun(@(x) strcmpi(x.subject,name),STUDY.limo.subjects)); % ensure match
            cond    = unique(STUDY.limo.subjects(s_value).cat_file);
            limo_contrast(fullfile(R{s},'Yr.mat'), BFiles{s}, LFiles{s}, 'T', 1, ERN(cond));
            limo_contrast(fullfile(R{s},'Yr.mat'), BFiles{s}, LFiles{s}, 'T', 1, CRN(cond));
            con1_files{s,:} = fullfile(R{s},'con_1.mat');
            con2_files{s,:} = fullfile(R{s},'con_2.mat');
        end

        writecell(con1_files,fullfile(STUDY.filepath,'con1_files.txt'))
        writecell(con2_files,fullfile(STUDY.filepath,'con2_files.txt'))

        % 2nd level
        for c = 1:3
            if c == 1
                mkdir(fullfile(STUDY.filepath,['2nd_level' filesep 'ERN']));
                cd(fullfile(STUDY.filepath,['2nd_level' filesep 'ERN']));
                limo_random_select('one sample t-test',AvgChanlocs,...
                    'LIMOfiles',con1_files,'parameter',1, 'analysis_type',...
                    'Full scalp analysis', 'type','Channels','nboot',1000,'tfce',1);
                limo_get_effect_size('one_sample_ttest_parameter_1.mat')
                % mean contrast values
                limo_central_tendency_and_ci(fullfile(STUDY.filepath,'con1_files.txt'),...
                    1, AvgChanlocs.expected_chanlocs, 'mean', 'Trimmed mean', 21,'FCz_ERP')
            elseif c == 2
                mkdir(fullfile(STUDY.filepath,['2nd_level' filesep 'CRN']));
                cd(fullfile(STUDY.filepath,['2nd_level' filesep 'CRN']));
                limo_random_select('one sample t-test',AvgChanlocs,...
                    'LIMOfiles',con2_files,'parameter',1, 'analysis_type',...
                    'Full scalp analysis', 'type','Channels','nboot',1000,'tfce',1);
                limo_get_effect_size('one_sample_ttest_parameter_1.mat')
                % mean contrast values
                limo_central_tendency_and_ci(fullfile(STUDY.filepath,'con2_files.txt'),...
                    1, AvgChanlocs.expected_chanlocs, 'mean', 'Trimmed mean', 21,'FCz_ERP')
            else
                mkdir(fullfile(STUDY.filepath,['2nd_level' filesep 'Difference_wave']));
                cd(fullfile(STUDY.filepath,['2nd_level' filesep 'Difference_wave']));
                for N=size(con1_files,1):-1:1
                    data{1,N} = con1_files{N};
                    data{2,N} = con2_files{N};
                end
                limo_random_select('paired t-test',AvgChanlocs,...
                    'LIMOfiles',data, 'analysis_type',...
                    'Full scalp analysis', 'type','Channels','nboot',1000,'tfce',1);
                limo_get_effect_size('paired_samples_ttest_parameter_1_2.mat')
                % ERPs (use limo_add_plots to visualize)
                limo_central_tendency_and_ci(fullfile(files.LIMO, 'LIMO_files_ERN_ERN_GLM_Channels_Time_WLS.txt'), ...
                    find(ERN), AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_errors')
                limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_ERN_ERN_GLM_Channels_Time_WLS.txt'), ...
                    find(CRN), AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_correct')
                Diff = limo_plot_difference('ERPs_errors_single_subjects_Weighted mean.mat',...
                    'ERPs_correct_single_subjects_Weighted mean.mat',...
                    'type','paired','fig',0,'name','ERP_diff');
                save('ERP_difference','Diff')
            end
        end
    elseif strcmpi(task{t},'MMN')

        % 2nd level
        mkdir(fullfile(STUDY.filepath,['2nd_level' filesep 'MMN']));
        cd(fullfile(STUDY.filepath,['2nd_level' filesep 'MMN']));
        limo_random_select('paired t-test',AvgChanlocs,...
            'LIMOfiles',fullfile(files.LIMO,'Beta_files_MMN_MMN_GLM_Channels_Time_WLS.txt'), ...
            'parameter',[1 2], 'analysis_type',...
            'Full scalp analysis', 'type','Channels','nboot',1000,'tfce',1);
        limo_get_effect_size('paired_samples_ttest_parameter_1_2.mat')
        % ERPs (use limo_add_plots to visualize)
        limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_MMN_MMN_GLM_Channels_Time_WLS.txt'), ...
            1, AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_deviant')
        limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_MMN_MMN_GLM_Channels_Time_WLS.txt'), ...
            2, AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_standard')
        Diff = limo_plot_difference('ERPs_deviant_single_subjects_Weighted mean.mat',...
            'ERPs_standard_single_subjects_Weighted mean.mat',...
            'type','paired','fig',0,'name','ERP_MMN');
        save('ERP_difference','Diff')

    elseif strcmpi(task{t},'N170')
        % there are two analyses
        % faces vs cars
        % faces-scrambled vs cars-scrambled
        CarDiff  = [1 0 -1 0];
        FaceDiff = [0 1 0 -1];
        [~,~,LFiles] = limo_get_files([],[],[],...
            fullfile(files.LIMO,'LIMO_files_N170_N170_GLM_Channels_Time_WLS.txt'));
        [~,R,BFiles] = limo_get_files([],[],[],...
            fullfile(files.LIMO,'Beta_files_N170_N170_GLM_Channels_Time_WLS.txt'));

        for s=1:length(LFiles)
            limo_contrast(fullfile(R{s},'Yr.mat'), BFiles{s}, LFiles{s}, 'T', 1, CarDiff);
            limo_contrast(fullfile(R{s},'Yr.mat'), BFiles{s}, LFiles{s}, 'T', 1, FaceDiff);
            con1_files{s,:} = fullfile(R{s},'con_1.mat');
            con2_files{s,:} = fullfile(R{s},'con_2.mat');
        end

        writecell(con1_files,fullfile(STUDY.filepath,'con1_files.txt'))
        writecell(con2_files,fullfile(STUDY.filepath,'con2_files.txt'))

        mkdir(fullfile(STUDY.filepath,['2nd_level' filesep 'Cars_vs_Faces']));
        cd(fullfile(STUDY.filepath,['2nd_level' filesep 'Cars_vs_Faces']));
        limo_random_select('paired t-test',AvgChanlocs,...
            'LIMOfiles',fullfile(files.LIMO,'Beta_files_N170_N170_GLM_Channels_Time_WLS.txt'), ...
            'parameter',[2 1], 'analysis_type',...
            'Full scalp analysis', 'type','Channels','nboot',1000,'tfce',1);
        limo_get_effect_size('paired_samples_ttest_parameter_2_1.mat')
        % ERPs (use limo_add_plots to visualize)
        limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_N170_N170_GLM_Channels_Time_WLS.txt'), ...
            1, AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_Cars')
        limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_N170_N170_GLM_Channels_Time_WLS.txt'), ...
            2, AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_Faces')
        Diff = limo_plot_difference('ERPs_Faces_single_subjects_Weighted mean.mat',...
            'ERPs_Cars_single_subjects_Weighted mean.mat',...
            'type','paired','fig',0,'name','ERP_Difference');
        save('ERP_difference','Diff')

        mkdir(fullfile(STUDY.filepath,['2nd_level' filesep 'Cars_vs_Faces_controlled']));
        cd(fullfile(STUDY.filepath,['2nd_level' filesep 'Cars_vs_Faces_controlled']));
        for N=size(con1_files,1):-1:1
            data{1,N} = con1_files{N};
            data{2,N} = con2_files{N};
        end
        limo_random_select('paired t-test',AvgChanlocs,...
            'LIMOfiles',data, 'analysis_type',...
            'Full scalp analysis', 'type','Channels','nboot',1000,'tfce',1);
        limo_get_effect_size('paired_samples_ttest_parameter_1_2.mat')
        % Param avg (use limo_add_plots to visualize)
        % we can also do double diff ERP if needed (do as above twice)
        limo_central_tendency_and_ci(fullfile(STUDY.filepath,'con1_files.txt'),...
            1, AvgChanlocs, 'mean', 'Trimmed mean', [],'Con_Cars')
        limo_central_tendency_and_ci(fullfile(STUDY.filepath,'con2_files.txt'),...
            1, AvgChanlocs, 'mean', 'Trimmed mean', [],'Con_Faces')
        Diff = limo_plot_difference('Con_Faces_single_subjects_mean.mat',...
            'Con_Cars_single_subjects_mean.mat',...
            'type','paired','fig',0,'name','Con_diff');
        save('Parameter_difference','Diff')

        limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_N170_N170_GLM_Channels_Time_WLS.txt'), ...
            1 , AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_Cars')
        limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_N170_N170_GLM_Channels_Time_WLS.txt'), ...
            3, AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_Cars_control')
        set1      = load('ERPs_Cars_single_subjects_Weighted mean.mat');
        set2      = load('ERPs_Cars_control_single_subjects_Weighted mean.mat');
        Data.data = set1.Data.data - set2.Data.data;
        Data.limo = set1.Data.limo;
        save('ERPs_Cars_diff_single_subjects_Weighted mean.mat','Data')
        limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_N170_N170_GLM_Channels_Time_WLS.txt'), ...
            2, AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_Faces')
        limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_N170_N170_GLM_Channels_Time_WLS.txt'), ...
            4, AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_Faces_control')
        set1      = load('ERPs_Faces_single_subjects_Weighted mean.mat');
        set2      = load('ERPs_Faces_control_single_subjects_Weighted mean.mat');
        Data.data = set1.Data.data - set2.Data.data;
        Data.limo = set1.Data.limo;
        save('ERPs_Faces_diff_single_subjects_Weighted mean.mat','Data')
        Diff = limo_plot_difference('ERPs_Faces_diff_single_subjects_Weighted mean.mat',...
            'ERPs_Cars_diff_single_subjects_Weighted mean.mat',...
            'type','paired','fig',0,'name','ERP_Faces_Cars_Difference');
        save('ERP_difference','Diff')

   
    elseif strcmpi(task{t},'N2pc')
       % "111": "Stimulus - target blue, target left, gap at top",
 	     % "112": "Stimulus - target blue, target left, gap at bottom",
       % "121": "Stimulus - target blue, target right, gap at top",
       % "122": "Stimulus - target blue, target right, gap at bottom",
       % "211": "Stimulus - target pink, target left, gap at top",
       % "212": "Stimulus - target pink, target left, gap at bottom",
       % "221": "Stimulus - target pink, target right, gap at top",
       % "222": "Stimulus - target pink, target right, gap at bottom",
       % for the analysis, make contrasts for left-side targets and right-side targets,
       % but collapsed across target color.
       % then comes, contralateral waveforms (i.e., right hemisphere electrode
       % sites for left-side targets averaged with left hemisphere electrode sites for right-side targets)
       % and ipsilateral waveforms (i.e., right hemisphere electrode sites for right-side targets averaged with
       % left hemisphere electrode sites for left-side targets). We then computed a contralateral-minus-
       % ipsilateral difference waveform to isolate the N2pc. Can be redone using limo_LI.
       left  = [1 1 0 0 1 1 0 0];
       right = [0 0 1 1 0 0 1 1];
       [~,~,LFiles] = limo_get_files([],[],[],...
           fullfile(files.LIMO,'LIMO_files_N2pc_N2pc_GLM_Channels_Time_WLS.txt'));
       [~,R,BFiles] = limo_get_files([],[],[],...
           fullfile(files.LIMO,'Beta_files_N2pc_N2pc_GLM_Channels_Time_WLS.txt'));

       for s=1:length(LFiles)
           index   = strfind(LFiles{s},'sub-'); % get subject start
           name    = R{s}(index:index+6); % name
           s_value = find(arrayfun(@(x) strcmpi(x.subject,name),STUDY.limo.subjects)); % ensure match
           cond    = unique(STUDY.limo.subjects(s_value).cat_file);
           limo_contrast(fullfile(R{s},'Yr.mat'), BFiles{s}, LFiles{s}, 'T', 1, left(cond));
           limo_contrast(fullfile(R{s},'Yr.mat'), BFiles{s}, LFiles{s}, 'T', 1, right(cond));
           con1_files{s,:} = fullfile(R{s},'con_1.mat');
           con2_files{s,:} = fullfile(R{s},'con_2.mat');
       end

       writecell(con1_files,fullfile(STUDY.filepath,'con1_files.txt'))
       writecell(con2_files,fullfile(STUDY.filepath,'con2_files.txt'))

       mkdir(fullfile(STUDY.filepath,['2nd_level' filesep 'Ipsi-Contra']));
       cd(fullfile(STUDY.filepath,['2nd_level' filesep 'Ipsi-Contra']));
       labels = arrayfun(@(x) x.labels, AvgChanlocs.expected_chanlocs, 'UniformOutput', false);
       table_channels{1} = labels(1:12)'; table_channels{2} = labels([16 18 19 20 23:30])';
       channels = limo_pair_channels(AvgChanlocs.expected_chanlocs,'pairs',table_channels,'figure','off');
       limo_ipsi_contra(fullfile(STUDY.filepath,'con1_files.txt'),...
           fullfile(STUDY.filepath,'con2_files.txt'),...
           'channellocs',AvgChanlocs,'channelpairs',channels)
       limo_get_effect_size('paired_samples_ttest_parameter_1_2.mat')

       load LIMO.mat
       if ~isfield(LIMO.data,'timevect')
            LIMO.data.timevect = LIMO.data.start:(1/LIMO.data.sampling_rate*1000):LIMO.data.end;
            save(fullfile(LIMO.dir,'LIMO.mat'),'LIMO');
       end
       load('ipsilateral.mat'); TM1  = limo_trimmed_mean(ipsilateral,20,.05);
       load('contralateral.mat'); TM2  = limo_trimmed_mean(contralateral,20,.05);      
       Diff = limo_trimmed_mean(contralateral-ipsilateral,20,.05);
       save('ERP_difference','Diff')

       figure; 
       channel = 10; % use PO7/PO8
       subplot(1,2,1); vect = LIMO.data.timevect; hold on
       plot(vect,squeeze(TM1(channel,:,2)),'LineWidth',2,'Color',[1 0 0]);
       plot(vect,squeeze(TM2(channel,:,2)),'LineWidth',2,'Color',[0 0 1]);
       fillhandle = patch([vect fliplr(vect)], [squeeze(TM1(channel,:,1)) ,fliplr(squeeze(TM1(channel,:,3)))], [1 0 0]);
       set(fillhandle,'EdgeColor',[1 0 0],'FaceAlpha',0.2,'EdgeAlpha',0.8);%set edge color
       fillhandle = patch([vect fliplr(vect)], [squeeze(TM2(channel,:,1)) ,fliplr(squeeze(TM2(channel,:,3)))], [0 0 1]);
       set(fillhandle,'EdgeColor',[0 0 1],'FaceAlpha',0.2,'EdgeAlpha',0.8);%set edge color
       grid on; axis tight; box on; title('Trimmed means - N2Pc for channels PO7/PO8')
       legend({'ipsilateral conditions','contralateral conditions'});        
       subplot(1,2,2); 
       plot(vect,squeeze(Diff(channel,:,2)),'LineWidth',2,'Color',[0 0 1]);
       fillhandle = patch([vect fliplr(vect)], [squeeze(Diff(channel,:,1)) , ...
           fliplr(squeeze(Diff(channel,:,3)))], [1 0 0]);
       set(fillhandle,'EdgeColor',[1 0 0],'FaceAlpha',0.2,'EdgeAlpha',0.8);%set edge color
       grid on; axis tight; box on; title('contra minus ipsi for channels PO7/PO8')
       saveas(gcf, 'PO7_PO8_difference.fig','fig'); close(gcf)
       
    elseif strcmpi(task{t},'N400')
     % 111 prime word, related word pair, list 1
	   % 112 prime word, related word pair, list 2
	   % 121 prime word, unrelated word pair, list 1
	   % 122 prime word, unrelated word pair, list 2
	   % 211 target word, related word pair, list 1
	   % 212 target word, related word pair, list 2
	   % 221 target word, unrelated word pair, list 1
	   % 222 target word, unrelated word pair, list 2
       related   = [0 0 0 0 1 1 0 0];
       unrelated = [0 0 0 0 0 0 1 1];
       [~,~,LFiles] = limo_get_files([],[],[],...
           fullfile(files.LIMO,'LIMO_files_N400_N400_GLM_Channels_Time_WLS.txt'));
       [~,R,BFiles] = limo_get_files([],[],[],...
            fullfile(files.LIMO,'Beta_files_N400_N400_GLM_Channels_Time_WLS.txt'));

        for s=1:length(LFiles)
            index   = strfind(LFiles{s},'sub-'); % get subject start
            name    = R{s}(index:index+6); % name
            s_value = find(arrayfun(@(x) strcmpi(x.subject,name),STUDY.limo.subjects)); % ensure match
            cond    = unique(STUDY.limo.subjects(s_value).cat_file);
            limo_contrast(fullfile(R{s},'Yr.mat'), BFiles{s}, LFiles{s}, 'T', 1, related(cond));
            limo_contrast(fullfile(R{s},'Yr.mat'), BFiles{s}, LFiles{s}, 'T', 1, unrelated(cond));
            con1_files{s,:} = fullfile(R{s},'con_1.mat');
            con2_files{s,:} = fullfile(R{s},'con_2.mat');
        end      
        
        % 2nd level
       writecell(con1_files,fullfile(STUDY.filepath,'con1_files.txt'))
       writecell(con2_files,fullfile(STUDY.filepath,'con2_files.txt'))

       mkdir(fullfile(STUDY.filepath,['2nd_level' filesep 'N400']));
        cd(fullfile(STUDY.filepath,['2nd_level' filesep 'N400']));
        for N=size(con1_files,1):-1:1
            data{1,N} = con1_files{N};
            data{2,N} = con2_files{N};
        end
        limo_random_select('paired t-test',AvgChanlocs,...
            'LIMOfiles',data, 'analysis_type',...
            'Full scalp analysis', 'type','Channels','nboot',1000,'tfce',1);
        limo_get_effect_size('paired_samples_ttest_parameter_1_2.mat')
        % Param avg (use limo_add_plots to visualize)
        limo_central_tendency_and_ci(fullfile(STUDY.filepath,'con1_files.txt'),...
            1, AvgChanlocs, 'mean', 'Trimmed mean', [],'Con_related')
        limo_central_tendency_and_ci(fullfile(STUDY.filepath,'con2_files.txt'),...
            1, AvgChanlocs, 'mean', 'Trimmed mean', [],'Con_unrelated')
        Diff = limo_plot_difference('Con_unrelated_single_subjects_mean.mat',...
            'Con_related_single_subjects_mean.mat',...
            'type','paired','fig',0,'name','Con_diff');    
        save('Parameter_difference','Diff')
        limo_central_tendency_and_ci(fullfile(STUDY.filepath,['LIMO_N400' filesep 'LIMO_files_N400_N400_GLM_Channels_Time_WLS.txt']),...
            'con_1', AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_related')
        limo_central_tendency_and_ci(fullfile(STUDY.filepath,['LIMO_N400' filesep 'LIMO_files_N400_N400_GLM_Channels_Time_WLS.txt']),...
            'con_2', AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_unrelated')
        Diff = limo_plot_difference('ERPs_unrelated_single_subjects_Weighted mean.mat',...
            'ERPs_related_single_subjects_Weighted mean.mat',...
            'type','paired','fig',0,'name','ERP_diff');   
        save('ERP_difference','Diff')

    elseif strcmpi(task{t},'P3')
   
     % 11: Stimulus - block target A, trial stimulus A,
	   % 22: Stimulus - block target B, trial stimulus B,
	   % 33: Stimulus - block target C, trial stimulus C,
	   % 44: Stimulus - block target D, trial stimulus D,
     % 55: Stimulus - block target E, trial stimulus E,
     % 12, 13, 14, 15 
     % 21, 23, 24, 25
     % 31, 32, 34, 35
     % 41, 42, 43, 45
     % 51, 52, 53, 54
     distractor = [0 1 1 1 1 1 0 1 1 1 1 1 0 1 1 1 1 1 0 1 1 1 1 1 0];
     target     = distractor==0;
       [~,~,LFiles] = limo_get_files([],[],[],...
           fullfile(files.LIMO,'LIMO_files_P3_P3_GLM_Channels_Time_WLS.txt'));
        [~,R,BFiles] = limo_get_files([],[],[],...
            fullfile(files.LIMO,'Beta_files_P3_P3_GLM_Channels_Time_WLS.txt'));

        for s=1:length(LFiles)
            index   = strfind(LFiles{s},'sub-'); % get subject start
            name    = R{s}(index:index+6); % name
            s_value = find(arrayfun(@(x) strcmpi(x.subject,name),STUDY.limo.subjects)); % ensure match
            cond    = unique(STUDY.limo.subjects(s_value).cat_file);
            limo_contrast(fullfile(R{s},'Yr.mat'), BFiles{s}, LFiles{s}, 'T', 1, distractor(cond));
            limo_contrast(fullfile(R{s},'Yr.mat'), BFiles{s}, LFiles{s}, 'T', 1, target(cond));
            con1_files{s,:} = fullfile(R{s},'con_1.mat');
            con2_files{s,:} = fullfile(R{s},'con_2.mat');
        end      
        
        % 2nd level
       writecell(con1_files,fullfile(STUDY.filepath,'con1_files.txt'))
       writecell(con2_files,fullfile(STUDY.filepath,'con2_files.txt'))

       mkdir(fullfile(STUDY.filepath,['2nd_level' filesep 'P3']));
        cd(fullfile(STUDY.filepath,['2nd_level' filesep 'P3']));
        for N=size(con1_files,1):-1:1
            data{1,N} = con2_files{N};
            data{2,N} = con1_files{N};
        end
        limo_random_select('paired t-test',AvgChanlocs,...
            'LIMOfiles',data, 'analysis_type',...
            'Full scalp analysis', 'type','Channels','nboot',1000,'tfce',1);
        limo_get_effect_size('paired_samples_ttest_parameter_2_1.mat')
        % Param avg (use limo_add_plots to visualize)
        limo_central_tendency_and_ci(fullfile(STUDY.filepath,'con1_files.txt'),...
            1, AvgChanlocs, 'mean', 'Trimmed mean', [],'Con_distractors')
        limo_central_tendency_and_ci(fullfile(STUDY.filepath,'con2_files.txt'),...
            1, AvgChanlocs, 'mean', 'Trimmed mean', [],'Con_targets')
        Diff = limo_plot_difference('Con_targets_single_subjects_mean.mat',...
            'Con_distractors_single_subjects_mean.mat',...
            'type','paired','fig',0,'name','Con_diff');   
        save('Parameter_difference','Diff')
        limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_P3_P3_GLM_Channels_Time_WLS.txt'),...
            'con_1', AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_distractors')
        limo_central_tendency_and_ci(fullfile(files.LIMO,'LIMO_files_P3_P3_GLM_Channels_Time_WLS.txt'),...
            'con_2', AvgChanlocs, 'Weighted mean', 'Trimmed mean', [], 'ERPs_targets')
        Diff = limo_plot_difference('ERPs_targets_single_subjects_Weighted mean.mat',...
            'ERPs_distractors_single_subjects_Weighted mean.mat',...
            'type','paired','fig',0,'name','ERP_diff');   
        save('ERP_difference','Diff')

    end
    clear STUDY ALLEEG EEG
end