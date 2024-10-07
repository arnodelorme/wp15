import os
import sys
import gzip

current_directory = os.getcwd();
list_subjects = os.listdir(current_directory);

for sub in list_subjects:
    if sub[:3] == "sub":
        path_subject = os.path.join(current_directory, sub);
        list_sessions = os.listdir(path_subject);
        for ses in list_sessions:
            path_session = os.path.join(path_subject, ses);
            list_fmris = os.listdir(path_session);
            for s in list_sessions:
                path_session = os.path.join(path_subject, ses);
                list_directories = os.listdir(path_session);
                for d in list_directories:
                    path_fmri = os.path.join(path_session, d);
                    list_files = os.listdir(path_fmri);
                    for f in list_files:
                        path_file = os.path.join(path_fmri, f)                       
                        if f[-4:] == '.nii':
                            print(path_file);
                            os.chmod(path_file, 644);