
function whole_body_motion_csv(action)

if nargin < 1 || isempty(action)
    action = 'install';
end

switch lower(char(action))
    case 'install'
        installLogger();
    case 'save'
        try
            exportCsv();
        catch ME
            warning('Sim2Real:WholeBodyCSV', ...
                'Automatic whole-body CSV export failed: %s',ME.message);
        end
    otherwise
        error('Use whole_body_motion_csv(''install'') or whole_body_motion_csv(''save'').');
end
end

function installLogger()
mdl = 'Sim2Real_whole_body_motion';

if ~bdIsLoaded(mdl)
    load_system(mdl);
end

logger = [mdl '/WHOLE BODY CSV LOGGER'];

if getSimulinkBlockHandle(logger) < 0

    add_block('built-in/SubSystem',logger, ...
        'Position',[1950 1580 2130 1760]);

    oldLines = find_system(logger,'FindAll','on', ...
        'SearchDepth',1,'Type','line');

    for i = 1:numel(oldLines)
        delete_line(oldLines(i));
    end

    oldBlocks = find_system(logger,'SearchDepth',1,'Type','block');

    for i = 1:numel(oldBlocks)
        if ~strcmp(oldBlocks{i},logger)
            delete_block(oldBlocks{i});
        end
    end

    groups = {'left_leg','right_leg','waist','left_arm','right_arm'};
    types = {'pos_ref','pos_state','vel_state','tau_state'};
    names = {'ref','state','vel','tau'};

    for k = 1:4

        sourceName = [types{k} '_in'];
        selectorName = [types{k} '_selector'];
        y = 70 + (k-1)*300;

        add_block('built-in/Inport',[logger '/' sourceName], ...
            'Port',num2str(k),'Position',[40 y+50 70 y+70]);

        add_block('simulink/Signal Routing/Bus Selector', ...
            [logger '/' selectorName], ...
            'Position',[170 y 230 y+220]);

        fieldNames = cell(1,5);

        for j = 1:5
            fieldNames{j} = [groups{j} '_' types{k}];
        end

        set_param([logger '/' selectorName], ...
            'OutputSignals',strjoin(fieldNames,','));

        add_line(logger,[sourceName '/1'],[selectorName '/1'], ...
            'autorouting','on');

        ports = get_param([logger '/' selectorName],'PortHandles');

        for j = 1:5

            sink = sprintf('sink_%s_%s',names{k},groups{j});
            sy = y + 28 + 37*(j-1);

            add_block('built-in/Terminator',[logger '/' sink], ...
                'Position',[390 sy 410 sy+20]);

            add_line(logger,[selectorName '/' num2str(j)], ...
                [sink '/1'],'autorouting','on');

            logPort(ports.Outport(j), ...
                sprintf('WB_%s_%s',names{k},groups{j}));

        end
    end

    add_block('built-in/Inport',[logger '/motion_enable_in'], ...
        'Port','5','Position',[40 1320 70 1340]);

    add_block('built-in/Terminator',[logger '/sink_motion_enable'], ...
        'Position',[180 1320 200 1340]);

    add_line(logger,'motion_enable_in/1','sink_motion_enable/1', ...
        'autorouting','on');

    p = get_param([logger '/motion_enable_in'],'PortHandles');
    logPort(p.Outport(1),'WB_motion_enable');

    set_param(logger,'Position',[2040 1580 2200 1760]);

    add_line(mdl,'HIGH-LEVEL TRAJECTORY GENERATOR/1', ...
        'WHOLE BODY CSV LOGGER/1','autorouting','on');

    add_line(mdl,'SIM2REAL VARIANT SUBSYSTEM/3', ...
        'WHOLE BODY CSV LOGGER/2','autorouting','on');

    add_line(mdl,'SIM2REAL VARIANT SUBSYSTEM/4', ...
        'WHOLE BODY CSV LOGGER/3','autorouting','on');

    add_line(mdl,'SIM2REAL VARIANT SUBSYSTEM/2', ...
        'WHOLE BODY CSV LOGGER/4','autorouting','on');

    add_line(mdl,'motion_enable/1', ...
        'WHOLE BODY CSV LOGGER/5','autorouting','on');

else
    fprintf('WHOLE BODY CSV LOGGER already exists; keeping its wiring.\n');
end

set_param(mdl,'SignalLogging','on', ...
    'SignalLoggingName','logsout', ...
    'SignalLoggingSaveFormat','Dataset');

oldStop = get_param(mdl,'StopFcn');

