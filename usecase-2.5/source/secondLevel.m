function secondLevel(path_output, list_runs, contrast_name)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Make model: 2nd level One-sample t-test
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
    szRuns = size(list_runs);
    list_subjects = dir(path_output);
    szSubjects = size(list_subjects);
    
    for r = 3:szRuns(1)

        for sub = 3:szSubjects(1)
            path_subject = fullfile(path_output, list_subjects(sub).name);
            pathRun_event = fullfile(path_subject, list_runs(r).name);
            contrasts = dir(fullfile(pathRun_event, 'con*'));

            path_spmmat = fullfile(pathRun_event, 'SPM.mat');
            %pathContrast_manager = fullfile(pathRun_event, 'contrast_manager.mat');
            %movefile(path_spmmat, pathContrast_manager);

            pathCon_file = fullfile(pathRun_event, contrasts(1).name);
            %matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr(pathContrast_manager);
            
            matlabbatch{1}.spm.stats.con.spmmat = cellstr(path_spmmat);

            matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Main_Effect';         % t Contrast (f contrast = fcon)
            matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1];
    
            matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Main_Effect_Minus';         % t Contrast (f contrast = fcon)
            matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [-1];

            spm_jobman('run',matlabbatch);
            clear matlabbatch;
        end
    end 
