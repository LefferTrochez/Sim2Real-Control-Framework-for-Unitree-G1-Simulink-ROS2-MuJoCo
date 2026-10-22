
function ankle_motion_analysis()

analysisWindow_s = [3.0 5.0];
plotWindow_s = [3.0 5.0];
maxResponseShift_s = 0.20;
configuredBackend_ms = 1.0;
configuredLogger_Hz = 500.0;
figureResolution_dpi = 300;

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder)
    scriptFolder = pwd;
end

outputFolder = fullfile(scriptFolder, 'ankle_motion_analysis_results');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

simFile = locateLatestCsv(scriptFolder, 'ankle_motion_sim_metrics');
expFile = locateLatestCsv(scriptFolder, 'ankle_motion_exp_metrics');

if isempty(simFile) && isempty(expFile)
    error('No ankle motion CSV files found.');
end

sim = [];
expData = [];

if ~isempty(simFile)
    sim = loadAnkleData(simFile, 0);
end

if ~isempty(expFile)
    expData = loadAnkleData(expFile, 1);
end

simMetrics = evaluateRun(sim, analysisWindow_s, maxResponseShift_s);
expMetrics = evaluateRun(expData, analysisWindow_s, maxResponseShift_s);

createComparisonFigure(sim, expData, plotWindow_s, ...
    outputFolder, figureResolution_dpi);

metricNames = {
    'Pitch RMS error'
    'Pitch peak error'
    'Pitch response shift'
    'Roll RMS error'
    'Roll peak error'
    'Roll response shift'
    'Configured backend period'
    'Configured supervisory/logging rate'
};

units = {'rad'; 'rad'; 'ms'; 'rad'; 'rad'; 'ms'; 'ms'; 'Hz'};

simVals = [
    simMetrics.Pitch.RMSE
    simMetrics.Pitch.Peak
    simMetrics.Pitch.Shift_ms
    simMetrics.Roll.RMSE
    simMetrics.Roll.Peak
    simMetrics.Roll.Shift_ms
    NaN
    NaN
];

expVals = [
    expMetrics.Pitch.RMSE
    expMetrics.Pitch.Peak
    expMetrics.Pitch.Shift_ms
    expMetrics.Roll.RMSE
    expMetrics.Roll.Peak
    expMetrics.Roll.Shift_ms
    NaN
    NaN
];

if ~isempty(sim)
    simVals(end-1:end) = [configuredBackend_ms; configuredLogger_Hz];
end

if ~isempty(expData)
    expVals(end-1:end) = [configuredBackend_ms; configuredLogger_Hz];
end

metricsTable = table(metricNames, units, simVals, expVals, ...
    'VariableNames', {'Metric','Unit','MuJoCo','G1_Hardware'});

writetable(metricsTable, ...
    fullfile(outputFolder, 'ankle_motion_metrics.csv'));

modeNames = {'MuJoCo'; 'G1_Hardware'};
metricRows = {simMetrics; expMetrics};

extra = table('Size',[2 19], ...
    'VariableTypes', [{'cell'}, repmat({'double'},1,18)], ...
    'VariableNames', {
        'Environment'
        'WindowStart_s'
        'WindowEnd_s'
        'NSamples'
        'MedianLoggedSample_ms'
        'Pitch_RMSE_rad'
        'Pitch_MAE_rad'
        'Pitch_PeakError_rad'
        'Pitch_Bias_rad'
        'Pitch_Shift_ms'
        'Pitch_CommandRMSE_rad'
        'Pitch_PICorrectionRMS_rad'
        'Roll_RMSE_rad'
        'Roll_MAE_rad'
        'Roll_PeakError_rad'
        'Roll_Bias_rad'
        'Roll_Shift_ms'
        'Roll_CommandRMSE_rad'
        'Roll_PICorrectionRMS_rad'
    });

