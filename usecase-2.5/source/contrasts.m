% appply some contrasts to SPM.mat file  
function contrasts(path_output, names, weights)

    contrasts = struct;    
    szNames = size(names);
	            
	path_spmmat = fullfile(path_output, 'SPM.mat');
	contrasts.matlabbatch{1}.spm.stats.con.spmmat = cellstr(path_spmmat);
        
	for s = 1:szNames(2)
		% What contrasts to put in
		contrasts.matlabbatch{1}.spm.stats.con.consess{1}.tcon.name =  convertStringsToChars(names(s)); %names(s);
		contrasts.matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [weights(s,1) weights(s,2) weights(s,3) weights(s,4)];
		contrasts.matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
                        
		spm_jobman('run', contrasts.matlabbatch);

		path_contrast = fullfile(path_output, names(s));
		check_contrast = isfolder(path_contrast);
                        
		if check_contrast == false
			mkdir(path_contrast);
		end 
				
		% rename result SPM.mat file 
		path_spmmat = fullfile(path_output, 'SPM.mat');
		copyfile(path_spmmat, path_contrast);
		path_save = fullfile(path_output, 'save');
		filename = 'contrast' + names(s) + '_manager.mat';
		path_copy = fullfile(path_save, filename);
		copyfile(path_spmmat, path_copy);
		old_spmmat = fullfile(path_contrast, 'SPM.mat');
		new_spmmat = fullfile(path_contrast, 'contrast_manager.mat');
		movefile(old_spmmat, new_spmmat);
		
		list_files = dir(path_output);
		szFiles = size(list_files);
		
		% copy con* files to their associated contrast directories
		for f = 3:szFiles(1)
			path_file = fullfile(path_output, list_files(f).name);
			check_folder = isfolder(path_file);
			check_spm = startsWith(list_files(f).name, 'spm');
			check_contrast = startsWith(list_files(f).name, 'con');
			check_nifti = endsWith(list_files(f).name, '.nii');
			
			if check_folder == false && check_contrast == true && check_nifti == true
				copyfile(path_file, path_contrast);
			end 
			
			if check_folder == false && check_spm == true && check_nifti == true
				copyfile(path_file, path_contrast);
			end 
			
		end 
	end
end