if ~contains(oldStop,'whole_body_motion_csv(''save'')')

    hook = sprintf([ ...
        '\naddpath(fileparts(get_param(''%s'',''FileName'')));\n' ...
        'whole_body_motion_csv(''save'');\n'],mdl);

    set_param(mdl,'StopFcn',[oldStop newline hook]);

end

save_system(mdl);

fprintf('Automatic whole-body CSV logging installed.\n');
fprintf('RUN_MODE=0: whole_body_motion_sim_metrics.csv\n');
fprintf('RUN_MODE=1: whole_body_motion_exp_metrics.csv\n');

end

function logPort(port,name)

set_param(port,'DataLogging','on', ...
    'DataLoggingNameMode','Custom','DataLoggingName',name, ...
    'DataLoggingDecimateData','off', ...
    'DataLoggingLimitDataPoints','off');

end

function exportCsv()

mdl = 'Sim2Real_whole_body_motion';

runObj = Simulink.sdi.getCurrentSimulationRun(mdl);

assert(~isempty(runObj), ...
    'No SDI run was found for the active model.');

assert(evalin('base','exist(''RUN_MODE'',''var'')==1'), ...
    'RUN_MODE was not found in the base workspace.');

mode = evalin('base','RUN_MODE');

if isa(mode,'Simulink.Parameter')
    mode = mode.Value;
end

assert(isnumeric(mode) && isscalar(mode) && ...
    any(double(mode)==[0 1]), ...
    'RUN_MODE must be 0 or 1.');

if double(mode)==0
    stem = 'whole_body_motion_sim_metrics';
else
    stem = 'whole_body_motion_exp_metrics';
end

groups = {'left_leg','right_leg','waist','left_arm','right_arm'};
lengths = [6 6 3 7 7];

jointNames = { ...
    'LeftHipPitch','LeftHipRoll','LeftHipYaw','LeftKnee', ...
    'LeftAnklePitch','LeftAnkleRoll', ...
    'RightHipPitch','RightHipRoll','RightHipYaw','RightKnee', ...
    'RightAnklePitch','RightAnkleRoll', ...
    'WaistYaw','WaistRoll','WaistPitch', ...
    'LeftShoulderPitch','LeftShoulderRoll','LeftShoulderYaw', ...
    'LeftElbow','LeftWristRoll','LeftWristPitch','LeftWristYaw', ...
    'RightShoulderPitch','RightShoulderRoll','RightShoulderYaw', ...
    'RightElbow','RightWristRoll','RightWristPitch','RightWristYaw'};

[t,~] = findSignal(runObj,'WB_ref_left_leg');

n = numel(t);

assert(n>=3, ...
    'Fewer than three position-reference samples were logged.');

refs = NaN(n,29);
pos = NaN(n,29);
vel = NaN(n,29);
tau = NaN(n,29);

for j = 1:5

    indices = sum(lengths(1:j-1)) + (1:lengths(j));

    refs(:,indices) = groupSignal( ...
        runObj,['WB_ref_' groups{j}],t,lengths(j),true);

    pos(:,indices) = groupSignal( ...
        runObj,['WB_state_' groups{j}],t,lengths(j),true);

    vel(:,indices) = groupSignal( ...
        runObj,['WB_vel_' groups{j}],t,lengths(j),false);

    tau(:,indices) = groupSignal( ...
        runObj,['WB_tau_' groups{j}],t,lengths(j),false);

end

nomLeft = groupSignalAlternatives(runObj, ...
    {'<left_leg_pos_ref>','left_leg_pos_ref','WB_nom_left_leg'}, ...
    t,6);

nomRight = groupSignalAlternatives(runObj, ...
    {'<right_leg_pos_ref>','right_leg_pos_ref','WB_nom_right_leg'}, ...
    t,6);

nominal = refs;

nominal(:,1:6) = nomLeft;
nominal(:,7:12) = nomRight;

piCorrection = refs-nominal;

assert(any(all(isfinite(nominal(:,[1 4 7 10])),2)), ...
    'The four moving joint nominal references contain no valid samples.');

motionEnable = groupSignal(runObj,'WB_motion_enable',t,1,true);
motionEnable = motionEnable(:,1);

if any(motionEnable>=0.5)

    onset = find(motionEnable>=0.5,1,'first');
    tMotion = t(onset);

else

    tMotion = NaN;
    warning('Motion enable never became active during this run.');

end

