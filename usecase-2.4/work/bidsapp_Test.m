% bidsapp_Test
% Tests the behaviour of ERP_Core_WB.m
% called via bidsapp -- edit line 7 to ensure the path is correct
% run in command window from code folder as:
% results = runtests('bidsapp_Test'); table(results)

InputDataset = fileparts(pwd); % running from /work (understood as BIDS code) this should be correct

% set a bunch of options
tasks           = {'MMN','N400'};
Subjects        = {'sub-001','sub-002','sub-008','sub-010','sub-011','sub-022','sub-030','sub-031'};
high_pass       = 0.1;
ICAname         = 'runica';
epoch_window    = [-0.5 0.5];
baseline_window = [-500 -100];
analysis_window = [-100 500];
estimation      = 'OLS';
nboot           = 655;
tfce            = false;
OutputLocation  = [fileparts(dataset_folder) filesep 'bidsapp_Test'];

% compute and assert
bidsapp(InputDataset,OutputLocation,'participant','TaskLabel',tasks,'SubjectLabel',...
    Subjects, 'high_pass',high_pass,'ICAname',ICAname,'epoch_window',epoch_window,...
    'baseline_window',baseline_window,'analysis_window',analysis_window);
% checks tasks are present
taskD = dir(OutputLocation); taskD(1:2) = [];
whichtasks = arrayfun(@(x) any(strcmpi(x.name,tasks)),taskD);
assert(sum(whichtasks)==length(tasks),...
    sprintf('some tasks are missing: %s\n',tasks{whichtasks==0}))
% which subjects
for t = 1:size(taskD,1)
    sub = dir(fullfile(taskD(t).folder,[taskD(t).name filesep 'derivatives' filesep 'sub-*']));
    assert(size(sub,1)==length(Subjects)-1,...
        sprintf('the number of subjects in derivatives %g does match was it expsted %g',...
        size(sub,1),length(Subjects)-1));
end

% second level
Outputfolder = fullfile(OutputLocation,'group_level');
bidsapp(OutputLocation,Outputfolder,'group','nboot',nboot,'tfce',tfce)
whichfolders = dir(Outputfolder); whichfolders(1:2) = []; 
for t=1:length(tasks)
    assert(sum(arrayfun(@(x) any(strcmpi(x.name,tasks(t))),whichfolders))==1,...
        sprintf('2nd level error, task %s missing',tasks{t}))
end

% ----------
% clean up
% ----------
rmdir(OutputLocation, 's')

