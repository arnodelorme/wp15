% convert the tsv files to txt files in path_input using copyfile function 
function convert_tsv_to_txt(path_input)
	list_subjects = dir(path_input);
	szSubjects = size(list_subjects);
	
	for sub = 3:szSubjects(1)
		path_subject = fullfile(path_input, list_subjects(sub).name);
		path_func = fullfile(path_subject, 'func');
		list_files = dir(path_func);
		szFiles =size(list_files);
		for f = 3:szFiles(1)
			path_file = fullfile(path_func, list_files(f).name);
			check_tsv = endsWith(list_files(f).name, '.tsv');
			if check_tsv == true 
				splitFile = split(list_files(f).name, '.');
				filename = splitFile(1);
				filename_txt = append(filename{1}, '.txt');
				path_txt = fullfile(path_func, filename_txt);
				copyfile(path_file, path_txt);
			end
		end
	end 
end