T = table(t,repmat(double(mode),n,1),motionEnable, ...
    repmat(tMotion,n,1),t-tMotion, ...
    'VariableNames',{'Time_s','RUN_MODE','MotionEnable', ...
    'MotionStartTime_s','TimeSinceMotionEnable_s'});

for j = 1:29

    base = jointNames{j};

    T.([base '_NominalReference_rad']) = nominal(:,j);
    T.([base '_Reference_rad']) = refs(:,j);
    T.([base '_PICorrection_rad']) = piCorrection(:,j);
    T.([base '_Feedback_rad']) = pos(:,j);
    T.([base '_TrackingError_rad']) = refs(:,j)-pos(:,j);
    T.([base '_NominalTrackingError_rad']) = nominal(:,j)-pos(:,j);
    T.([base '_VelocityFeedback_rad_s']) = vel(:,j);
    T.([base '_TorqueFeedback_Nm']) = tau(:,j);

end

modelFile = get_param(mdl,'FileName');

assert(~isempty(modelFile), ...
    'Save the model before running the logger.');

folder = fileparts(char(modelFile));
file = nextCsvName(folder,stem);

writetable(T,file);

fprintf('\n[Sim2Real] Saved %d whole-body samples:\n%s\n',n,file);
fprintf('Motion enabled at t = %.3f s.\n',tMotion);
fprintf('Nominal reference, PI command, joint feedback and metrics signals exported.\n');

end

function X = groupSignalAlternatives(runObj,candidates,t,width)

for j = 1:numel(candidates)

    name = candidates{j};

    if hasSignal(runObj,name) || ...
            hasSignal(runObj,sprintf('%s(1,1)',name))

        X = groupSignal(runObj,name,t,width,true);
        return

    end
end

error('Nominal signal missing in SDI. Expected one of: %s', ...
    strjoin(candidates,', '));

end

function X = groupSignal(runObj,name,t,width,required)

X = NaN(numel(t),width);

if hasSignal(runObj,name)

    [ts,xs] = findSignal(runObj,name);

    assert(size(xs,2)==width, ...
        'Expected %d channels in SDI signal %s, found %d.', ...
        width,name,size(xs,2));

    for k = 1:width
        X(:,k) = interp1(ts,xs(:,k),t,'linear',NaN);
    end

    return

end

for k = 1:width

    indexedName = sprintf('%s(%d,1)',name,k);

    if ~hasSignal(runObj,indexedName)
        indexedName = sprintf('%s(%d)',name,k);
    end

    if ~hasSignal(runObj,indexedName)

        if required
            error('Required SDI signal %s, component %d, is missing.', ...
                name,k);
        else
            warning('Optional SDI signal %s, component %d, is missing.', ...
                name,k);
            continue
        end

    end

    [ts,xs] = findSignal(runObj,indexedName);

    assert(size(xs,2)==1, ...
        'Expected one channel in SDI signal %s.',indexedName);

    X(:,k) = interp1(ts,xs(:,1),t,'linear',NaN);

end
end

function tf = hasSignal(runObj,name)

tf = false;

for k = 1:double(runObj.SignalCount)

    sig = getSignalByIndex(runObj,k);

    if strcmp(char(sig.Name),name)
        tf = true;
        return
    end

end
end

function [t,x] = findSignal(runObj,name)

found = [];

for k = 1:double(runObj.SignalCount)

    sig = getSignalByIndex(runObj,k);

    if strcmp(char(sig.Name),name)
        found = sig;
        break
    end

end

assert(~isempty(found), ...
    'SDI signal "%s" was not found.',name);

v = found.Values;

assert(isa(v,'timeseries'), ...
    '%s is not a timeseries.',name);

t = double(v.Time(:));
a = double(v.Data);

if size(a,1)==numel(t)

    x = reshape(a,numel(t),[]);

elseif size(a,ndims(a))==numel(t)

    x = reshape(a,[],numel(t)).';

else

    error('Unsupported data dimensions for signal %s.',name);

end

[t,ix] = unique(t,'stable');
x = x(ix,:);

[t,ix] = sort(t);
x = x(ix,:);

assert(numel(t)>=2 && all(diff(t)>0), ...
    'Bad timestamps for %s.',name);

end

function f = nextCsvName(folder,stem)

f = fullfile(folder,[stem '.csv']);

if exist(f,'file')~=2
    return
end

for i = 1:99999

    f = fullfile(folder,sprintf('%s_%03d.csv',stem,i));

    if exist(f,'file')~=2
        return
    end

end

error('No free CSV filename for %s.',stem);

end
