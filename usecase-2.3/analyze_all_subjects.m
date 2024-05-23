inputprefix = fullfile(pwd, 'input');
outputprefix = fullfile(pwd, 'output');

for subject=10:16
  close all

  nruns = 1; % FIXME
  megfile = cell(1,nruns);
  for run=1:nruns
    megfile{run} = fullfile(inputprefix, sprintf('sub-%02d/ses-meg/meg/sub-%02d_ses-meg_task-facerecognition_run-%02d_meg.fif', subject, subject, run));
  end

  mrifile = fullfile(inputprefix, sprintf('sub-%02d/ses-mri/anat/sub-%02d_ses-mri_acq-mprage_T1w.nii.gz', subject, subject));

  coordsystemfile = fullfile(inputprefix, sprintf('sub-%02d/ses-meg/meg/sub-%02d_ses-meg_coordsystem.json', subject, subject));
  coordsystem = ft_read_json(coordsystemfile);

  NAS = coordsystem.AnatomicalLandmarkCoordinates.Nasion;
  LPA = coordsystem.AnatomicalLandmarkCoordinates.LPA;
  RPA = coordsystem.AnatomicalLandmarkCoordinates.RPA;

  outputpath = fullfile(outputprefix, sprintf('sub-%02d', subject));
  mkdir(outputpath);

  analyze_single_subject;
end
