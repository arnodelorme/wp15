% apply first level function based on nifti files (rsub*) and their associated text files (produced by the spm_preprocess function)
function firstLevel(path_input, path_output, struct_levels)

design_stats = struct;

path_func = fullfile(path_input, 'func');
list_files = dir(path_func);
szFiles = size(list_files);

path_rsub = '';
path_txt= '';

index = 1;

list_rSub = {};
list_txt = {};

% retrieve nifti files (rsub*) and their associated text files for each subject
for f = 3:szFiles(1)

  check_rp = startsWith(list_files(f).name, 'rp');
  check_txt = endsWith(list_files(f).name, '.txt');

  if check_rp == true && check_txt == true
    index = 1;
    start_pos = 0;
    final_pos = 0;
    filename = list_files(f).name;
    start_pos = strfind(list_files(f).name, 'rp_');
    final_pos = '';

    real_begin = -1;
    real_end = -1;

    final_pos = strfind(list_files(f).name, 'bold');
    real_begin = start_pos + 24;
    real_end = final_pos - 2;

    localizer = '';

    for r = real_begin:real_end
      localizer = append(localizer, filename(r));
    end

    path_txt = fullfile(path_func, list_files(f).name);

    path_rFile = '';

    length = strlength(localizer);

    for g = 3:szFiles(1)

      check_rsub = startsWith(list_files(g).name, 'rsub');
      check_nifti = endsWith(list_files(g).name, '.nii');

      if check_rsub == true && check_nifti == true
        position = 0;
        position = strfind(list_files(g).name, localizer);
        if position > 0
          path_rFile = fullfile(path_func, list_files(g).name);
        end
      end
    end

    % specify scans and multi_regression files
    design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.scans = {};
    design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(path_rFile);
    design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg= cellstr(path_txt);

    % setup batch job structure
    % dir
    pathLocalizer_output = fullfile(path_output, localizer);

    disp(pathLocalizer_output);

    design_stats.matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(pathLocalizer_output); %{path_output};

    % timing
    design_stats.matlabbatch{1}.spm.stats.fmri_spec.timing.units = struct_levels.timing_units;
    design_stats.matlabbatch{1}.spm.stats.fmri_spec.timing.RT = struct_levels.timing_RT;

    names = struct_levels.conditionName;
    szNames = size(names);

    onset = struct_levels.conditionOnset;
    szOnset = size(onset);

    duration = struct_levels.conditionDuration;
    szDuration = size(duration);

    stop = 1;

    for n = 1:szNames(2)
      subOnset = [];
      subDuration = [];
      index = 1;
      name_event = names(n);
      length = szOnset(2) - 1;
      while onset(index) < onset(index+1)
        subOnset(index) = onset(index);
        index = index + 1;
      end

      stop = index;

      index = 1;
      szDuration = size(duration);
      szSubOnset = size(subOnset);

      for s = 1:szSubOnset(2)
        if index <= szDuration(2)
          subDuration(index) = duration(index);
        end

        if index > szDuration(2)
          if szDuration(2) > 1
            subDuration(index) = duration(szDuration(2) - 1);
          end

          if szDuration(2) == 1
            subDuration(index) = duration(1);
          end
        end

        index = index + 1;
      end

      design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.cond(n).name = name_event;
      design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.cond(n).onset = subOnset;
      design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.cond(n).duration = subDuration;

    end

    %run batch job
    spm_jobman('run',design_stats.matlabbatch);
    clear matlabbatch;
  end
end
end