% add EEGLAB
addpath('eeglab2024.0');

% the rest runs automatically
eeglab('nogui')

plugin_askinstall('bids-matlab-tools','pop_importbids',1);
plugin_askinstall('zapline-plus','pop_zapline_plus',1);
plugin_askinstall('clean_rawdata','pop_clean_rawdata',1);
plugin_askinstall('picard','picard',1);
plugin_askinstall('ICLabel','pop_iclabel',1);
plugin_askinstall('Fieldtrip-lite','ft_prepare_neighbours',1);

ft_defaults
