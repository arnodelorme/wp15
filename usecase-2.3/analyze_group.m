inputprefix = fullfile(pwd, 'input');
outputprefix = fullfile(pwd, 'output');
grouppath = fullfile(outputprefix, 'group');
mkdir(grouppath);

warning off

participants = ft_read_tsv(fullfile(inputprefix, 'participants.tsv'));

% be sure that the emptyroom is not there
participants = participants(~isnan(participants.age), :);
nsubj = size(participants,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load the single subject averages
timelock_faces      = cell(1,nsubj);
timelock_scrambled  = cell(1,nsubj);
timelock_famous     = cell(1,nsubj);
timelock_unfamiliar = cell(1,nsubj);

for subject=1:nsubj
  % use the identifier from the participants file
  subjname = participants.participant_id{subject};

  subjectpath = fullfile(outputprefix, sprintf('%s', subjname));

  tmp = load(fullfile(subjectpath, 'timelock_faces'));
  timelock_faces{subject} = tmp.timelock;

  tmp = load(fullfile(subjectpath, 'timelock_scrambled'));
  timelock_scrambled{subject} = tmp.timelock;

  tmp = load(fullfile(subjectpath, 'timelock_famous'));
  timelock_famous{subject} = tmp.timelock;

  tmp = load(fullfile(subjectpath, 'timelock_unfamiliar'));
  timelock_unfamiliar{subject} = tmp.timelock;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% compute planar gradients

timelock_faces_cmb      = cell(1,nsubj);
timelock_scrambled_cmb  = cell(1,nsubj);
timelock_famous_cmb     = cell(1,nsubj);
timelock_unfamiliar_cmb = cell(1,nsubj);

for i=1:nsubj
  disp(i)
  cfg = [];
  timelock_faces_cmb{i}      = ft_combineplanar(cfg, timelock_faces{i});
  timelock_scrambled_cmb{i}  = ft_combineplanar(cfg, timelock_scrambled{i});
  timelock_famous_cmb{i}     = ft_combineplanar(cfg, timelock_famous{i});
  timelock_unfamiliar_cmb{i} = ft_combineplanar(cfg, timelock_unfamiliar{i});
end

% this is a bit of a lengthy step, hence save the intermediate results
save(fullfile(grouppath, 'timelock_faces_cmb'), 'timelock_faces_cmb');
save(fullfile(grouppath, 'timelock_scrambled_cmb'), 'timelock_scrambled_cmb');
save(fullfile(grouppath, 'timelock_famous_cmb'), 'timelock_famous_cmb');
save(fullfile(grouppath, 'timelock_unfamiliar_cmb'), 'timelock_unfamiliar_cmb');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% compute grand averages

timelock_faces_cmb_ga      = ft_timelockgrandaverage(cfg, timelock_faces_cmb{:});
timelock_scrambled_cmb_ga  = ft_timelockgrandaverage(cfg, timelock_scrambled_cmb{:});
timelock_famous_cmb_ga     = ft_timelockgrandaverage(cfg, timelock_famous_cmb{:});
timelock_unfamiliar_cmb_ga = ft_timelockgrandaverage(cfg, timelock_unfamiliar_cmb{:});

%% visualise the grand-averages

cfg = [];
cfg.layout = 'neuromag306cmb';
figure
ft_multiplotER(cfg, timelock_faces_cmb_ga, timelock_scrambled_cmb_ga);

figure
ft_multiplotER(cfg, timelock_famous_cmb_ga, timelock_unfamiliar_cmb_ga);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do standard statistical comparison between conditions

cfg = [];
cfg.method = 'analytic';
cfg.statistic = 'depsamplesT';
cfg.correctm = 'fdr';
cfg.design = [
  1:nsubj          1:nsubj
  1*ones(1,nsubj)  2*ones(1,nsubj)
  ];
cfg.uvar = 1; % unit of observation, i.e. subject
cfg.ivar = 2; % independent variable, i.e. stimulus

stat_cmb_faces_vs_scrambled   = ft_timelockstatistics(cfg, timelock_faces_cmb{:},  timelock_scrambled_cmb{:});
stat_cmb_famous_vs_unfamiliar = ft_timelockstatistics(cfg, timelock_famous_cmb{:}, timelock_unfamiliar_cmb{:});

% this is a bit of a lengthy step, hence save the results
save(fullfile(grouppath, 'stat_cmb_faces_vs_scrambled'), 'stat_cmb_faces_vs_scrambled');
save(fullfile(grouppath, 'stat_cmb_famous_vs_unfamiliar'), 'stat_cmb_famous_vs_unfamiliar');

%% quick and dirty visualisation

figure
subplot(2,1,1)
h = imagesc(-log10(stat_cmb_faces_vs_scrambled.prob)); colorbar
subplot(2,1,2)
h = imagesc(-log10(stat_cmb_faces_vs_scrambled.prob)); colorbar
set(h, 'AlphaData', stat_cmb_faces_vs_scrambled.mask);
print('-dpng', fullfile(grouppath, 'stat_cmb_faces_vs_scrambled.png'));

%% compute the condition difference

% note that these are the differences of the combined planar gradient representations
% not the combined planar gradient representations of the difference

cfg = [];
cfg.parameter = 'avg';
cfg.operation = 'x1-x2';
diff_cmb_faces_vs_scrambled = ft_math(cfg, timelock_faces_cmb_ga, timelock_scrambled_cmb_ga);
diff_cmb_famous_vs_unfamiliar = ft_math(cfg, timelock_famous_cmb_ga, timelock_unfamiliar_cmb_ga);

% save the results
save(fullfile(grouppath, 'diff_cmb_faces_vs_scrambled'), 'diff_cmb_faces_vs_scrambled');
save(fullfile(grouppath, 'diff_cmb_famous_vs_unfamiliar'), 'diff_cmb_famous_vs_unfamiliar');

%% more detailed visualisation

% add the statistical mask to the data
diff_cmb_faces_vs_scrambled.mask = stat_cmb_faces_vs_scrambled.mask;
diff_cmb_famous_vs_unfamiliar.mask = stat_cmb_famous_vs_unfamiliar.mask;

cfg = [];
cfg.layout = 'neuromag306cmb';
cfg.parameter = 'avg';
cfg.maskparameter = 'mask';
figure
ft_multiplotER(cfg, diff_cmb_faces_vs_scrambled);
print('-dpng', fullfile(grouppath, 'diff_cmb_faces_vs_scrambled_stat.png'));

figure
ft_multiplotER(cfg, diff_cmb_famous_vs_unfamiliar);
print('-dpng', fullfile(grouppath, 'diff_cmb_famous_vs_unfamiliar_stat.png'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% determine the neighbours that we consider to share evidence in favour of H1

cfg = [];
cfg.layout = 'neuromag306cmb';
cfg.method = 'distance';
cfg.neighbourdist = 0.15;
cfg.feedback = 'yes';
neighbours_cmb = ft_prepare_neighbours(cfg); % this is an example of a poor neighbourhood definition

print('-dpng', fullfile(grouppath, 'neighbours_cmb_distance.png'));

cfg.layout = 'neuromag306cmb';
cfg.method = 'triangulation';
cfg.feedback = 'yes';
neighbours_cmb = ft_prepare_neighbours(cfg); % this one is better, but could use some manual adjustments

print('-dpng', fullfile(grouppath, 'neighbours_cmb_triangulation.png'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do a more sensitive cluster-based statistical analysis

cfg = [];
cfg.method = 'montecarlo';
cfg.numrandomization = 500;
cfg.statistic = 'depsamplesT';
cfg.correctm = 'cluster';
cfg.neighbours = neighbours_cmb;
cfg.design = [
  1:nsubj          1:nsubj
  1*ones(1,nsubj)  2*ones(1,nsubj)
  ];
cfg.uvar = 1; % unit of observation, i.e. subject
cfg.ivar = 2; % independent variable, i.e. stimulus

cluster_cmb_faces_vs_scrambled   = ft_timelockstatistics(cfg, timelock_faces_cmb{:},  timelock_scrambled_cmb{:});
cluster_cmb_famous_vs_unfamiliar = ft_timelockstatistics(cfg, timelock_famous_cmb{:}, timelock_unfamiliar_cmb{:});

% this is a very lengthy step, hence save the results
save(fullfile(grouppath, 'cluster_cmb_faces_vs_scrambled'), 'cluster_cmb_faces_vs_scrambled');
save(fullfile(grouppath, 'cluster_cmb_famous_vs_unfamiliar'), 'cluster_cmb_famous_vs_unfamiliar');

%% quick and dirty visualisation

figure
subplot(2,1,1)
h = imagesc(-log10(cluster_cmb_faces_vs_scrambled.prob)); colorbar
subplot(2,1,2)
h = imagesc(-log10(cluster_cmb_faces_vs_scrambled.prob)); colorbar
set(h, 'AlphaData', cluster_cmb_faces_vs_scrambled.mask);
print('-dpng', fullfile(grouppath, 'cluster_cmb_faces_vs_scrambled.png'));

%% more detailed visualisation

% add the statistical mask to the data
diff_cmb_faces_vs_scrambled.mask = cluster_cmb_faces_vs_scrambled.mask;
diff_cmb_famous_vs_unfamiliar.mask = cluster_cmb_famous_vs_unfamiliar.mask;

cfg = [];
cfg.layout = 'neuromag306cmb';
cfg.parameter = 'avg';
cfg.maskparameter = 'mask';
figure
ft_multiplotER(cfg, diff_cmb_faces_vs_scrambled);
print('-dpng', fullfile(grouppath, 'diff_cmb_faces_vs_scrambled_cluster.png'));

figure
ft_multiplotER(cfg, diff_cmb_famous_vs_unfamiliar);
print('-dpng', fullfile(grouppath, 'diff_cmb_famous_vs_unfamiliar_cluster.png'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% show full provenance of the final analysis

cfg = [];
cfg.filetype = 'html';
cfg.filename = fullfile(grouppath, 'cluster_cmb_faces_vs_scrambled');
ft_analysispipeline(cfg, cluster_cmb_faces_vs_scrambled);
