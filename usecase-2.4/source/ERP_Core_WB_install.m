% This code is shared under the CC0 license
%
% Copyright (C) 2024, SIESTA workpackage 15 team

% add EEGLAB -- edit path as needed
addpath('eeglab2024.0');

% the rest runs automatically
eeglab('nogui')
pluginfolder = fullfile(fileparts(which('eeglab.m')),'plugins');

%% follows https://eeglab.org/others/Compiled_EEGLAB.html#can-i-compile-eeglab-myself

plugin_askinstall('bids-matlab-tools', 'bids_export', true);
plugin_askinstall('zapline-plus','pop_zapline_plus',true);
plugin_askinstall('clean_rawdata', 'eegplugin_clean_rawdata', true);
plugin_askinstall('IClabel', 'eegplugin_iclabel', true);
plugin_askinstall('PICARD', 'picard', true);
plugin_askinstall('Fieldtrip-lite', 'ft_defaults', true);

%%
% FIXME, move directories one level up
%%

% this sets up the path to the plugins
eeglab('nogui')

rehash toolbox

% if still not there return an error message
if ~exist('pop_importbids.m','file') || ...
    ~exist('pop_zapline_plus.m','file') || ...
    ~exist('pop_clean_rawdata.m','file') || ...
    ~exist('picard.m','file') || ...
    ~exist('pop_iclabel.m','file') || ...
    ~exist('ft_prepare_neighbours.m','file') || ...
    ~exist('limo_eeg.m','file')
  error('installation error when checking plugins');
else
  disp('all plugins found')
end
