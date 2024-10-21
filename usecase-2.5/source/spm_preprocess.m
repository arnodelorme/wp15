function [structPreProcess, funcfiles] = spm_preprocess(path_input, task_list, run_list)

if nargin<2 || isempty(task_list) || (ischar(task_list) && isequal(task_list, 'all'))
  task_list = {}; % don't do a selection on the tasks
end

if nargin<3 || isempty(run_list) || (ischar(run_list) && isequal(run_list, 'all'))
  run_list = {}; % don't do a selection on the runs
end

path_source = '';
path_anat = fullfile(path_input, 'anat');
list_files = dir(fullfile(path_anat, 'sub*nii.gz'));
if ~isempty(list_files)
  for f = 1:numel(list_files)
    fname = fullfile(list_files(f).folder, list_files(f).name);
    fprintf('unzipping %s', fname)
    gunzip(fname);
    delete(fname);
  end
end
list_files = dir(fullfile(path_anat, 'sub*nii'));
szFiles = size(list_files);

for f = 1:szFiles(1)
  path_file   = fullfile(path_anat, list_files(f).name);
  path_source = path_file;
end

path_func = fullfile(path_input, 'func'); % according to BIDS, functional MRIs are always stored in func folders
list_fmris = dir(fullfile(path_func, 'sub*nii.gz')); 
if ~isempty(list_fmris)
  for f = 1:numel(list_fmris)
    fname = fullfile(list_fmris(f).folder, list_fmris(f).name);
    fprintf('unzipping %s', fname)
    gunzip(fname);
    delete(fname);
  end
end
list_fmris = dir(fullfile(path_func, 'sub*nii'));

funcfiles  = {list_fmris.name}';
sel        = false(numel(funcfiles), 1);
if ~isempty(task_list)
  for k = 1:numel(task_list)
    sel = sel | contains(funcfiles, task_list{k});
  end
  funcfiles = funcfiles(sel);
end
sel        = false(numel(funcfiles), 1);
if ~isempty(run_list)
  for k = 1:numel(run_list)
    sel = sel | contains(funcfiles, run_list{k});
  end
end
funcfiles = funcfiles(sel);

structPreProcess = struct;

disp('Step 2 -- Realign all volumes to first functional volume');
%realign(path_func, funcfiles);
disp('Step 2 - Done!');
  
disp('Step 3 -- Coregister structural image to first dynamic image');
%coreg(path_source, path_func, funcfiles);
disp('Step 3 - Done!');

disp('Step 4 -- Gaussian kernel smoothing of realigned data');
%smooth(path_func, funcfiles); % FIXME CHECK WITH CerCo PEOPLE, the input to smooth() was path_anat at first, is that correct????
disp('Step 4 is done !');
end
