class Database:
    def unzip(self):
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
                                    if f[-3:] == '.gz':
                                        check_symlink = os.path.islink(path_file);
                                        
                                        if check_symlink == True:
                                            path_symlink = os.readlink(path_file);
                                            list_words = path_symlink.split("/");
                                            filename = list_words[-1];
                                            real_symlink = current_directory;

                                            for w in range(3, len(list_words)):
                                                real_symlink = os.path.join(real_symlink, list_words[w]);
                            
                                            command_copy = 'cp ' + real_symlink + ' ' + path_fmri;
                                            os.system(command_copy);
                                            command_remove = 'rm ' + path_file;
                                            os.system(command_remove);
                                            old_file = os.path.join(path_fmri, filename);
                                            new_file = os.path.join(path_fmri, f);
                                            command_name = 'mv ' + old_file +  " " +  " " + new_file;
                                            os.system(command_name);     
                                            command_gzip = 'gzip -d ' + new_file;
                                            os.system(command_gzip);
                                            command_permissions = 'chmod + w ' + new_file;
                                            os.system(command_permissions);
                                
                                        if check_symlink == False:
                                            command_gzip = 'gzip -d ' + path_file;
                                            os.system(command_gzip);                        
                                