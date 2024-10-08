function printResults(path_output)
	list_subjects = dir(path_output);
	szSubjects = size(list_subjects);

	for s = 3:szSubjects(1)
		path_subject = fullfile(path_output, list_subjects(s).name);
		list_sessions = dir(path_subject);
		szSessions = size(list_sessions);
		for s = 3:szSessions(1)
			path_session = fullfile(path_subject, list_sessions(s).name);
			path_func = fullfile(path_session, 'func');
			list_localizers = dir(path_func);
			szLocalizers = size(list_localizers);
			for l = 3:szLocalizers(1)
				path_localizer = fullfile(path_func, list_localizers(l).name);
				list_contrasts = dir(path_localizer);
				szContrasts = size(list_contrasts);
				for c = 3:szContrasts(1)
					path_contrast = fullfile(path_localizer, list_contrasts(c).name);
					check_folder = isfolder(path_contrast);
					check_pair = strcmp(list_contrasts(c).name, 'pair');
					check_save = strcmp(list_contrasts(c).name, 'save');
					if check_folder == true && check_pair == false && check_save == false
						spm_runResults(path_contrast, list_contrasts(c).name);
					end
				end
			end 
		end
	end 
end
		