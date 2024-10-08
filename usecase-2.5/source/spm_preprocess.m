function structPreProcess = spm_preprocess(path_input)
	
    list_sessions = dir(path_input);
    szSessions = size(list_sessions);
		
    for s = 3:szSessions(1)
        path_session = fullfile(path_input, list_sessions(s).name);
        list_fmris = dir(path_session);
        szFmris = size(list_fmris);
		
		path_session1 = fullfile(path_input, 'ses-1');
		path_anat = fullfile(path_session1, 'anat');
		list_files = dir(path_anat);
		szFiles = size(list_files);

        for fm = 3:szFmris(1)
            path_fmri = fullfile(path_session, list_fmris(fm).name);
            check_fmri = isfolder(path_fmri);			
			structPreProcess = struct;

			list_runs = dir(path_fmri);
			szRuns = size(list_runs);
		
			disp('Step 1 -- Realign all volumes to first functional volume');
			realign(path_fmri);
			disp('Step 1 - Done!');
		end 
								
		path_source = '';
		
		for f = 3:szFiles(1)
			check_anat = startsWith(list_files(f).name, 'sub');
			check_nifti = endsWith(list_files(f).name, '.nii');
			
			if check_anat == true && check_nifti == true 
				path_source = fullfile(path_anat, list_files(f).name);
			end
		end 
		
		path_func = fullfile(path_session, 'func');
		
		disp('Step 3 -- Coregister structural image to first dynamic image');
		coreg(path_source, path_func);
		disp('Step 3 - Done!'); 
									
		disp('Step 4 -- Gaussian kernel smoothing of realigned data');
		smooth(path_anat);
		disp('Step 4 is done !');
     end
end
