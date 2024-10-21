function smooth(path_func, funcfiles)

if nargin<3
  funcfiles = {};
end

list_files = dir(fullfile(path_func, 'r*nii'));
if isempty(funcfiles)
  funcfiles  = {list_files.name}';
else
  % the funcfiles are to be prepended with 'mean'
  for f = 1:numel(funcfiles)
    funcfiles{f} = sprintf('r%s', funcfiles{f});
  end
end

for f = 1:numel(funcfiles)
  check_rFile = startsWith(funcfiles{f}, 'rsub');

  if check_rFile == true
    path_file = fullfile(path_func, funcfiles{f});

    smooth = struct;

    % Data
    smooth.matlabbatch{1}.spm.spatial.smooth.data = cellstr(path_file);
    smooth.matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
    smooth.matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    smooth.matlabbatch{1}.spm.spatial.smooth.prefix = 's';

    % Run
    spm_jobman('run',smooth.matlabbatch);

    clear matlabbatch;

  end
end
end
