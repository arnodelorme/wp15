% create output architecture directory based on input directory
function createDataStructure(path_input, path_output)
       
    list_patients = dir(path_input);
    sz = size(list_patients);
    
    for p = 3:sz(1)
		path_subject = fullfile(path_input, list_patients(p).name);
		check_sub = startsWith(list_patients(p).name, 'sub');
		check_folder = isfolder(path_subject);
		
        if check_folder == true && check_sub == true
			pathSub_output = fullfile(path_output, list_patients(p).name);
			checkSub_output = isfolder(pathSub_output);
			
			if checkSub_output == false 
				mkdir(pathSub_output);
			end
						
			list_sessions = dir(path_subject);
			szSessions = size(list_sessions);
			
			for s = 3:szSessions(1)
				path_session = fullfile(path_subject, list_sessions(s).name);
				pathSess_output = fullfile(pathSub_output, list_sessions(s).name);
				check_session = isfolder(pathSess_output);
				
				if check_session == false 
					mkdir(pathSess_output);
				end
				
				list_fmris = dir(path_session);
				szFMRIs = size(list_fmris);
				
				for fm = 3:szFMRIs(1)
					path_fmri = fullfile(path_session, list_fmris(fm).name);
					pathFMRI_output = fullfile(pathSess_output, list_fmris(fm).name);
					check_fmri = isfolder(pathFMRI_output);
					
					if check_fmri == false
						mkdir(pathFMRI_output);
					end 
					
					list_files = dir(path_fmri);
					szFiles = size(list_files);
					
					for f = 3:szFiles(1)
						check_nifti = endsWith(list_files(f).name, '.nii');
						start_pos = 0;
						final_pos = 0;
						start_pos = strfind(list_files(f).name, 'task-');
						final_pos = strfind(list_files(f).name, 'bold');
						
						if check_nifti == true
							if start_pos > 0
								if  final_pos > 0
									path_file = fullfile(path_fmri, list_files(f).name);
									filename = list_files(f).name;
									real_begin = start_pos + 5;
									real_end = final_pos - 2;
																		
									foldername = '';		
									
									for t = real_begin:real_end
										foldername = append(foldername, filename(t));
									end 
									
									path_localizer = fullfile(pathFMRI_output, foldername);
									check_exist = isfolder(path_localizer);
									
									if check_exist == false 
										mkdir(path_localizer);
									end 									
								end 
							end
						end
						
					end
				end
			end
		end 
    end
end