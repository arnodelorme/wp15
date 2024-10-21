function realign(path_input, funcfiles)

if nargin<2
  funcfiles = {};
end

realign_estimate_reslice = struct;

if isempty(funcfiles)
  list_files = dir(fullfile(path_input, 'sub*nii'));
  funcfiles  = {list_files.name}';
end

for f = 1:numel(funcfiles)
  check_nifti = endsWith(funcfiles{f}, '.nii');

  if check_nifti == true
    path_file = fullfile(path_input, funcfiles{f});
    disp(path_file);

    V = spm_vol(path_file);
    Vsize = size(V);
    Nt = Vsize(1);
    fnms={};

    for i = 1:Nt
      fnms{i} = [path_file ',' num2str(i) ];
    end

    %Data
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.data={fnms'};
    realign_estimate_reslice.matlabbatch{1}.spm.temporal.st.nslices = 38;
    realign_estimate_reslice.matlabbatch{1}.spm.temporal.st.tr = 2;
    realign_estimate_reslice.matlabbatch{1}.spm.temporal.st.ta = 1.94736842105263;
    realign_estimate_reslice.matlabbatch{1}.spm.temporal.st.refslice = 19;
    realign_estimate_reslice.matlabbatch{1}.spm.temporal.st.prefix = 'a';

    % Eoptions
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';

    %Roptions
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    realign_estimate_reslice.matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

    % Run
    spm_jobman('run', realign_estimate_reslice.matlabbatch);
  end
end
end