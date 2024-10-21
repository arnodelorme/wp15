function coreg(path_source, path_func, funcfiles)

if nargin<3
  funcfiles = {};
end

coreg_estimate = struct;

list_files = dir(fullfile(path_func, 'mean*nii'));
if isempty(funcfiles)
  funcfiles  = {list_files.name}';
else
  % the funcfiles are to be preprended with 'mean'
  for f = 1:numel(funcfiles)
    funcfiles{f} = sprintf('mean%s', funcfiles{f});
  end
end

for f = 1:numel(funcfiles)
  check_mean = startsWith(funcfiles{f}, 'mean');

  if check_mean == true
    path_ref = fullfile(path_func, funcfiles{f});

    matlabbatch = {};

    disp(path_source);
    disp(path_ref);

    % Ref
    coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.ref = cellstr(path_ref);

    % Source
    coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.source = cellstr(path_source);

    % Eoptions
    coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    % Run
    spm_jobman('run',coreg_estimate.matlabbatch);

    clear matlabbatch;
  end
end
end