% apply a list of transformations on niftii files and written results to the correct output directory
function onePatient(path_username, path_patient, path_output, cellOnset, cellDuration)

	% apply list of transformations to fMRIs
   spm_preprocess(path_patient);
    disp('preProcess is done !');
		
	path_input = fullfile(path_username, 'input');
	list_files = dir(path_input);
	szFiles = size(list_files);
		
	% apply first level parameters to files produced by spm_preprocess function
    firstLevelParameters = struct('timing_units', '', 'timing_RT', '', 'conditionName', '', 'conditionOnset', '', 'conditionDuration', '');
    firstLevelParameters = create_levelParameters(2, 'intact', [25 75 125 175 225 275], 25);
    secondLevelParameters = struct('timing_units', '', 'timing_RT', '', 'conditionName', '', 'conditionOnset', '', 'conditionDuration', '');
    secondLevelParameters = create_levelParameters(2, 'scrambled', [50 100 150 200 250 300], 25);
	firstLevel(path_username, path_patient, path_output, firstLevelParameters, secondLevelParameters);
    disp('specify first level is done !');
		  
	 list_sessions = dir(path_output);
	 szSessions = size(list_sessions);
	 
	contrast_names = ["ME_0Back" "ME_2Back" "ME_0Back" "0Back_gt_R" "2Back_gt_R"];
    weights = [0 1 0 0; 0 0 1 0; 0 0 0 1; -1 1 0 0; -1 0 1 0; -1 0 0 1];
	
	% estimate model and apply contrasts on files produced by the previous steps 
	 for s = 3:szSessions(1)
		path_session = fullfile(path_output, list_sessions(s).name);
		path_func = fullfile(path_session, 'func');
		list_localizers = dir(path_func);
		szLoc = size(list_localizers);
		for l = 3:szLoc(1)
			path_localizer = fullfile(path_func, list_localizers(l).name);
			
			estimateModel(path_username, path_localizer, false);
			disp('estimate model is done !');
			
			contrasts(path_localizer, contrast_names, weights);
			disp('contrats is done !');
			
		end 
	end
	
	% apply the second level analysis to files produced by the previous steps 
	for s = 3:szSessions(1)
		path_session = fullfile(path_output, list_sessions(s).name);
		path_func = fullfile(path_session, 'func');
		list_localizers = dir(path_func);
		szLoc = size(list_localizers);
		for l = 3:szLoc(1)
			path_localizer = fullfile(path_func, list_localizers(l).name);
			list_contrasts = dir(path_localizer);
			szContrasts = size(list_contrasts);
			secondLevel(path_localizer);
			disp('secondLevel is done !');
		end
	end
	
	% apply estimateModel function to files producted by the previous steps
	for s = 3:szSessions(1)
		path_session = fullfile(path_output, list_sessions(s).name);
		path_func = fullfile(path_session, 'func');
		list_localizers = dir(path_func);
		szLoc = size(list_localizers);
		for l = 3:szLoc(1)
			path_localizer = fullfile(path_func, list_localizers(l).name);
			path_pair = fullfile(path_localizer, 'pair');
			list_contrasts = dir(path_pair);
			szContrasts = size(list_contrasts);
			for c = 3:szContrasts(1)
				path_contrast = fullfile(path_pair, list_contrasts(c).name);
				estimateModel(path_username, path_contrast, true);
				disp('estimate model is done !');
			end
		end
	end 
end
