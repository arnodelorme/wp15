% apply a list of transformations on niftii files and written results to the correct output directory
function onePatient(path_username, path_subject, path_output)

	% apply list of transformations to fMRIs
    	[s, funcfiles] = spm_preprocess(path_subject, path_output);
    	disp('preProcess is done !');
		
	path_input = fullfile(path_username, 'input');
	path_output = fullfile(path_username, 'output');
	list_subjects = dir(path_input);
	szSubjects = size(list_subjects);

	for sub = 3:szSubjects(1)
		path_subject = fullfile(path_input, list_subjects(sub).name);
		pathSubject_output = fullfile(path_output, list_subjects(sub).name);
		path_func = fullfile(path_subject, 'func');
		list_files = dir(path_func);
		szFiles = size(list_files);

		for f = 3:szFiles(1)
			path_file = fullfile(path_func, list_files(f).name);
			check_sub = startsWith(list_files(f).name, 'sub');
			check_nifti = endsWith(list_files(f).name, '.nii');

			if check_sub == true && check_nifti == true
				path_tsv = fullfile(path_func, list_files(f+1).name);
				path_txt = fullfile(path_func, list_files(f+2).name);
				run_event = extractEvents(list_files(f+1).name);
				events = dataEvents(path_txt, 'event');
				onset =  dataEvents(path_txt, 'onset');
				duration =  dataEvents(path_txt, 'duration');

				levels = create_levelParameters(2, 'intact', events, onset, duration);
				disp('specify first level is done !');

				path_run = fullfile(pathSubject_output, run_event);
		
				firstLevel(path_run, levels);
				disp('firstLevel is done !');

				estimateModel(path_run);
				disp('estimateModel is done !');

				contrasts(path_run);
				disp('contrasts is done !');
			end
        	end

        	path_anat = fullfile(path_subject, 'anat');
        	list_files = dir(path_anat);
        	szFiles = size(list_files);

        	for f = 3:szFiles(1)
            		check_sub = startsWith(list_files(f).name, 'sub');

            		if check_sub == false
                		path_file = fullfile(path_anat, list_files(f).name);
                		delete(path_file);
            		end
        	end 
	end

	path_ref = fullfile(path_output, 'sub-SAXNES2s001');
	list_runs = dir(path_ref);
	
	secondLevel(path_output, list_runs, "contrast");
	disp('secondLevel is done !');
end