for i = 1:2

    m = metricRows{i};

    extra.Environment{i} = modeNames{i};
    extra.WindowStart_s(i) = analysisWindow_s(1);
    extra.WindowEnd_s(i) = analysisWindow_s(2);
    extra.NSamples(i) = m.NSamples;
    extra.MedianLoggedSample_ms(i) = m.MedianSample_ms;

    extra.Pitch_RMSE_rad(i) = m.Pitch.RMSE;
    extra.Pitch_MAE_rad(i) = m.Pitch.MAE;
    extra.Pitch_PeakError_rad(i) = m.Pitch.Peak;
    extra.Pitch_Bias_rad(i) = m.Pitch.Bias;
    extra.Pitch_Shift_ms(i) = m.Pitch.Shift_ms;
    extra.Pitch_CommandRMSE_rad(i) = m.Pitch.CommandRMSE;
    extra.Pitch_PICorrectionRMS_rad(i) = m.Pitch.CorrectionRMS;

    extra.Roll_RMSE_rad(i) = m.Roll.RMSE;
    extra.Roll_MAE_rad(i) = m.Roll.MAE;
    extra.Roll_PeakError_rad(i) = m.Roll.Peak;
    extra.Roll_Bias_rad(i) = m.Roll.Bias;
    extra.Roll_Shift_ms(i) = m.Roll.Shift_ms;
    extra.Roll_CommandRMSE_rad(i) = m.Roll.CommandRMSE;
    extra.Roll_PICorrectionRMS_rad(i) = m.Roll.CorrectionRMS;

end

writetable(extra, ...
    fullfile(outputFolder, 'ankle_motion_metrics_extended.csv'));

disp(metricsTable);
disp(extra);
fprintf('Results saved in: %s\n', outputFolder);

end

function file = locateLatestCsv(folder, stem)

found = dir(fullfile(folder, [stem '*.csv']));
selected = false(numel(found),1);

expression = ['^' regexptranslate('escape',stem) ...
    '(_[0-9]+)?\.csv$'];

for i = 1:numel(found)
    selected(i) = ~found(i).isdir && ...
        ~isempty(regexp(found(i).name,expression,'once'));
end

found = found(selected);

if isempty(found)
    file = '';
    return
end

[~,idx] = max([found.datenum]);
file = fullfile(folder,found(idx).name);

end

function D = loadAnkleData(file,expectedMode)

T = readtable(file,'VariableNamingRule','preserve');

needed = {
    'Time_s'
    'RUN_MODE'
    'Pitch_Reference_rad'
    'Pitch_Feedback_rad'
    'Pitch_Command_rad'
    'Pitch_PI_Correction_rad'
    'Roll_Reference_rad'
    'Roll_Feedback_rad'
    'Roll_Command_rad'
    'Roll_PI_Correction_rad'
};

missing = setdiff(needed,T.Properties.VariableNames);

assert(isempty(missing), ...
    'Missing CSV columns: %s',strjoin(missing,', '));

modes = unique(T.RUN_MODE(isfinite(T.RUN_MODE)));

assert(isscalar(modes) && modes == expectedMode, ...
    'RUN_MODE does not match the selected environment.');

D.Time = double(T.Time_s(:));

D.Pitch.Reference = double(T.Pitch_Reference_rad(:));
D.Pitch.Feedback = double(T.Pitch_Feedback_rad(:));
D.Pitch.Command = double(T.Pitch_Command_rad(:));
D.Pitch.Correction = double(T.Pitch_PI_Correction_rad(:));

D.Roll.Reference = double(T.Roll_Reference_rad(:));
D.Roll.Feedback = double(T.Roll_Feedback_rad(:));
D.Roll.Command = double(T.Roll_Command_rad(:));
D.Roll.Correction = double(T.Roll_PI_Correction_rad(:));

[ts,ix] = sort(D.Time);
[ts,uniqueIx] = unique(ts,'stable');
ix = ix(uniqueIx);

D.Time = ts;

for joint = {'Pitch','Roll'}
    j = joint{1};

    for field = {'Reference','Feedback','Command','Correction'}
        f = field{1};
        v = D.(j).(f);
        D.(j).(f) = v(ix);
    end
end

