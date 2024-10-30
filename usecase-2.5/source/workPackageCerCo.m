function workPackageCerCo(sub_list, task_list, run_list)

if nargin<1 || isempty(sub_list)
  sub_list = 'all';
end

if nargin<2 || isempty(task_list)
  task_list = 'all';
end

if nargin<3 || isempty(run_list)
  run_list = 'all';
end

time_start = tic;

m = mfilename('fullpath');
[p,f,e] = fileparts(m);
s = split(p, filesep);
sel = find(strcmp(s,'wp15'))-1;
path_username = fullfile(filesep,s{1:sel});

% this assumes that the wp15 repo is at the same level as spm12 and the
% input/output folders, and that the spm12 distro is NOT in spm/spm12

% % build some paths
path_spm12 = fullfile(path_username, 'spm12');
path_config = fullfile(path_spm12, 'config');
path_matlabbatch = fullfile(path_spm12, 'matlabbatch');
path_input = fullfile(path_username, 'input');
path_output = fullfile(path_username, 'output');
path_workpackage = fullfile(path_username, s{(sel+1):end});

% addpath, for matlab and use them 
addpath(path_spm12);
addpath(path_config);
addpath(path_matlabbatch);
addpath(path_workpackage);

% initialize spm12 via matlab
spm('defaults','fmri');
spm_jobman('initcfg');
spm_get_defaults('cmdline',true);

% remove the subject 006
pathSubject_delete = fullfile(path_input, 'sub-SAXNES2s006');
if exist(pathSubject_delete, 'dir')
  removeSubject(pathSubject_delete);
end

% delete VOE files
deleteVOE(path_input);
	
% create output architecture directory based on input directory
try
  % running createDataStructure for a second time while output folder
  % already exists leads to problems in my case. I don't want to spend time
  % on debugging/diagnosing this, so I will throw away the output folder
  % and start from scratch
  rmdir(path_output, 's');
end
createDataStructure(path_input, path_output);

% apply a list of transformations to nifti files (anat + func)
patientsDatabase(path_input, path_output, sub_list, task_list, run_list);

time_end = toc(time_start);
disp(time_end);
