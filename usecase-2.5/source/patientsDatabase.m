% apply a list of transformations on nifti files and write results to the correct output directory
function patientsDatabase(path_input, path_output, sub_list, task_list)

  if nargin<3 || isempty(sub_list) || (ischar(sub_list) && isequal(sub_list,'all'))
    list_subjects = dir(fullfile(path_input, 'sub*'));
    sub_list = {list_subjects.name}';    
  end

  if nargin<4 || (ischar(task_list) && isequal(task_list, 'all'))
    task_list = {'DOTS_run-001' 'DOTS_run-002' 'Motion_run-001' 'Motion_run-002' 'spWM_run-001' 'spWM_run-002'}';
  end

  % first level model for the specified subjects
	for p = 1:numel(sub_list)
		path_patient_in = fullfile(path_input, sub_list{p});
		path_patient_out = fullfile(path_output, sub_list{p});
	  onePatient(path_patient_in, path_patient_out);
  end

  secondLevel_works(path_output, task_list, sub_list);
end