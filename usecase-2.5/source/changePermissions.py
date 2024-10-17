import os
import stat
import sys
import gzip

current_directory = os.getcwd();
list_strings = current_directory.split('/');
path_home = '/' + list_strings[1];
path_username = os.path.join(path_home, list_strings[2]);
path_input = os.path.join(path_username, 'ds004934');
list_subjects = os.listdir(path_input);
print(list_subjects);

for sub in list_subjects:
    if sub[:3] == "sub":
        path_subject = os.path.join(path_input, sub)
        list_fmris = os.listdir(path_subject)
        for mri in list_fmris:
            path_fmri =  os.path.join(path_subject, mri)
            check_folder = os.path.isfile(path_fmri)
            if check_folder == False:
                list_files = os.listdir(path_fmri);
                for  f in list_files:   
                    path_file = os.path.join(path_fmri, f)                  
                    if f[-4:] == '.nii':
                        print(path_file)
                        os.chmod(path_file, 0o644)
