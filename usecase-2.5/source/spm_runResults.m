function spm_runResults(path_contrast, contrast)

    spm('defaults','fmri');
    spm_jobman('initcfg');
    % setup batch job structure
    results = struct;
		
	path_contrastManager = fullfile(path_contrast, 'contrast_manager.mat');
	path_spmmat = fullfile(path_contrast, 'SPM.mat');
	movefile(path_contrastManager, path_spmmat);

     % spmmat
	 results.matlabbatch{1}.spm.stats.results.spmmat = cellstr(path_spmmat);
    
     % conspec
	 results.matlabbatch{1}.spm.stats.results.conspec.titlestr = contrast;
	 results.matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
	 results.matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'FWE';
	 results.matlabbatch{1}.spm.stats.results.conspec.thresh = 0.0500;
	 results.matlabbatch{1}.spm.stats.results.conspec.extent = 20;
	 results.matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
	 results.matlabbatch{1}.spm.stats.results.conspec.mask.none = 1; 
	 results.matlabbatch{1}.spm.stats.results.conspec.sections = 1;
	 
      % units
     results.matlabbatch{1}.spm.stats.results.units = 1;
    
     % export
     results.matlabbatch{1}.spm.stats.results.export{1}.ps = 1;

    % run batch job 
    spm_jobman('run',results.matlabbatch);
  
end