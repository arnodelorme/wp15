import os
import sys
import gzip

current_directory = os.getcwd();
list_strings = current_directory.split('/');
path_home = '/' + list_strings[1];
path_username = os.path.join(path_home, list_strings[2]);
path_input = os.path.join(path_username, 'ds004934');
list_subjects = os.listdir(path_input);

for sub in list_subjects:
    if sub[:3] == "sub":
        path_subject = os.path.join(path_input, sub)
        list_fmris = os.listdir(path_subject)
        for fmri in list_fmris:
            path_fmri = os.path.join(path_subject, fmri)
            check_folder = os.path.isfile(path_fmri)
            if check_folder == False:
                list_files = os.listdir(path_fmri)
                for f in list_files:
                    path_file = os.path.join(path_fmri, f) 
                    if f[-3:] == '.gz':
                        check_symlink = os.path.islink(path_file)
                        if check_symlink == True:
                            path_symlink = os.readlink(path_file)
                            list_words = path_symlink.split("/")
                            filename = list_words[-1]
                            real_symlink = os.path.join(path_input, '.git')

                            for w in range(3, len(list_words)):
                                real_symlink = os.path.join(real_symlink, list_words[w])
                            
                            command_copy = 'cp ' + real_symlink + ' ' + path_fmri
                            os.system(command_copy)
                            command_remove = 'rm ' + path_file
                            os.system(command_remove)
                            old_file = os.path.join(path_fmri, filename)
                            new_file = os.path.join(path_fmri, f)
                            command_name = 'mv ' + old_file +  " " +  " " + new_file
                            os.system(command_name)
                            command_gzip = 'gzip -d ' + new_file
                            print(command_gzip)
                            os.system(command_gzip)
                                
                        if check_symlink == False:
                            command_gzip = 'gzip -d ' + path_file
                            os.system(command_gzip);                        
                                
            