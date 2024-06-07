% add EEGLAB -- edit path as needed
addpath('eeglab2024.0');

% the rest runs automatically
eeglab('nogui')
pluginfolder = fullfile(fileparts(which('eeglab.m')),'plugins');

%%

plugin_askinstall('bids-matlab-tools','pop_importbids',1);
plugin_askinstall('zapline-plus','pop_zapline_plus',1);
plugin_askinstall('clean_rawdata','pop_clean_rawdata',1);
plugin_askinstall('picard', 'picard', 1);
plugin_askinstall('ICLabel', 'pop_iclabel', 1);
plugin_askinstall('Fieldtrip-lite', 'ft_prepare_neighbours', 1);

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
