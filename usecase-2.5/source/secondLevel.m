% compare contrasts (pair - t-test)
function secondLevel(path_output)
        		
    list_files = dir(path_output);
    szFiles = size(list_files);
    
	disp(path_output);
	
    contrast_num = 0;
    
    for f = 3:szFiles(1)
        filename = list_files(f).name;
        if filename(1:4) == 'con_'
            contrast_num = contrast_num + 1;
        end
    end
                    
    contrast_begin = 'con_00';          %this is added to with 01; 02.....10; 11 in script
	path_spmmat = fullfile(path_output, 'contrast_manager.mat');
    pair = struct;
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make model: 2nd level paired-sample t-test
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
    if contrast_num > 6
        pairs_array = [1 3; 2 4; 7 9; 8 10];
        pairs_name = {'PreVsPost_TaskgtRest' 'PreVsPost_RestgtTask' 'PreVsPost_ME_Left' 'PreVsPost_ME_Right'};
    else
        pairs_array = [1 3; 2 4];
        pairs_name = ["PreVsPost_TaskgtRest" "PreVsPost_RestgtTask"];
    end
        
    path_pair = fullfile(path_output, 'pair');
    check_pair = isfolder(path_pair);
        
    if check_pair == false 
        mkdir(path_pair);
    end
	
	sz = size(pairs_name);
	       	
    for c = 1:sz(2)
        pathPair_directory = fullfile(path_pair, pairs_name(c));
        checkPair_directory = isfolder(pathPair_directory);
 
        if checkPair_directory == false
            mkdir(pathPair_directory);
        end
        
        pair.matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(pathPair_directory);     
        first_contrast_pair = ['0' num2str(pairs_array(c,1))]; 
                    
        if pairs_array(c,1) > 9 
            first_contrast_pair = first_contrast_pair(2:end); 
        end
        
        second_contrast_pair = ['0' num2str(pairs_array(c,2))];
            
        if pairs_array(c,2) > 9
            second_contrast_pair = second_contrast_pair(2:end); 
        end
        
        insert_contrast1 = [contrast_begin first_contrast_pair '.nii'];
        insert_contrast2 = [contrast_begin second_contrast_pair '.nii'];   
		           
        P = cellstr(spm_select('FPList', path_output, '^con_00.*\.nii$'));
        pair.matlabbatch{1}.spm.stats.factorial_design.des.pt.pair.scans{1,:} = P{1}; % new paired one
        
        R = cellstr(spm_select('FPList', path_output, insert_contrast2));
        pair.matlabbatch{1}.spm.stats.factorial_design.des.pt.pair.scans{2,:} = R{1}; % new paired one
                       
        %keyboard   
        spm_jobman('run', pair.matlabbatch); 
		clear matlabbatch;
		
		path_spmmat = fullfile(pathPair_directory, 'SPM.mat');
		new_spmmat1 = fullfile(pathPair_directory, 'secondLevel1.mat');
		movefile(path_spmmat, new_spmmat1);

		pair.matlabbatch{1}.spm.stats.fmri_est.spmmat= cellstr(new_spmmat1);
		spm_jobman('run',pair.matlabbatch);  
		new_spmmat2 = fullfile(pathPair_directory, 'secondLevel2.mat');
		movefile(path_spmmat, new_spmmat2);
        clear matlabbatch;
		 
		pair.matlabbatch{1}.spm.stats.con.spmmat= cellstr(new_spmmat2);
    
		pair.matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Pre_gt_Post'; % t Contrast (f contrast = fcon)
		pair.matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
    
		pair.matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Post_gt_Pre'; % t Contrast (f contrast = fcon)
		pair.matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
    
		spm_jobman('run', pair.matlabbatch);
		clear matlabbatch;
		 
    end %s (inputting each subjects contrast)
end