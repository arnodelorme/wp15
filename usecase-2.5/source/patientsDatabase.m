% apply a list of transformations on nifti files and write results to the correct output directory
function patientsDatabase(path_input, path_output, run_list)

  if nargin<4 || isempty(run_list)
    list_subjects = dir(fullfile(path_input, 'sub*'));
    run_list = {list_subjects}';    
  end

	for p = 1:numel(run_list)
		path_patient = fullfile(path_input, run_list{p});
		pathOutput_patient = fullfile(path_output, run_list{p});
		onePatient(path_patient, pathOutput_patient);
	end
end