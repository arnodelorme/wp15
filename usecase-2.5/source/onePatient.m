% apply a list of transformations on nifti files and write results to the correct output directory
function onePatient(path_subject, path_output, task_list, run_list)

% apply list of transformations to fMRIs, preceded by unzipping if needed: realignment, coregistration, smoothing
[s, funcfiles] = spm_preprocess(path_subject, task_list, run_list);
disp('preProcess is done !');

contrast_names = 'contrast';
convec = [1 -1];

path_func = fullfile(path_subject, 'func');
szFiles = numel(funcfiles);
for f = 1:szFiles
  %path_txt = fullfile(path_func, list_files(f+2).name); % FIXME this is dangerous, because it assumes a fixed order (and number) of files
  path_txt = fullfile(path_func, strrep(funcfiles{f}, 'bold.nii', 'events.tsv'));
  events = dataEvents(path_txt, 'event'); %FIXME consider adjusting dataEvents so that it can operate on the *tsv files directly, which takes away the need to convert the tsv files to txt first
  onset =  dataEvents(path_txt, 'onset');
  duration =  dataEvents(path_txt, 'duration');

  levels = create_levelParameters(2, 'intact', events, onset, duration);
  disp('specify first level is done !');

  firstLevel(path_subject, path_output, levels);
  disp('firstLevel is done !');

  estimateModel(path_output, false);
  disp('estimateModel is done !');

  contrasts(path_output, contrast_names, convec);
  disp('contrasts is done !');
end
end
