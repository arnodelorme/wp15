function structPreProcess = spm_preprocess(path_input)

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
szFMRIs = size(list_fmris);

for m = 1:szFMRIs(1)
  structPreProcess = struct;

  disp('Step 2 -- Realign all volumes to first functional volume');
  realign(path_func);
  disp('Step 2 - Done!');
  
  disp('Step 3 -- Coregister structural image to first dynamic image');
  coreg(path_source, path_func);
  disp('Step 3 - Done!');

  disp('Step 4 -- Gaussian kernel smoothing of realigned data');
  smooth(path_func); % FIXME CHECK WITH CerCo PEOPLE, the input to smooth() was path_anat at first, is that correct????
  disp('Step 4 is done !');
end
end
