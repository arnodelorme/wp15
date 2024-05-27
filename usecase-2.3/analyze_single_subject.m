do_explore        = false;
do_preprocessing  = true;
do_artefacts      = true;
do_timelock       = true;
do_frequency      = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reading and converting the original data files

% the data set consists of MEG and EEG
% furthermore there is anatomical and functional MRI, but that is not considered here

if do_explore
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Reading and reviewing the functional data

  cfg = [];
  cfg.dataset = megfile{1};
  cfg.channel = 'MEG';
  cfg.viewmode = 'vertical';
  cfg.layout = 'neuromag306all.lay';
  ft_databrowser(cfg);

end % do explore

if do_preprocessing
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Aligning the MEG time course data with perception and behavior

  % We want to create three categories of events, based on their numerical codes:
  % Famous faces:      5 (00101),  6 (00110),  7 (00111) => Bit 3 only
  % Unfamiliar faces: 13 (01101), 14 (01110), 15 (01111) => Bit 3 and 4
  % Scrambled images: 17 (10001), 18 (10010), 19 (10011) => Bit 5 only

  % the MEG+EEG data is acquired in 6 blocks, each represented in a single file

  block = {};
  for i=1:numel(megfile)

    cfg = [];
    cfg.dataset = megfile{i};

    cfg.trialfun = 'ft_trialfun_bids';
    cfg.trialdef.eventtype = {'Famous', 'Unfamiliar', 'Scrambled'};
    cfg.trialdef.prestim  = 0.5;
    cfg.trialdef.poststim = 1.2;

    cfg = ft_definetrial(cfg);

    % cfg.channel = 'all';
    % cfg.channel = 'megmag';
    % cfg.channel = 'eeg';
    cfg.channel = 'meggrad';
    cfg.baselinewindow = [-inf 0];
    cfg.demean = 'yes';
    block{i} = ft_preprocessing(cfg);
    block{i} = ft_struct2single(block{i});
  end

  % show the two different types of trial codes
  disp(block{1}.trialinfo);

  % combine all six blocks into a single
  cfg = [];
  cfg.keepsampleinfo = 'no';
  cfg.outputfile = fullfile(outputpath, 'raw.mat');
  raw = ft_appenddata(cfg, block{:});
  
  clear block raw

  %% deal with maxfiltering

  % the data has been maxfiltered and subsequently concatenated
  % this will result in an ill-conditioned estimate of covariance or CSD

  cfg = [];
  cfg.method = 'pca';
  cfg.updatesens = 'no';
  cfg.channel = 'meggrad';
  cfg.inputfile = fullfile(outputpath, 'raw.mat');
  cfg.outputfile = fullfile(outputpath, 'comp.mat');
  comp = ft_componentanalysis(cfg);

  cfg = [];
  cfg.updatesens = 'no';
  cfg.component = comp.label(51:end);
  cfg.inputfile = fullfile(outputpath, 'comp.mat');
  cfg.outputfile = fullfile(outputpath, 'raw_subspace.mat');
  raw_subspace = ft_rejectcomponent(cfg);

  cfg = [];
  cfg.baselinewindow = [-inf 0];
  cfg.demean = 'yes';
  cfg.precision = 'single';
  cfg.inputfile = fullfile(outputpath, 'raw_subspace.mat');
  cfg.outputfile = fullfile(outputpath, 'raw_subspace_demean.mat');
  raw_subspace_demean = ft_preprocessing(cfg);

end % do preprocessing

