inputprefix  = fullfile(pwd, 'input');
outputprefix = fullfile(pwd, 'output');

d  = dir(fullfile(inputprefix, 'sub*'));

% be sure that the emptyroom is not there
subjnames = {d.name}';
subjnames = subjnames(~contains(subjnames, 'emptyroom'));
nsubj = numel(subjnames);

nruns = 1; % do the computations for the first run only
for subject=1:nsubj
  close all

  subjname = subjnames{subject};
  megfile = cell(1,nruns);
  for run=1:nruns
    megfile{run} = fullfile(inputprefix, sprintf('%s/ses-meg/meg/%s_ses-meg_task-facerecognition_run-%02d_meg.fif', subjname, subjname, run));
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
