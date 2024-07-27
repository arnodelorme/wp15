inputprefix = fullfile(pwd, 'input');
outputprefix = fullfile(pwd, 'output');

participants = ft_read_tsv(fullfile(inputprefix, 'participants.tsv'));

% be sure that the emptyroom is not there
participants = participants(~isnan(participants.age), :);

nsubj = size(participants,1);
nruns = 2; % do the computations for the first few runs only

for subject=1:nsubj
  close all

  % use the identifier from the participants file
  subjname = participants.participant_id{subject};

  megfile = cell(1,nruns); % these are the raw data files, they come with the events.tsv
  sssfile = cell(1,nruns); % these are the MaxFiltered data files
  for run=1:nruns
    megfile{run} = fullfile(inputprefix, sprintf('%s/ses-meg/meg/%s_ses-meg_task-facerecognition_run-%02d_meg.fif', subjname, subjname, run));
    sssfile{run} = fullfile(inputprefix, sprintf('derivatives/meg_derivatives/%s/ses-meg/meg/%s_ses-meg_task-facerecognition_run-%02d_proc-sss_meg.fif', subjname, subjname, run));
  end

  mrifile = fullfile(inputprefix, sprintf('%s/ses-mri/anat/%s_ses-mri_acq-mprage_T1w.nii.gz', subjname, subjname));

  coordsystemfile = fullfile(inputprefix, sprintf('%s/ses-meg/meg/%s_ses-meg_coordsystem.json', subjname, subjname));
  coordsystem = ft_read_json(coordsystemfile);

  NAS = coordsystem.AnatomicalLandmarkCoordinates.Nasion;
  LPA = coordsystem.AnatomicalLandmarkCoordinates.LPA;
  RPA = coordsystem.AnatomicalLandmarkCoordinates.RPA;

  outputpath = fullfile(outputprefix, sprintf('%s', subjname));
  mkdir(outputpath);

  analyze_single_subject;
end
