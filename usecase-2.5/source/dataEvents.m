% retrieve data onset and duration written in tsv files located at path_input
function [cellOnset, cellDuration] = dataEvents(path_input) 
	list_files = dir(path_input);
	szFiles = size(list_files);
	
	count = 0;
	
	for f = 3:szFiles(1)
		path_file = fullfile(path_input, list_files(f).name);
		check_file = isfolder(path_file);
		check_txt = endsWith(path_file, '.txt');
		if check_file == false && check_txt == true 
			count = count + 1;
		end 
	end 
	
	index = 1;	
	cellOnset = cell(1, count);
	cellDuration = cell(1, count);
	
	for f = 3:szFiles(1)
		path_file = fullfile(path_input, list_files(f).name);
		check_file = isfolder(path_file);
		check_txt = endsWith(path_file, '.txt');
		arrayOnset = zeros(1,1);
		arrayDuration = zeros(1,1);
		if check_file == false && check_txt == true 
			T = readtable(path_file);
			onset = T.onset;
			duration = T.duration;
			szOnset = size(onset);
			arrayOnset = zeros(szOnset(1), 1);
			for o = 1:szOnset(1)
				arrayOnset(o, 1) = onset(o);
				arrayDuration(o, 1) = duration(o);
			end
		end
		
		sz = size(arrayOnset);
		rows = sz(1);
		
		if  rows > 1
			cellOnset{1, index} = arrayOnset;
			cellDuration{1, index} = arrayDuration;
			index = index + 1;
		end
	end 	
end 