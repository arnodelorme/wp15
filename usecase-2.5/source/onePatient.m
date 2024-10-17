% apply a list of transformations on niftii files and written results to the correct output directory
function onePatient(path_username, path_subject, path_output)

	% apply list of transformations to fMRIs
    	spm_preprocess(path_subject);
    	disp('preProcess is done !');
		
	path_input = fullfile(path_username, 'input');
	list_subjects = dir(path_input);
	szSubjects = size(list_subjects);

	contrast_names = "contrast";
    	convec = [1 -1];

	for sub = 3:szSubjects(1)
		path_subject = fullfile(path_input, list_subjects(sub).name);
		path_func = fullfile(path_subject, 'func');
		list_files = dir(path_func);
		szFiles = size(list_files);
		for f = 3:szFiles(1)
			path_file = fullfile(path_func, list_files(f).name);
			check_sub = startsWith(list_files(f).name, 'sub');
			check_nifti = endsWith(list_files(f).name, '.nii');
			levels = {};
			if check_sub == true && check_nifti == true
				path_txt = fullfile(path_func, list_files(f+2).name);
				events = dataEvents(path_txt, 'event');
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
	end 
end
