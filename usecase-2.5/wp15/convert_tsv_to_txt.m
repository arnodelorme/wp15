% convert the tsv files to txt files in path_input using copyfile function 
function convert_tsv_to_txt(path_input)
	list_files = dir(path_input);
	szFiles = size(list_files);
	
	for f = 3:szFiles(1)
		path_file = fullfile(path_input, list_files(f).name);
		check_file = isfolder(path_file);
		check_task = startsWith(list_files(f).name, 'task');
		check_tsv = endsWith(list_files(f).name, '.tsv');
		if check_file == false && check_task == true && check_tsv == true 
			splitFile = split(list_files(f).name, '.');
			filename = splitFile(1);
			filename_txt = append(filename{1}, '.txt');
			path_txt = fullfile(path_input, filename_txt);
			copyfile(path_file, path_txt);
		end
	end 
end