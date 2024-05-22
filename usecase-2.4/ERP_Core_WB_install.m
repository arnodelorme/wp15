% add EEGLAB -- edit path as needed
addpath('eeglab2024.0');

% the rest runs automatically
eeglab('nogui')
pluginfolder = fullfile(fileparts(which('eeglab.m')),'plugins');
% addpath(genpath(pluginfolder));

index = 1;
plugin_askinstall('bids-matlab-tools','pop_importbids',1);
if ~exist('pop_importbids','file')
    folder2add = dir(fullfile(pluginfolder,"bids-matlab-tools*"));
    addpath(fullfile(pluginfolder,folder2add.name));
end
plugin_askinstall('zapline-plus','pop_zapline_plus',1);
if ~exist('pop_zapline_plus','file')
    folder2add = dir(fullfile(pluginfolder,"zapline-plus*"));
    addpath(fullfile(pluginfolder,folder2add.name));
end
plugin_askinstall('clean_rawdata','pop_clean_rawdata',1);
if ~exist('pop_clean_rawdata','file')
    folder2add = dir(fullfile(pluginfolder,"clean_rawdata*"));
    addpath(fullfile(pluginfolder,folder2add.name));
end
plugin_askinstall('picard', 'picard', 1);
if ~exist('picard','file')
    folder2add = dir(fullfile(pluginfolder,"PICARD*"));
    addpath(fullfile(pluginfolder,folder2add.name));
end
plugin_askinstall('ICLabel', 'pop_iclabel', 1);
if ~exist('pop_iclabel','file')
    folder2add = dir(fullfile(pluginfolder,"ICLabel*"));
    addpath(fullfile(pluginfolder,folder2add.name));
end
plugin_askinstall('Fieldtrip-lite', 'ft_prepare_neighbours', 1);
if ~exist('ft_prepare_neighbours','file')
    folder2add = dir(fullfile(pluginfolder,"Fieldtrip-lite*"));
    addpath(fullfile(pluginfolder,folder2add.name));
end
if ~exist('limo_eeg','file')
    folder2add = dir(fullfile(pluginfolder,"limo_tools*"));
    addpath(fullfile(pluginfolder,folder2add.name));
end

% if still not there return an error message
if ~exist('pop_importbids','file') || ...
        ~exist('pop_zapline_plus','file') || ...
        ~exist('pop_clean_rawdata','file') || ...
        ~exist('picard','file') || ...
        ~exist('pop_iclabel','file') || ...
        ~exist('ft_prepare_neighbours','file') || ...
        ~exist('limo_eeg','file')
    error('installation error when checking plugins');
else
    disp('all plugins found')
end
