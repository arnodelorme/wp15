% apply first level function based on nifti files (rsub*) and their associated text files (produced by the spm_preprocess function)
function firstLevel(path_username, path_input, path_output, struct_level1, struct_level2)
    
    path_workpackage = fullfile(path_username, 'wp15');
    
    design_stats = struct;
    
    list_sessions = dir(path_input);
	szSessions= size(list_sessions);
	
	for s = 3:szSessions(1)
		path_session = fullfile(path_input, list_sessions(s).name);
		pathSess_output = fullfile(path_output, list_sessions(s).name);
		list_fmris = dir(path_session);
		szFMRIs = size(list_fmris);
		
		path_func = fullfile(path_session, 'func');
		pathFunc_output = fullfile(pathSess_output, 'func');
		list_files = dir(path_func);
		szFiles = size(list_files);
			
		path_rsub = '';
		path_txt= '';
	
		index = 1;

		list_rSub = {};
		list_txt = {};
		
		% retrieve nifti files (rsub*) and their associated text files for each subject
		for f = 3:szFiles(1)
										
			check_txt = endsWith(list_files(f).name, '.txt');
				
			if check_txt == true 
				index = 1;
				start_pos = 0;
				final_pos = 0;
				filename = list_files(f).name;
				start_pos = strfind(list_files(f).name, 'rp_');
				final_pos = '';
									
				real_begin = -1;
				real_end = -1;
					
				final_pos = strfind(list_files(f).name, 'bold');
				real_begin = start_pos + 24;
				real_end = final_pos - 2;
				%end
									
				localizer = '';
					
				for r = real_begin:real_end
					localizer = append(localizer, filename(r));
				end 
					
				path_txt = fullfile(path_func, list_files(f).name);
										
				path_rFile = '';
					
				length = strlength(localizer);
					
				for g = 3:szFiles(1)
					
					check_rsub = startsWith(list_files(g).name, 'rsub');
					check_nifti = endsWith(list_files(g).name, '.nii');
						
					if check_rsub == true && check_nifti == true
						position = 0;
						position = strfind(list_files(g).name, localizer);
						if position > 0
							path_rFile = fullfile(path_func, list_files(g).name);
						end
					end
				end 
							
				% specify scans and multi_regression files 
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.scans = {};
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(path_rFile);				 
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg= cellstr(path_txt);
					
				% setup batch job structure
				% dir
				pathLocalizer_output = fullfile(pathFunc_output, localizer);
				check_folder = isfolder(pathLocalizer_output);

				 design_stats.matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(pathLocalizer_output); %{path_output};
				%end
					
				% timing
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.timing.units = struct_level1.timing_units;
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.timing.RT = struct_level1.timing_RT;
					
				% filling in onsets and durations for each condition
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = struct_level1.conditionName;
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = struct_level1.conditionOnset;
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = struct_level1.conditionDuration;
					
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = struct_level2.conditionName;
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = struct_level2.conditionOnset;
				design_stats.matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = struct_level2.conditionDuration;     
					
				% run batch job
				spm_jobman('run',design_stats.matlabbatch); 	
				
				path_save = fullfile(pathLocalizer_output, 'save');
				check_folder = isfolder(path_save);
				
				if check_folder == false 
					mkdir(path_save);
				end 
					
				% copy the SPM.mat result file to a save directory
				old_spmmat = fullfile(pathLocalizer_output, 'SPM.mat');
				cd(pathLocalizer_output);
				copyfile(old_spmmat, path_save);
				cd(path_save);
				old_spmmat = fullfile(path_save, 'SPM.mat');
				new_spmmat = fullfile(path_save, 'firstLevel.mat');
				movefile(old_spmmat, new_spmmat);
				S = load(new_spmmat);
				SPM = S.SPM;
				SPM.swd = path_save;
				save(new_spmmat);
				cd(path_workpackage);
				clear matlabbatch;
			end			
		end
	end
end