function secondLevel_works(path_output, list_runs, list_subjects)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make model: 2nd level One-sample t-test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize the batch
matlabbatch = cell(3,1);

% Define output directory for second-level results
outputdir = fullfile(path_output, 'groupresults');
if ~exist(outputdir, 'dir')
  mkdir(outputdir);
end

for r = 1:numel(list_runs)
  outputdir = fullfile(path_output, 'groupresults', list_runs{r});
  if ~exist(outputdir, 'dir')
    mkdir(outputdir);
  end

  con_files = cell(numel(list_subjects),1);
  for s = 1:numel(list_subjects)
    % List of first-level contrast images
    con_files{s} = fullfile(path_output, list_subjects{s}, list_runs{r}, 'con_0001.nii');
  end

  % Specify the factorial design for one-sample t-test
  matlabbatch{1}.spm.stats.factorial_design.dir = {outputdir};
  matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = con_files;

  % Specify model estimation
  matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(outputdir, 'SPM.mat')};

  % Specify contrast manager (optional, to define contrasts at the second level)
  matlabbatch{3}.spm.stats.con.spmmat = {fullfile(outputdir, 'SPM.mat')};
  matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Main_Effect';
  matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
  matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

  matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Main_Effect_Minus';
  matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = -1;
  matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

  spm_jobman('run',matlabbatch);
end

