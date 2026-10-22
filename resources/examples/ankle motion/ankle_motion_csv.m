function ankle_motion_csv(action)

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
            warning('Sim2Real:AnkleCSV', ...
                'Automatic ankle CSV export failed: %s', ME.message);
        end
    otherwise
        error('Use ankle_motion_csv(''install'') once; CSVs are then saved automatically.');
end
end

function names = ankleSignalNames()
names = { ...
    'pitch_pos_ref', 'pitch_pos_meas', 'pitch_pos_cmd', ...
    'pitch_pos_error', 'delta q pitch', ...
    'roll_pos_ref', 'roll_pos_meas', 'roll_pos_cmd', ...
    'roll_pos_error', 'delta q roll' ...
};
end

function installLogger()
mdl = 'Sim2Real_ankle_motion_2025a';
if ~bdIsLoaded(mdl)
    load_system(mdl);
end
controller = [mdl '/HIGH LEVEL CONTROLLER - PI'];

names = ankleSignalNames();
lines = find_system(controller, 'FindAll', 'on', ...
    'SearchDepth', 1, 'Type', 'line');

for i = 1:numel(names)
    desired = names{i};
    foundPort = [];
    for j = 1:numel(lines)
        if strcmp(get_param(lines(j), 'Name'), desired)
            foundPort = get_param(lines(j), 'SrcPortHandle');
            break
        end
    end
    assert(~isempty(foundPort) && foundPort ~= -1, ...
        'Could not locate the signal "%s" in %s.', desired, controller);
    set_param(foundPort, ...
        'DataLogging', 'on', ...
        'DataLoggingNameMode', 'Custom', ...
        'DataLoggingName', desired, ...
        'DataLoggingDecimateData', 'off', ...
        'DataLoggingLimitDataPoints', 'off');
end

set_param(mdl, ...
    'SignalLogging', 'on', ...
    'SignalLoggingName', 'logsout', ...
    'SignalLoggingSaveFormat', 'Dataset');

oldStop = get_param(mdl, 'StopFcn');
if isempty(strfind(oldStop, 'ankle_motion_csv(''save'')')) %#ok<STREMP>
    hook = sprintf(['\n%% Automatic ankle metrics CSV (installed once)\n' ...
        'addpath(fileparts(get_param(''%s'', ''FileName'')));\n' ...
        'ankle_motion_csv(''save'');\n'], mdl);
    set_param(mdl, 'StopFcn', [oldStop newline hook]);
end

save_system(mdl);
fprintf(['\nAutomatic ankle logging installed in %s.\n' ...
    'Press Run normally; the CSV will be written at simulation stop.\n' ...
    'RUN_MODE=0: ankle_motion_sim_metrics.csv\n' ...
    'RUN_MODE=1: ankle_motion_exp_metrics.csv\n' ...
    'Existing CSVs will NOT be overwritten.\n\n'], mdl);
end

function exportCsv()
mdl = 'Sim2Real_ankle_motion_2025a';

assert(evalin('base', 'exist(''RUN_MODE'', ''var'') == 1'), ...
    'RUN_MODE does not exist in the base workspace.');
mode = evalin('base', 'RUN_MODE');
if isa(mode, 'Simulink.Parameter')
    mode = mode.Value;
end
assert(isnumeric(mode) && isscalar(mode) && any(double(mode) == [0 1]), ...
    'RUN_MODE must be 0 (MuJoCo) or 1 (physical G1).');

if mode == 0
    stem = 'ankle_motion_sim_metrics';
    environment = 'MuJoCo';
else
    stem = 'ankle_motion_exp_metrics';
    environment = 'Physical G1';
end

runObj = Simulink.sdi.getCurrentSimulationRun(mdl);
assert(~isempty(runObj), ...
    'No SDI run was found. Install the logger and run the model again.');

[t, pitchRef] = readLoggedSignal(runObj, 'pitch_pos_ref');
pitchMeas   = alignLoggedSignal(runObj, 'pitch_pos_meas',  t);
pitchCmd    = alignLoggedSignal(runObj, 'pitch_pos_cmd',   t);
pitchPIErr  = alignLoggedSignal(runObj, 'pitch_pos_error', t);
pitchDelta  = alignLoggedSignal(runObj, 'delta q pitch',   t);
rollRef     = alignLoggedSignal(runObj, 'roll_pos_ref',   t);
rollMeas    = alignLoggedSignal(runObj, 'roll_pos_meas',  t);
rollCmd     = alignLoggedSignal(runObj, 'roll_pos_cmd',   t);
rollPIErr   = alignLoggedSignal(runObj, 'roll_pos_error', t);
rollDelta   = alignLoggedSignal(runObj, 'delta q roll',   t);

pitchErr    = pitchRef - pitchMeas;
rollErr     = rollRef - rollMeas;
pitchCmdErr = pitchCmd - pitchMeas;
rollCmdErr  = rollCmd - rollMeas;
pitchOk = isfinite(pitchErr);
rollOk = isfinite(rollErr);
assert(nnz(pitchOk) >= 3 && nnz(rollOk) >= 3, ...
    'Insufficient finite feedback samples to export metrics.');

