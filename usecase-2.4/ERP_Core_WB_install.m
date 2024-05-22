% add EEGLAB -- edit path as needed
addpath('eeglab2024.0');

% the rest runs automatically
eeglab('nogui')
pluginfolder = fullfile(fileparts(which('eeglab.m')),'plugins');

plugin_askinstall('bids-matlab-tools',[],1);
if ~exist('pop_importbids','file')
    try 
        folder2add = dir(fullfile(pluginfolder,"bids-matlab-tools*"));
        addpath(fullfile(pluginfolder,folder2add.name)); 
    end
end
plugin_askinstall('zapline-plus',[],1);
if ~exist('pop_zapline_plus','file')
    try 
        folder2add = dir(fullfile(pluginfolder,"zapline-plus*"));
        addpath(fullfile(pluginfolder,folder2add.name)); 
    end
end
plugin_askinstall('clean_rawdata',[],1);
if ~exist('pop_clean_rawdata','file')
    try 
        folder2add = dir(fullfile(pluginfolder,"clean_rawdata*"));
        addpath(fullfile(pluginfolder,folder2add.name)); 
    end
end
plugin_askinstall('picard', [], 1);
if ~exist('picard','file')
    try 
        folder2add = dir(fullfile(pluginfolder,"PICARD*"));
        addpath(fullfile(pluginfolder,folder2add.name)); 
    end
end
plugin_askinstall('ICLabel', [], 1);
if ~exist('pop_iclabel','file')
    try 
        folder2add = dir(fullfile(pluginfolder,"ICLabel*"));
        addpath(fullfile(pluginfolder,folder2add.name)); 
    end
end
plugin_askinstall('Fieldtrip-lite', [], 1);
if ~exist('ft_prepare_neighbours','file')
    try 
        folder2add = dir(fullfile(pluginfolder,"Fieldtrip-lite*"));
        addpath(fullfile(pluginfolder,folder2add.name)); 
    end
end
if ~exist('limo_eeg','file')
    try 
        folder2add = dir(fullfile(pluginfolder,"limo_tools*"));
        addpath(fullfile(pluginfolder,folder2add.name)); 
    end
end

% if still not there return an error message
if ~exist('pop_importbids','file') || ...
        ~exist('pop_zapline_plus','file') || ...
        ~exist('pop_clean_rawdata','file') || ...
        ~exist('picard','file') || ...
        ~exist('pop_iclabel','file') || ...
        ~exist('ft_prepare_neighbours','file') || ...
        ~exist('limo_eeg','file')
    error('1 or more of the necessary plugins is not found');
else
    disp('all plugins found')
    savepath
end
