
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reading and preprocessing

% the data set consists of MEG and EEG
% furthermore there is anatomical and functional MRI, but that is not considered here

nruns = length(megfile);
block = cell(1, nruns);

% We want to create three categories of events, based on their numerical codes:
% Famous faces:      5 (00101),  6 (00110),  7 (00111) => Bit 3 only
% Unfamiliar faces: 13 (01101), 14 (01110), 15 (01111) => Bit 3 and 4
% Scrambled images: 17 (10001), 18 (10010), 19 (10011) => Bit 5 only

% the MEG+EEG data is acquired in 6 blocks, each represented in a single file
for i=1:nruns

  cfg = [];
  % define the trials on basis of the original raw datafile
  % the maxfiltered version does not include the events.tsv
  cfg.dataset = megfile{i};

  cfg.trialfun = 'ft_trialfun_bids';
  cfg.trialdef.eventtype = {'Famous', 'Unfamiliar', 'Scrambled'};
  cfg.trialdef.prestim  = 0.5;
  cfg.trialdef.poststim = 1.2;

  % aligning the MEG time course data with perception and behavior
  cfg = ft_definetrial(cfg);

  % read the maxfiltered version of the raw data
  cfg.dataset = sssfile{i};
  cfg.readbids = 'no';

  % cfg.channel = 'all';
  % cfg.channel = 'megmag';
  % cfg.channel = 'eeg';
  cfg.channel = 'meggrad';
  cfg.baselinewindow = [-inf 0];
  cfg.demean = 'yes';
  cfg.precision = 'single';
  cfg.coilaccuracy = 1;

  % read and preprocess the trials of interest from the data
  block{i} = ft_preprocessing(cfg);
end

% show the two different types of trial codes
disp(block{1}.trialinfo);

% combine all six blocks into a single
cfg = [];
cfg.keepsampleinfo = 'no';
cfg.outputfile = fullfile(outputpath, 'raw.mat');
raw = ft_appenddata(cfg, block{:});

clear block

%%

% some downstream analysis may get stuck if it encounters both a grad and elec fields
% FIXME this should be addressed in the fieldtrip code: specifically for me (JM) ft_combineplanar
% did not run without error, because it did not correctly detect the senstyp automatically
raw = rmfield(raw, 'elec');


%% Deal with maxfiltering

% the data has been maxfiltered and subsequently concatenated
% this will result in an ill-conditioned estimate of covariance or CSD

cfg = [];
cfg.method = 'pca';
cfg.updatesens = 'no';
cfg.channel = 'meggrad';
% cfg.inputfile = fullfile(outputpath, 'raw.mat');
cfg.outputfile = fullfile(outputpath, 'comp.mat');
comp = ft_componentanalysis(cfg, raw);

cfg = [];
cfg.updatesens = 'no';
cfg.component = comp.label(51:end);
% cfg.inputfile = fullfile(outputpath, 'comp.mat');
cfg.outputfile = fullfile(outputpath, 'raw_subspace.mat');
raw_subspace = ft_rejectcomponent(cfg, comp);

cfg = [];
cfg.baselinewindow = [-inf 0];
cfg.demean = 'yes';
cfg.precision = 'single';
% cfg.inputfile = fullfile(outputpath, 'raw_subspace.mat');
cfg.outputfile = fullfile(outputpath, 'raw_subspace_demean.mat');
raw_subspace_demean = ft_preprocessing(cfg, raw_subspace);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data reviewing and artifact handling

cfg = [];
cfg.metric = 'std';
cfg.threshold = 10e-12; % pT
% cfg.inputfile = fullfile(outputpath, 'raw_subspace_demean.mat');
cfg.outputfile = fullfile(outputpath, 'raw_clean.mat');
raw_clean = ft_baddata(cfg, raw_subspace_demean);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Averaging and Event-Related Fields

cfg = [];
% cfg.inputfile = fullfile(outputpath, 'raw_clean.mat');

cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Famous'));
cfg.outputfile = fullfile(outputpath, 'timelock_famous.mat');
timelock_famous = ft_timelockanalysis(cfg, raw_clean);

cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Unfamiliar'));
cfg.outputfile = fullfile(outputpath, 'timelock_unfamiliar.mat');
timelock_unfamiliar = ft_timelockanalysis(cfg, raw_clean);

cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Scrambled'));
cfg.outputfile = fullfile(outputpath, 'timelock_scrambled.mat');
timelock_scrambled = ft_timelockanalysis(cfg, raw_clean);

cfg.trials = find(strcmp(raw_clean.trialinfo.stim_type, 'Famous') | strcmp(raw_clean.trialinfo.stim_type, 'Unfamiliar'));
cfg.outputfile = fullfile(outputpath, 'timelock_faces.mat');
timelock_faces = ft_timelockanalysis(cfg, raw_clean);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Visualization

cfg = [];
cfg.layout = 'neuromag306planar';
ft_multiplotER(cfg, timelock_faces, timelock_scrambled);
print('-dpng', fullfile(outputpath, 'timelock_faces_scrambled.png'));
ft_multiplotER(cfg, timelock_famous, timelock_unfamiliar);
print('-dpng', fullfile(outputpath, 'timelock_famous_unfamiliar.png'));

cfg = [];
timelock_famous_cmb      = ft_combineplanar(cfg, timelock_famous);
timelock_unfamiliar_cmb  = ft_combineplanar(cfg, timelock_unfamiliar);
timelock_scrambled_cmb   = ft_combineplanar(cfg, timelock_scrambled);
timelock_faces_cmb       = ft_combineplanar(cfg, timelock_faces);

cfg = [];
cfg.layout = 'neuromag306cmb';
ft_multiplotER(cfg, timelock_famous_cmb, timelock_unfamiliar_cmb, timelock_scrambled_cmb);
print('-dpng', fullfile(outputpath, 'timelock_famous_unfamiliar_scrambled_cmb.png'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Visualization of contrasts

cfg = [];
cfg.parameter = 'avg';
cfg.operation = 'x1-x2';
faces_vs_scrambled   = ft_math(cfg, timelock_faces, timelock_scrambled);
famous_vs_unfamiliar = ft_math(cfg, timelock_famous, timelock_unfamiliar);

cfg = [];
faces_vs_scrambled_cmb   = ft_combineplanar(cfg, faces_vs_scrambled);
famous_vs_unfamiliar_cmb = ft_combineplanar(cfg, famous_vs_unfamiliar);

cfg = [];
cfg.layout = 'neuromag306cmb';
figure
ft_multiplotER(cfg, faces_vs_scrambled_cmb);
print('-dpng', fullfile(outputpath, 'faces_vs_scrambled_cmb.png'));

figure
ft_multiplotER(cfg, famous_vs_unfamiliar_cmb);
print('-dpng', fullfile(outputpath, 'famous_vs_unfamiliar_cmb.png'));
