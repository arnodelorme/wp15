function cleanDatabase(path_input)
	list_subjects = dir(path_input);
	szSubjects = size(list_subjects);

	for sub = 3:szSubjects(1)
		path_subject = fullfile(path_input, list_subjects(sub).name);
		check_sub = startsWith(list_subjects(sub).name, 'sub');
		list_fmris = dir(path_subject);
		szFMRIs = size(list_fmris);

		if check_sub == true
			for m = 3:szFMRIs(1)
				path_fmri = fullfile(path_subject, list_fmris(m).name);
				list_files = dir(path_fmri);
				szFiles = size(list_files);
				check_folder = isfolder(path_fmri);
				if check_folder == true
					for f = 3:szFiles(1)
						path_file = fullfile(path_fmri, list_files(f).name);
						check_mean = startsWith(list_files(f).name, 'm');
						check_contrast = startsWith(list_files(f).name, 'c');
						check_r = startsWith(list_files(f).name, 'r');
						check_sr = startsWith(list_files(f).name, 'sr');
						check_mat = endsWith(list_files(f).name, '.mat');

						if check_mean == true
							delete(path_file);
						end

						if check_contrast == true
							delete(path_file);
						end

						if check_r == true
							delete(path_file);
						end

						if check_sr == true
							delete(path_file);
						end

						if check_mat == true
							delete(path_file);
						end

					end
				end
			end
		end
	end
end