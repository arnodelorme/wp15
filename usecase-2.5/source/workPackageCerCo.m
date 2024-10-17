time_start = tic;

%%
% FIXME the below section is very dangerous because it has strong
% expectations with respect to the user's current working directory

% % retrieve the path username from path_input
% current_folder = pwd;
% split_folder = split(current_folder, '/');
% 
% % build some paths
% path_username = strcat('/', split_folder{2}, '/', split_folder{3}, '/');
% path_spm = fullfile(path_username, 'spm');
% path_spm12 = fullfile(path_spm, 'spm12');
% path_fieldtrip = fullfile(path_spm12, 'fieldtrip');
% path_fileio = fullfile(path_fieldtrip, 'fileio');
% path_freesurfer = fullfile(path_fieldtrip, 'external/freesurfer');
% path_config = fullfile(path_spm12, 'config');
% path_matlabbatch = fullfile(path_spm12, 'matlabbatch');
% path_input = fullfile(path_username, 'input');
% path_output = fullfile(path_username, 'output');
% path_workpackage = fullfile(path_username, 'source');

m = mfilename('fullpath');
[p,f,e] = fileparts(m);
s = split(p, filesep);
sel = find(strcmp(s,'wp15'))-1;
path_username = fullfile(filesep,s{1:sel});

% this assumes that the wp15 repo is at the same level as spm12 and the
% input/output folders, and that the spm12 distro is NOT in spm/spm12

% % build some paths
path_spm12 = fullfile(path_username, 'spm12');
path_fieldtrip = fullfile(path_spm12, 'external', 'fieldtrip');
path_fileio = fullfile(path_fieldtrip, 'fileio');
path_freesurfer = fullfile(path_fieldtrip, 'external/freesurfer');
path_config = fullfile(path_spm12, 'config');
path_matlabbatch = fullfile(path_spm12, 'matlabbatch');
path_input = fullfile(path_username, 'input');
path_output = fullfile(path_username, 'output');
path_workpackage = fullfile(path_username, s{(sel+1):end});

% addpath, for matlab and use them 
addpath(path_spm12);
addpath(path_fieldtrip);
addpath(path_fileio);
addpath(path_freesurfer);
addpath(path_config);
addpath(path_matlabbatch);
addpath(path_workpackage);

% initialize spm12 via matlab
spm('defaults','fmri');
spm_jobman('initcfg');
spm_get_defaults('cmdline',true);

% remove the subject 006
pathSubject_delete = fullfile(path_input, 'sub-SAXNES2s006');
removeSubject(pathSubject_delete);

% convert tsv files to txt files located at path_input 
convert_tsv_to_txt(path_input);
	
% create output architecture directory based on input directory
createDataStructure(path_input, path_output);

% apply a list of transformations to niftii files (anat + func)
patientsDatabase(path_username, path_input, path_output);

% clean useless files
cleanDatabase(path_input);

time_end = toc(time_start);
disp(time_end);