if do_artefacts
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Data reviewing and artifact handling

  % start with a copy, iterate multiple times
  load(fullfile(outputpath, 'raw_subspace_demean.mat'), 'data');
  raw_clean = data;

  % cfg = [];
  % cfg.keeptrial = 'no';
  % cfg.keepchannel = 'yes';

  % cfg.channel = 'meggrad';
  % raw_clean = ft_rejectvisual(cfg, raw_clean);

  % cfg.channel = 'megmag';
  % raw_clean = ft_rejectvisual(cfg, raw_clean);

  % cfg.channel = 'eeg';
  % raw_clean = ft_rejectvisual(cfg, raw_clean);
  
  % some downstream analysis may get stuck if it encounters both a grad and elec fields
  % FIXME this should be addressed in the fieldtrip code: specifically for me (JM) ft_combineplanar
  % did not run without error, because it did not correctly detect the senstyp automatically
  raw_clean = rmfield(raw_clean, 'elec');
  save(fullfile(outputpath, 'raw_clean'), 'raw_clean');

end % do artefacts


if do_timelock || do_frequency
  % both need the cleaned preprocessed data
  load(fullfile(outputpath, 'raw_clean.mat'));
  raw_clean = data;
end

if do_timelock
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Averaging and Event-Related Fields

  cfg = [];
  cfg.inputfile = fullfile(outputpath, 'raw_clean.mat');

  cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Famous'));
  cfg.outputfile = fullfile(outputpath, 'timelock_famous.mat');
  timelock_famous = ft_timelockanalysis(cfg);

  cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Unfamiliar'));
  cfg.outputfile = fullfile(outputpath, 'timelock_unfamiliar.mat');
  timelock_unfamiliar = ft_timelockanalysis(cfg);

  cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Scrambled'));
  cfg.outputfile = fullfile(outputpath, 'timelock_scrambled.mat');
  timelock_scrambled = ft_timelockanalysis(cfg);

  cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Famous') | strcmp(raw_clean.trialinfo.stim_type, 'Unfamiliar'));
  cfg.outputfile = fullfile(outputpath, 'timelock_faces.mat');
  timelock_faces = ft_timelockanalysis(cfg);

  %% Visualization

  cfg = [];
  cfg.layout = 'neuromag306planar';
  ft_multiplotER(cfg, timelock_faces, timelock_scrambled);
  print('-dpng', fullfile(outputpath, 'timelock_faces_scrambled.png'));
  ft_multiplotER(cfg, timelock_famous, timelock_unfamiliar);
  print('-dpng', fullfile(outputpath, 'timelock_famous_unfamiliar.png'));

  % remove the elec field, otherwise it is not detected as neuromag306
  timelock_famous     = removefields(timelock_famous, 'elec');
  timelock_unfamiliar = removefields(timelock_unfamiliar, 'elec');
  timelock_scrambled  = removefields(timelock_scrambled, 'elec');
  timelock_faces      = removefields(timelock_faces, 'elec');

  timelock_famous_cmb      = ft_combineplanar(cfg, timelock_famous);
  timelock_unfamiliar_cmb  = ft_combineplanar(cfg, timelock_unfamiliar);
  timelock_scrambled_cmb   = ft_combineplanar(cfg, timelock_scrambled);
  timelock_faces_cmb       = ft_combineplanar(cfg, timelock_faces);

  cfg = [];
  cfg.layout = 'neuromag306cmb';
  ft_multiplotER(cfg, timelock_famous_cmb, timelock_unfamiliar_cmb, timelock_scrambled_cmb);
  print('-dpng', fullfile(outputpath, 'timelock_famous_unfamiliar_scrambled_cmb.png'));

  %% Look at contrasts

  cfg = [];
  cfg.parameter = 'avg';
  cfg.operation = 'x1-x2';
  faces_vs_scrambled   = ft_math(cfg, timelock_faces, timelock_scrambled);
  famous_vs_unfamiliar = ft_math(cfg, timelock_famous, timelock_unfamiliar);

  faces_vs_scrambled_cmb   = ft_combineplanar(cfg, faces_vs_scrambled);
  famous_vs_unfamiliar_cmb = ft_combineplanar(cfg, famous_vs_unfamiliar);

  % note that there is a confound due to the number of trials!!

  cfg = [];
  cfg.layout = 'neuromag306cmb';
  figure
  ft_multiplotER(cfg, faces_vs_scrambled_cmb);
  print('-dpng', fullfile(outputpath, 'faces_vs_scrambled_cmb.png'));

  figure
  ft_multiplotER(cfg, famous_vs_unfamiliar_cmb);
  print('-dpng', fullfile(outputpath, 'famous_vs_unfamiliar_cmb.png'));

