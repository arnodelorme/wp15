% apply a list of transformations on niftii files and written results to the correct output directory
function patientsDatabase(path_username, path_input, path_output, cellOnset, cellDuration)
	list_subjects = dir(path_input);
	szSubjects = size(list_subjects);

	for p = 3:szSubjects(1)
		check_sub = startsWith(list_subjects(p).name, 'sub');
		if check_sub == true
			path_patient = fullfile(path_input, list_subjects(p).name);
			pathOutput_patient = fullfile(path_output, list_subjects(p).name);
			onePatient(path_username, path_patient, pathOutput_patient, cellOnset, cellDuration);
		end
	end
end