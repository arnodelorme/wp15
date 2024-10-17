% appply some contrasts to SPM.mat file  
function contrasts(path_output, names, convec)

    contrasts = struct;    
    szNames = size(names);
	            
	list_runs = dir(path_output);
	szRuns = size(list_runs);
	
	for s = 1:szNames(2)

		for r = 3:szRuns(1)
			path_run = fullfile(path_output, list_runs(r).name);
			path_spmmat = fullfile(path_run, 'SPM.mat');

			contrasts.matlabbatch{1}.spm.stats.con.spmmat = cellstr(path_spmmat);

			% What contrasts to put in
			matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = convec;
			matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
                        
			spm_jobman('run', contrasts.matlabbatch);
		end
	end
end