% apply first level function based on nifti files (rsub*) and their associated text files (produced by the spm_preprocess function)
function firstLevel(path_run, struct_levels)
        
	names = struct_levels.conditionName;
	split_names = split(names, '_');
	szSplit = size(split_names);
	sz_split = szSplit(1) - 1;

	index_onset = 1;
	index_duration = 1;

	save_onset = 1;
	save_duration = 1;

	for s = 1:sz_split
		name_event = split_names{s};
				
		% retrieve nifti files (rsub*) and their associated text files for each subject				
		struct_rsub = dir(fullfile(path_run, 'rsub*'));
		struct_txt = dir(fullfile(path_run, '*.txt'));

		path_rsub = fullfile(struct_rsub.folder, struct_rsub.name);
		path_txt = fullfile(struct_txt.folder, struct_txt.name);
												
		% specify scans and multi_regression files 
		matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(path_rsub);				 
		matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(path_txt);
					
		% setup batch job structure
		% dir
		matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(path_run); %{path_output};
					
		% timing
		matlabbatch{1}.spm.stats.fmri_spec.timing.units = struct_levels.timing_units;
		matlabbatch{1}.spm.stats.fmri_spec.timing.RT = struct_levels.timing_RT;
					
		onset = struct_levels.conditionOnset;
		duration = struct_levels.conditionDuration;
		szDuration = size(duration);

		subOnset = [];
		subDuration = [];
		
		index_onset = save_onset;
		while onset(index_onset) < onset(index_onset+1)
			subOnset(index_onset) = onset(index_onset);
			index_onset = index_onset + 1;
		end

		save_onset = index_onset - 1;
		
		index_duration = save_duration;

		if szDuration(2) > 1
			if duration(index_duration) < duration(index_duration+1)
				while duration(index_duration) < duration(index_duration+1)
					subDuration(index_duration) = duration(index_duration);
					index_duration = index_duration + 1;
				end 
			end 

			if duration(index_duration) == duration(index_duration+1)
				tmp_duration = index_duration;
				szSubOnset = size(subOnset);
				szSubDuration = size(subDuration);
				while szSubDuration(2) < szSubOnset(2)
					subDuration(index_duration) = duration(tmp_duration);
					index_duration = index_duration + 1;
					szSubDuration = size(subDuration);
				end
				save_duration = tmp_duration;
			end
		end 
		
		if szDuration(2) == 1
			szSubOnset = size(subOnset);
			szSubDuration = size(subDuration);
			while szSubDuration(2) < szSubOnset(2)
				subDuration(index_duration) = duration(1);
				index_duration = index_duration + 1;
				szSubDuration = size(subDuration);
			end
		end

		save_duration = index_duration - 1;
							
		matlabbatch{1}.spm.stats.fmri_spec.sess.cond(s).name = name_event;
		matlabbatch{1}.spm.stats.fmri_spec.sess.cond(s).onset = subOnset;
		matlabbatch{1}.spm.stats.fmri_spec.sess.cond(s).duration = subDuration;
	end
	%run batch job
	spm_jobman('run',matlabbatch); 	
	clear matlabbatch;
end
