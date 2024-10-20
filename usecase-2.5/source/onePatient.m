% apply a list of transformations on nifti files and write results to the correct output directory
function onePatient(path_subject, path_output)

% apply list of transformations to fMRIs, preceded by unzipping if needed: realignment, coregistration, smoothing
spm_preprocess(path_subject);
disp('preProcess is done !');

contrast_names = 'contrast';
convec = [1 -1];

path_func = fullfile(path_subject, 'func');
list_files = dir(fullfile(path_func, 'sub*nii'));
szFiles = size(list_files);
for f = 1:szFiles(1)
  path_txt = fullfile(path_func, list_files(f+2).name); % FIXME this is dangerous, because it assumes a fixed order (and number) of files
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
