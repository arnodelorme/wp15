addpath('eeglab2024.0');
eeglab; % otherwise it won't find plugin_askinstall

plugin_askinstall('bids-matlab-tools',[],1);
plugin_askinstall('zapline-plus',[],1);
plugin_askinstall('picard',[],1);

addpath(fullfile(pwd, 'eeglab2024.0/plugins/zapline-plus1.2.1/zapline-plus-1.2.1');
addpath(fullfile(pwd, 'eeglab2024.0/plugins/bids-matlab-tools8.0/bids-matlab-tools');
addpath(fullfile(pwd, 'eeglab2024.0/plugins/Fieldtrip-lite20240111/fieldtrip-20240111');
addpath(fullfile(pwd, 'eeglab2024.0/plugins/PICARD1.0/picard-matlab');
