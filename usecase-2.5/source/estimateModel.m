% estimate model function, the result is stored on save directory
function estimateModel(path_output, contrast)

    % setup batch job structure
    model_estimation = struct;
	 
    list_runs = dir(path_output);
    szRuns= size(list_runs);	
	
	for r = 3:szRuns(1)
		path_run = fullfile(path_output, list_runs(r).name);
		path_spmmat = fullfile(path_run, 'SPM.mat');

     	% spmmat
     	model_estimation.matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr(path_spmmat); %path_spmmat
   
     	% write_residuals
    	model_estimation.matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;

    	% method
		model_estimation.matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
        
		% run batch job
		spm_jobman('run',model_estimation.matlabbatch);
		clear matlabbatch;
	end
end