assert(numel(D.Time) >= 3 && all(diff(D.Time) > 0), ...
    'Insufficient valid timestamps.');

end

function m = evaluateRun(D,window,maxShift)

emptyAxis = struct( ...
    'RMSE',NaN, ...
    'MAE',NaN, ...
    'Peak',NaN, ...
    'Bias',NaN, ...
    'Shift_ms',NaN, ...
    'CommandRMSE',NaN, ...
    'CorrectionRMS',NaN);

m = struct( ...
    'NSamples',NaN, ...
    'MedianSample_ms',NaN, ...
    'Pitch',emptyAxis, ...
    'Roll',emptyAxis);

if isempty(D)
    return
end

idx = D.Time >= window(1) & D.Time <= window(2);
t = D.Time(idx);

if numel(t) < 10
    return
end

m.NSamples = numel(t);
m.MedianSample_ms = 1000*median(diff(t));

for joint = {'Pitch','Roll'}

    j = joint{1};

    r = D.(j).Reference(idx);
    y = D.(j).Feedback(idx);
    cmd = D.(j).Command(idx);
    delta = D.(j).Correction(idx);

    ok = isfinite(t) & isfinite(r) & isfinite(y) & ...
        isfinite(cmd) & isfinite(delta);

    if nnz(ok) < 10
        continue
    end

    r = r(ok);
    y = y(ok);
    cmd = cmd(ok);
    delta = delta(ok);
    time = t(ok);

    e = r-y;
    commandError = cmd-y;

    m.(j).RMSE = sqrt(mean(e.^2));
    m.(j).MAE = mean(abs(e));
    m.(j).Peak = max(abs(e));
    m.(j).Bias = mean(e);

    m.(j).Shift_ms = estimateResponseShift( ...
        time,r,y,maxShift);

    m.(j).CommandRMSE = sqrt(mean(commandError.^2));
    m.(j).CorrectionRMS = sqrt(mean(delta.^2));

end

end

function ms = estimateResponseShift(t,ref,feedback,maxShift_s)

ms = NaN;

t = t(:);
ref = ref(:);
feedback = feedback(:);

if numel(t) < 10 || any(diff(t) <= 0)
    return
end

dt = median(diff(t));

if ~isfinite(dt) || dt <= 0
    return
end

maxLag = min(round(maxShift_s/dt),floor(numel(t)/4));

if maxLag < 1
    return
end

ref = ref-mean(ref);
feedback = feedback-mean(feedback);

if norm(ref) < 1e-9 || norm(feedback) < 1e-9
    return
end

best = -Inf;