end % do timelock

if do_frequency
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Time-frequency analysis

  cfg = [];
  cfg.method = 'wavelet';
  cfg.width = 5;
  cfg.gwidth = 2;
  % cfg.keeptrials = 'yes';
  cfg.toi = -0.5:0.02:1.2;
  cfg.foi = 2:2:50;
  cfg.inputfile = fullfile(outputpath, 'raw_clean.mat');
  % cfg.outputfile = fullfile(outputpath, 'freq.mat');
  % freq = ft_freqanalysis(cfg);

  %% compute selective averages

  % load(fullfile(outputpath, 'freq'));

  % cfg = [];
  cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Famous'));
  cfg.outputfile = fullfile(outputpath, 'freq_famous.mat');
  % freq_famous = ft_freqdescriptives(cfg, freq);
  freq_famous = ft_freqanalysis(cfg);

  cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Unfamiliar'));
  cfg.outputfile = fullfile(outputpath, 'freq_unfamiliar.mat');
  % freq_unfamiliar = ft_freqdescriptives(cfg, freq);
  freq_unfamiliar = ft_freqanalysis(cfg);

  cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Scrambled'));
  cfg.outputfile = fullfile(outputpath, 'freq_scrambled.mat');
  % freq_scrambled = ft_freqdescriptives(cfg, freq);
  freq_scrambled = ft_freqanalysis(cfg);

  cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Famous') | strcmp(raw_clean.trialinfo.stim_type, 'Unfamiliar'));
  cfg.outputfile = fullfile(outputpath, 'freq_faces.mat');
  % freq_faces = ft_freqdescriptives(cfg, freq);
  freq_faces = ft_freqanalysis(cfg);

  %% Combine planar and do visualization

  cfg = [];
  cfg.inputfile = fullfile(outputpath, 'freq_famous.mat');
  cfg.outputfile = fullfile(outputpath, 'freq_famous_cmb.mat');
  freq_famous_cmb = ft_combineplanar(cfg);
  cfg.inputfile = fullfile(outputpath, 'freq_unfamiliar.mat');
  cfg.outputfile = fullfile(outputpath, 'freq_unfamiliar_cmb.mat');
  freq_unfamiliar_cmb = ft_combineplanar(cfg);
  cfg.inputfile = fullfile(outputpath, 'freq_scrambled.mat');
  cfg.outputfile = fullfile(outputpath, 'freq_scrambled_cmb.mat');
  freq_scrambled_cmb  = ft_combineplanar(cfg);
  cfg.inputfile = fullfile(outputpath, 'freq_faces.mat');
  cfg.outputfile = fullfile(outputpath, 'freq_faces_cmb.mat');
  freq_faces_cmb = ft_combineplanar(cfg);

  cfg = [];
  cfg.layout = 'neuromag306cmb';
  cfg.baseline = [-inf 0];
  cfg.baselinetype = 'relchange';
  figure
  ft_multiplotTFR(cfg, freq_famous_cmb);
  print('-dpng', fullfile(outputpath, 'freq_famous_cmb.png'));

  figure
  ft_multiplotTFR(cfg, freq_unfamiliar_cmb);
  print('-dpng', fullfile(outputpath, 'freq_unfamiliar_cmb.png'));

  figure
  ft_multiplotTFR(cfg, freq_scrambled_cmb);
  print('-dpng', fullfile(outputpath, 'freq_scrambled_cmb.png'));

  figure
  ft_multiplotTFR(cfg, freq_faces_cmb);
  print('-dpng', fullfile(outputpath, 'freq_faces_cmb.png'));

end % do frequency
