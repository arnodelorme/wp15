function segmentation(path_input)
    
	spm('defaults','fmri');
    spm_jobman('initcfg');
    segmentation = struct;

    matlabbatch = {};
    list_files = dir(path_input);
	szFiles = size(list_files);
	
	path_file = '';
	
	for f = 3:szFiles(1)
		check_sub = startsWith(list_files(f).name, 'sub');
		check_nifti = endsWith(list_files(f).name, '.nii');
		
		if check_sub == true && check_nifti == true
			path_file = fullfile(path_input, list_files(f).name);
			V = spm_vol(path_file);
		
			disp(path_file);
			disp(V);
			
			% Channel
			segmentation.matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
			segmentation.matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
			segmentation.matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
			segmentation.matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(path_file);  

			% Warp
			segmentation.matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
			segmentation.matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
			segmentation.matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
			segmentation.matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;  
    
			% Run
			spm_jobman('run',segmentation.matlabbatch); 
        
			clear matlabbatch;
			
		end 
	end
end