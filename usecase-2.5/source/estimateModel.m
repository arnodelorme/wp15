% estimate model function, the result is stored on save directory
function estimateModel(path_username, path_output, contrast)

    path_workpackage = fullfile(path_username, 'wp15');

    % setup batch job structure
    spm('defaults','fmri');
    spm_jobman('initcfg');
    model_estimation = struct;
	        
    list_directories = dir(path_output);
    szDirectories = size(list_directories);	
	
	path_spmmat = '';
	
	if contrast == false
		path_spmmat = fullfile(path_output,  'SPM.mat');	
	end
		
	if contrast == true
		path_spmmat = fullfile(path_output, 'SPM.mat');	
	end
							
     % spmmat
     model_estimation.matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr(path_spmmat); %path_spmmat
   
     % write_residuals
    model_estimation.matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;

    % method
	model_estimation.matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
        
	% run batch job
	spm_jobman('run',model_estimation.matlabbatch);
				        
	path_estimate = '';
	path_save = fullfile(path_output, 'save');
		
	if contrast == false 
		path_estimate = fullfile(path_save, 'estimate1stLevel_model.mat');
	end
		
	if contrast == true 
		path_estimate = fullfile(path_output, 'estimate2ndLevel_model.mat');
	end 
	
	% copy result SPM.mat file in save directory
	copyfile(path_spmmat, path_estimate);  
	S = load(path_estimate);
	SPM = S.SPM;
	SPM.swd = path_save;	
	save(path_spmmat);
	cd(path_workpackage);
end