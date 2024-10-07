function coreg(path_source, path_func)
    
    spm('defaults','fmri');
    spm_jobman('initcfg');

    coreg_estimate = struct;
			
	listFunc_files = dir(path_func);
	szFunc = size(listFunc_files);
	
	for f = 3:szFunc(1)
		check_mean = startsWith(listFunc_files(f).name, "mean");
				
		if check_mean == true 
			path_ref = fullfile(path_func, listFunc_files(f).name);
					
			matlabbatch = {};
					
			disp(path_source);
			disp(path_ref);
					
			% Ref
			coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.ref = cellstr(path_ref);
        
			% Source
			coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.source = cellstr(path_source);
        
			% Eoptions
			coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
			coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
			coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
			coreg_estimate.matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        
			% Run
			spm_jobman('run',coreg_estimate.matlabbatch);
        
			clear matlabbatch;
		end 
	end
end