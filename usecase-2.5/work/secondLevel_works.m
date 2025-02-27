function secondLevel_works(path_output, list_runs, list_subjects)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make model: 2nd level One-sample t-test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize the batch
matlabbatch = cell(3 + numel(list_subjects),1);

% Define output directory for second-level results
outputdir = fullfile(path_output, 'group');
if ~exist(outputdir, 'dir')
  mkdir(outputdir);
end

for r = 1:numel(list_runs)
  outputdir = fullfile(path_output, 'group', list_runs{r});
  if ~exist(outputdir, 'dir')
    mkdir(outputdir);
  end

  if exist(fullfile(outputdir,'SPM.mat'))
    % avoid request for user input before proceeding
    delete(fullfile(outputdir,'SPM.mat'));
  end

  con_files = cell(numel(list_subjects),1);
  ncon_files = cell(numel(list_subjects),1);
  def_files = cell(numel(list_subjects),1);
  for s = 1:numel(list_subjects)
    % List of first-level contrast images
    con_files{s} = fullfile(path_output, list_subjects{s}, list_runs{r}, 'con_0001.nii');
    def_files{s} = fullfile(strrep(path_output, 'output', 'input'), list_subjects{s}, 'anat', sprintf('y_%s_T1w.nii', list_subjects{s}));
  
    % List of normalised contrast images
    ncon_files{s} = strrep(con_files{s}, 'con', 'wcon');
  end
 
  for s = 1:length(con_files)
    matlabbatch{s}.spm.spatial.normalise.write.subj.def = def_files(s);
    matlabbatch{s}.spm.spatial.normalise.write.subj.resample = con_files(s);
    matlabbatch{s}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85];
    matlabbatch{s}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{s}.spm.spatial.normalise.write.woptions.interp = 4;
  end

  % Specify the factorial design for one-sample t-test
  matlabbatch{s+1}.spm.stats.factorial_design.dir = {outputdir};
  matlabbatch{s+1}.spm.stats.factorial_design.des.t1.scans = ncon_files;

  % Specify model estimation
  matlabbatch{s+2}.spm.stats.fmri_est.spmmat = {fullfile(outputdir, 'SPM.mat')};

  % Specify contrast manager (optional, to define contrasts at the second level)
  matlabbatch{s+3}.spm.stats.con.spmmat = {fullfile(outputdir, 'SPM.mat')};
  matlabbatch{s+3}.spm.stats.con.consess{1}.tcon.name = 'Main_Effect';
  matlabbatch{s+3}.spm.stats.con.consess{1}.tcon.weights = 1;
  matlabbatch{s+3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

  matlabbatch{s+3}.spm.stats.con.consess{1}.tcon.name = 'Main_Effect_Minus';
  matlabbatch{s+3}.spm.stats.con.consess{1}.tcon.weights = -1;
  matlabbatch{s+3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

  spm_jobman('run',matlabbatch);
end