for lag = 0:maxLag

    if lag == 0
        a = ref;
        b = feedback;
    else
        a = ref(1:end-lag);
        b = feedback(1+lag:end);
    end

    score = (a.'*b)/(norm(a)*norm(b)+eps);

    if score > best
        best = score;
        ms = lag*dt*1000;
    end

end

end

function createComparisonFigure(sim,expData,window,outputFolder,dpi)

fig = figure( ...
    'Color','white', ...
    'Name','Ankle Motion Comparison', ...
    'Position',[100 100 1500 760]);

layout = tiledlayout(fig,2,2, ...
    'TileSpacing','compact', ...
    'Padding','compact');

cRef = [0.05 0.70 0.92];
cSimFeed = [0.40 0.64 0.13];
cExpPitch = [0.92 0.05 0.05];
cSimPitch = [0.00 0.38 0.73];
cSimRoll = [0.39 0.63 0.10];
cExpRoll = [0.05 0.71 0.89];

ax1 = nexttile(layout,1);
hold(ax1,'on');

plotReference(ax1,sim,expData,'Pitch',window,cRef);

plotSeries(ax1,sim,'Pitch','Feedback',window, ...
    cSimFeed,'-',2.0,'Sim. Feedback');

plotSeries(ax1,expData,'Pitch','Feedback',window, ...
    cExpPitch,'-',1.6,'Exp. Feedback');

configureAxes(ax1,'Pitch Signals','Position [rad]',window);

ax2 = nexttile(layout,2);
hold(ax2,'on');

plotReference(ax2,sim,expData,'Roll',window,cRef);

plotSeries(ax2,sim,'Roll','Feedback',window, ...
    cSimFeed,'-',2.0,'Sim. Feedback');

plotSeries(ax2,expData,'Roll','Feedback',window, ...
    cExpPitch,'-',1.6,'Exp. Feedback');

configureAxes(ax2,'Roll Signals','Position [rad]',window);

ax3 = nexttile(layout,3);
hold(ax3,'on');

plotSeries(ax3,sim,'Pitch','Command',window, ...
    cSimPitch,':',2.7,'Sim. Pitch Command');

plotSeries(ax3,sim,'Roll','Command',window, ...
    cSimRoll,':',2.7,'Sim. Roll Command');

plotSeries(ax3,expData,'Pitch','Command',window, ...
    cExpPitch,'-',1.6,'Exp. Pitch Command');

plotSeries(ax3,expData,'Roll','Command',window, ...
    cExpRoll,'-',1.6,'Exp. Roll Command');

configureAxes(ax3, ...
    'Control Signals [ PI controller ]', ...
    'Position [rad]',window);

ax4 = nexttile(layout,4);
hold(ax4,'on');

plotSeries(ax4,sim,'Pitch','Correction',window, ...
    cSimPitch,':',2.7,'Sim. \Delta_q Pitch');

plotSeries(ax4,sim,'Roll','Correction',window, ...
    cSimRoll,':',2.7,'Sim. \Delta_q Roll');

plotSeries(ax4,expData,'Pitch','Correction',window, ...
    cExpPitch,'-',1.6,'Exp. \Delta_q Pitch');

plotSeries(ax4,expData,'Roll','Correction',window, ...
    cExpRoll,'-',1.6,'Exp. \Delta_q Roll');

configureAxes(ax4, ...
    '\Delta_q Signals [ PI controller ]', ...
    '\Delta_q [rad]',window);

exportgraphics(fig, ...
    fullfile(outputFolder,'ankle_motion_comparison.png'), ...
    'Resolution',dpi);

end

function plotReference(ax,sim,expData,joint,window,color)

if isempty(sim) && isempty(expData)
    return
end

if isempty(sim)

    plotSeries(ax,expData,joint,'Reference',window, ...
        color,':',3.0,'Reference');

    return
end

plotSeries(ax,sim,joint,'Reference',window, ...
    color,':',3.0,'Reference');

if isempty(expData)
    return
end

idx = sim.Time >= window(1) & ...
    sim.Time <= window(2) & ...
    sim.Time >= min(expData.Time) & ...
    sim.Time <= max(expData.Time);

if ~any(idx)
    return
end

simRef = sim.(joint).Reference(idx);

expRef = interp1( ...
    expData.Time, ...
    expData.(joint).Reference, ...
    sim.Time(idx),'linear',NaN);

diffRef = abs(simRef-expRef);
valid = isfinite(diffRef);

if any(valid) && max(diffRef(valid)) > 1e-3
    warning('%s references differ between environments.',joint);
end

end

function plotSeries(ax,D,joint,field,window,color,lineStyle,lineWidth,label)

if isempty(D)
    return
end

idx = D.Time >= window(1) & D.Time <= window(2);

if ~any(idx)
    return
end

values = D.(joint).(field);

plot(ax,D.Time(idx),values(idx), ...
    'Color',color, ...
    'LineStyle',lineStyle, ...
    'LineWidth',lineWidth, ...
    'DisplayName',label);

end

function configureAxes(ax,heading,ylabelText,window)

title(ax,heading, ...
    'FontWeight','bold', ...
    'Interpreter','tex');

ylabel(ax,ylabelText,'Interpreter','tex');
xlabel(ax,'Time [s]');

xlim(ax,window);
grid(ax,'on');
box(ax,'on');

ax.FontSize = 10;

legend(ax,'show', ...
    'Location','northeast', ...
    'FontSize',9, ...
    'Interpreter','tex', ...
    'Box','on');

end
