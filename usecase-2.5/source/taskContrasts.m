function taskContrasts(path_output)

    % setup batch job structure
    contrasts = struct;

    list_directories = dir(path_output);
    szDirectories = size(list_directories);
        
    for d = 3:szDirectories(1)
        path_directory = fullfile(path_output, list_directories(d).name);
        path_spmmat = fullfile(path_directory, 'SPM.mat');
        contrasts.matlabbatch{1}.spm.stats.con.spmmat = cellstr(path_spmmat);
        
        % What contrasts to put in
        contrasts.matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'ME_Rest';
        contrasts.matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0];
        contrasts.matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';       
        
        contrasts.matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'ME_0Back';
        contrasts.matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0];
        contrasts.matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';   
    
        contrasts.matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'ME_2Back';
        contrasts.matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0];
        contrasts.matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';      
        
        contrasts.matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'ME_4Back';
        contrasts.matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1];
        contrasts.matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none'; 
  
        contrasts.matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = '0Back_gt_R';
        contrasts.matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [-1 1 0 0];
        contrasts.matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none'; 
    
        contrasts.matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = '2Back_gt_R';
        contrasts.matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [-1 0 1 0];
        contrasts.matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none'; 
   
        contrasts.matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = '4Back_gt_R';
        contrasts.matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [-1 0 0 1];
        contrasts.matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none'; 
   
        contrasts.matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = '2Back_gt_0Back';
        contrasts.matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 -1 1 0];
        contrasts.matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';  
        
        contrasts.matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = '4Back_gt_0Back';
        contrasts.matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [0 -1 0 1];
        contrasts.matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';   
        
        contrasts.matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = '0Back_gt_2Back';
        contrasts.matlabbatch{1}.spm.stats.con.consess{10}.tcon.weights = [0 1 -1 0];
        contrasts.matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';  
        
        contrasts.matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = '0Back_gt_4Back';
        contrasts.matlabbatch{1}.spm.stats.con.consess{11}.tcon.weights = [0 1 0 -1];
        contrasts.matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';    
        
        contrasts.matlabbatch{1}.spm.stats.con.delete = 1;        % delete existing contrasts (0=No, 1=Yes)
           
        spm_jobman('run', contrasts.matlabbatch);
    end
end