pRMSE = sqrt(mean(pitchErr(pitchOk).^2));
pMAE = mean(abs(pitchErr(pitchOk)));
pPeak = max(abs(pitchErr(pitchOk)));
pShift = responseShiftMs(t(pitchOk), pitchRef(pitchOk), pitchMeas(pitchOk));
rRMSE = sqrt(mean(rollErr(rollOk).^2));
rMAE = mean(abs(rollErr(rollOk)));
rPeak = max(abs(rollErr(rollOk)));
rShift = responseShiftMs(t(rollOk), rollRef(rollOk), rollMeas(rollOk));

n = numel(t);
T = table( ...
    t, repmat(double(mode), n, 1), ...
    pitchRef, pitchMeas, pitchCmd, pitchPIErr, pitchDelta, ...
    pitchErr, pitchCmdErr, ...
    rollRef, rollMeas, rollCmd, rollPIErr, rollDelta, ...
    rollErr, rollCmdErr, ...
    repmat(pRMSE,n,1), repmat(pMAE,n,1), ...
    repmat(pPeak,n,1), repmat(pShift,n,1), ...
    repmat(rRMSE,n,1), repmat(rMAE,n,1), ...
    repmat(rPeak,n,1), repmat(rShift,n,1), ...
    'VariableNames', { ...
        'Time_s', 'RUN_MODE', ...
        'Pitch_Reference_rad', 'Pitch_Feedback_rad', ...
        'Pitch_Command_rad', 'Pitch_PI_Error_rad', ...
        'Pitch_PI_Correction_rad', 'Pitch_TrackingError_rad', ...
        'Pitch_CommandError_rad', ...
        'Roll_Reference_rad', 'Roll_Feedback_rad', ...
        'Roll_Command_rad', 'Roll_PI_Error_rad', ...
        'Roll_PI_Correction_rad', 'Roll_TrackingError_rad', ...
        'Roll_CommandError_rad', ...
        'Pitch_RMSE_rad', 'Pitch_MAE_rad', ...
        'Pitch_PeakAbsError_rad', 'Pitch_ResponseShift_ms', ...
        'Roll_RMSE_rad', 'Roll_MAE_rad', ...
        'Roll_PeakAbsError_rad', 'Roll_ResponseShift_ms' ...
    });

modelFile = get_param(mdl, 'FileName');
assert(~isempty(modelFile), 'The Simulink model must be saved to disk.');
folder = fileparts(char(modelFile));
filename = uniqueCsvName(folder, stem);
writetable(T, filename);

fprintf('\n[Sim2Real] Saved %d ankle samples (%s):\n%s\n', ...
    height(T), environment, filename);
fprintf('Pitch: RMSE %.6f rad | MAE %.6f rad | Peak %.6f rad\n', ...
    pRMSE, pMAE, pPeak);
fprintf('Roll:  RMSE %.6f rad | MAE %.6f rad | Peak %.6f rad\n\n', ...
    rRMSE, rMAE, rPeak);
end

function filename = uniqueCsvName(folder, stem)
filename = fullfile(folder, [stem '.csv']);
if exist(filename,'file') ~= 2
    return
end
for k = 1:99999
    filename = fullfile(folder, sprintf('%s_%03d.csv',stem,k));
    if exist(filename,'file') ~= 2
        return
    end
end
error('No unused CSV filename available for %s.', stem);
end

function [t, x] = readLoggedSignal(runObj, signalName)
matched = [];
for i = 1:double(runObj.SignalCount)
    sig = getSignalByIndex(runObj, i);
    if strcmp(char(sig.Name), signalName)
        matched = sig;
        break
    end
end
assert(~isempty(matched), ...
    'Signal "%s" was not found in the current SDI run.', signalName);

values = matched.Values;
assert(isa(values, 'timeseries'), ...
    'Signal "%s" did not produce a timeseries.', signalName);
t = double(values.Time(:));
x = double(squeeze(values.Data));
assert(isvector(x) && numel(x) == numel(t), ...
    'Signal "%s" must be scalar at every sample.', signalName);
x = x(:);
[t, inds] = unique(t,'stable');
x = x(inds);
[t, inds] = sort(t);
x = x(inds);
assert(numel(t) >= 3 && all(diff(t) > 0), ...
    'Signal "%s" has insufficient ordered timestamps.', signalName);
end

function x = alignLoggedSignal(runObj, signalName, t)
[ts, xs] = readLoggedSignal(runObj, signalName);
x = interp1(ts, xs, t, 'linear', NaN);
end

function shiftMs = responseShiftMs(t, r, y)
shiftMs = NaN;
t = t(:); r = r(:); y = y(:);
if numel(t) < 10 || any(diff(t) <= 0)
    return
end
dt = median(diff(t));
if ~isfinite(dt) || dt <= 0
    return
end
maxLag = min(round(0.2/dt), floor(numel(t)/4));
if maxLag < 1
    return
end
r = r - mean(r); y = y - mean(y);
if norm(r) < 1e-9 || norm(y) < 1e-9
    return
end
best = -Inf;
for lag = 0:maxLag
    if lag == 0
        a = r; b = y;
    else
        a = r(1:end-lag); b = y(1+lag:end);
    end
    score = (a.'*b) / (norm(a)*norm(b)+eps);
    if score > best
        best = score;
        shiftMs = lag*dt*1000;
    end
end
end
