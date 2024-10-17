time_start = tic;

% retrieve the path username from path_input
current_folder = pwd;
split_folder = split(current_folder, '/');

% build some paths
path_username = strcat('/', split_folder{2}, '/', split_folder{3}, '/');
path_spm = fullfile(path_username, 'spm');
path_spm12 = fullfile(path_spm, 'spm12');
path_fieldtrip = fullfile(path_spm12, 'fieldtrip');
path_fileio = fullfile(path_fieldtrip, 'fileio');
path_freesurfer = fullfile(path_fieldtrip, 'external/freesurfer');
path_config = fullfile(path_spm12, 'config');
path_matlabbatch = fullfile(path_spm12, 'matlabbatch');
path_input = fullfile(path_username, 'input');
path_output = fullfile(path_username, 'output');
path_workpackage = fullfile(path_username, 'source');

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
pathSubject_delete = '/home/adrienm/ds004934/sub-SAXNES2s006';
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
