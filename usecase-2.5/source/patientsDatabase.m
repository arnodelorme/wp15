% apply a list of transformations on nifti files and write results to the correct output directory
function patientsDatabase(path_input, path_output, sub_list, task_list, run_list)

  if nargin<4 || isempty(sub_list) || (ischar(sub_list) && isequal(sub_list,'all'))
    list_subjects = dir(fullfile(path_input, 'sub*'));
    sub_list = {list_subjects.name}';    
  end

	for p = 1:numel(sub_list)
		path_patient = fullfile(path_input, sub_list{p});
		pathOutput_patient = fullfile(path_output, sub_list{p});
		%onePatient(path_patient, pathOutput_patient, task_list, run_list);
    onePatient(path_patient, pathOutput_patient);
	end
end