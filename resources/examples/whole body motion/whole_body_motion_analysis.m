
function whole_body_motion_analysis()

analysisWindow_s = [10.0 19.0];
maximumResponseShift_s = 0.5;
figureResolution_dpi = 300;

folder = fileparts(mfilename('fullpath'));
if isempty(folder)
    folder = pwd;
end

outputFolder = fullfile(folder,'whole_body_motion_analysis_results');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

simFile = newestCsv(folder,'whole_body_motion_sim_metrics');
expFile = newestCsv(folder,'whole_body_motion_exp_metrics');

assert(~isempty(simFile) || ~isempty(expFile), ...
    'No whole-body CSV was found beside the analysis script.');

sim = [];
expData = [];

if ~isempty(simFile)
    fprintf('MuJoCo: %s\n',simFile);
    sim = readRun(simFile,0);
end

if ~isempty(expFile)
    fprintf('Physical G1: %s\n',expFile);
    expData = readRun(expFile,1);
end

movingIdx = [1 4 7 10];
names = allJointNames();

if ~isempty(sim)
    assert(nnz(sim.Time >= analysisWindow_s(1) & ...
        sim.Time <= analysisWindow_s(2)) >= 10, ...
        'MuJoCo requires at least 10 samples between 10 and 19 seconds.');
end

if ~isempty(expData)
    assert(nnz(expData.Time >= analysisWindow_s(1) & ...
        expData.Time <= analysisWindow_s(2)) >= 10, ...
        'Physical G1 requires at least 10 samples between 10 and 19 seconds.');
end

createFigure(sim,expData,movingIdx,analysisWindow_s, ...
    figureResolution_dpi,outputFolder);

labels = {
    'RMSE'
    'MAE'
    'Peak absolute error'
    'Mean tracking error'
    'Response shift'
    'Peak absolute joint velocity'
    'Peak absolute torque feedback'
};

units = {'rad';'rad';'rad';'rad';'ms';'rad/s';'Nm'};
nRows = numel(movingIdx)*numel(labels);
jointColumn = cell(nRows,1);
metricColumn = cell(nRows,1);
unitColumn = cell(nRows,1);
simColumn = NaN(nRows,1);
expColumn = NaN(nRows,1);
idx = 0;

for i = movingIdx
    ms = metricsForJoint(sim,i,analysisWindow_s,maximumResponseShift_s,'nominal');
    me = metricsForJoint(expData,i,analysisWindow_s,maximumResponseShift_s,'nominal');

    for j = 1:numel(labels)
        idx = idx+1;
        jointColumn{idx} = names{i};
        metricColumn{idx} = labels{j};
        unitColumn{idx} = units{j};
        simColumn(idx) = ms(j);
        expColumn(idx) = me(j);
    end
end

mainTable = table(jointColumn,metricColumn,unitColumn,simColumn,expColumn, ...
    'VariableNames',{'Joint','Metric','Unit','MuJoCo','G1_Hardware'});

writetable(mainTable, ...
    fullfile(outputFolder,'whole_body_motion_metrics.csv'));

extended = table();

for mode = 1:2
    if mode == 1
        D = sim;
        env = 'MuJoCo';
    else
        D = expData;
        env = 'G1_Hardware';
    end

    for i = 1:29
        mNom = metricsForJoint(D,i,analysisWindow_s, ...
            maximumResponseShift_s,'nominal');
        mCmd = metricsForJoint(D,i,analysisWindow_s, ...
            maximumResponseShift_s,'command');

        if isempty(D)
            nSamples = NaN;
            motionTime = NaN;
            simulationEnd = NaN;
            motionDuration = NaN;
            correctionRMS = NaN;
            correctionPeak = NaN;
        else
            mask = D.Time >= analysisWindow_s(1) & ...
                D.Time <= analysisWindow_s(2);
            nSamples = nnz(mask);
            motionTime = D.MotionStart;
            simulationEnd = D.Time(end);
            motionDuration = simulationEnd-motionTime;
            correction = D.PICorrection(mask,i);
            correction = correction(isfinite(correction));

            if isempty(correction)
                correctionRMS = NaN;
                correctionPeak = NaN;
            else
                correctionRMS = sqrt(mean(correction.^2));
                correctionPeak = max(abs(correction));
            end
        end

        entry = table({env},{names{i}},i, ...
            motionTime,simulationEnd,motionDuration, ...
            analysisWindow_s(1),analysisWindow_s(2),nSamples, ...
            mNom(1),mNom(2),mNom(3),mNom(4),mNom(5), ...
            mNom(6),mNom(7), ...
            mCmd(1),mCmd(2),mCmd(3),mCmd(4),mCmd(5), ...
            correctionRMS,correctionPeak, ...
            'VariableNames',{ ...
            'Environment','Joint','JointIndex', ...
            'MotionStart_s','SimulationEnd_s','MotionDuration_s', ...
            'WindowStart_s','WindowEnd_s','NSamples', ...
            'RMSE_rad','MAE_rad','PeakError_rad','Bias_rad', ...
            'ResponseShift_ms','PeakVelocity_rad_s','PeakTorqueFeedback_Nm', ...
            'CommandRMSE_rad','CommandMAE_rad','CommandPeakError_rad', ...
            'CommandBias_rad','CommandResponseShift_ms', ...
            'PICorrectionRMS_rad','PICorrectionPeak_rad'});

        extended = [extended;entry];
    end
end

writetable(extended, ...
    fullfile(outputFolder,'whole_body_motion_metrics_extended.csv'));

disp(mainTable);
fprintf('\nMain metrics: nominal reference versus feedback.\n');
fprintf('Extended metrics: nominal and PI-corrected command tracking.\n');

if ~isempty(sim)
    fprintf('MuJoCo: motion enabled at %.3f s; recording ends at %.3f s.\n', ...
        sim.MotionStart,sim.Time(end));
end

if ~isempty(expData)
    fprintf('Physical G1: motion enabled at %.3f s; recording ends at %.3f s.\n', ...
        expData.MotionStart,expData.Time(end));
end

fprintf('Evaluation window: %.2f to %.2f s.\n', ...
    analysisWindow_s(1),analysisWindow_s(2));
fprintf('Saved in %s\n',outputFolder);

end

function file = newestCsv(folder,stem)

items = dir(fullfile(folder,[stem '*.csv']));
keep = false(numel(items),1);
pat = ['^' regexptranslate('escape',stem) '(_[0-9]+)?\.csv$'];

for j = 1:numel(items)
    keep(j) = ~items(j).isdir && ...
        ~isempty(regexp(items(j).name,pat,'once'));
end

items = items(keep);

if isempty(items)
    file = '';
else
    [~,i] = max([items.datenum]);
    file = fullfile(folder,items(i).name);
end

end

function D = readRun(file,mode)

T = readtable(file,'VariableNamingRule','preserve');
needed = {'Time_s','RUN_MODE','MotionEnable'};

for i = 1:numel(needed)
    assert(ismember(needed{i},T.Properties.VariableNames), ...
        'Missing CSV column %s in %s.',needed{i},file);
end

m = unique(T.RUN_MODE(isfinite(T.RUN_MODE)));
assert(isscalar(m) && m==mode,'RUN_MODE mismatch for %s.',file);

time = double(T.Time_s(:));
enable = double(T.MotionEnable(:));

[time,ix] = unique(time,'stable');
enable = enable(ix);
[time,ix2] = sort(time);
enable = enable(ix2);
ix = ix(ix2);

D.Time = time;
D.Enable = enable;

startIdx = find(D.Enable >= 0.5,1,'first');
assert(~isempty(startIdx),'MotionEnable never activated in %s.',file);
D.MotionStart = D.Time(startIdx);

names = allJointNames();
n = numel(D.Time);

D.Nominal = NaN(n,29);
D.Command = NaN(n,29);
D.Feedback = NaN(n,29);
D.Velocity = NaN(n,29);
D.Torque = NaN(n,29);
D.PICorrection = NaN(n,29);

for i = 1:29
    base = names{i};
    cNom = [base '_NominalReference_rad'];
    cCmd = [base '_Reference_rad'];
    cFb = [base '_Feedback_rad'];

    assert(ismember(cNom,T.Properties.VariableNames), ...
        ['The CSV lacks %s. Export a new run using the updated ' ...
         'whole_body_motion_csv.m: %s'],cNom,file);

    assert(ismember(cCmd,T.Properties.VariableNames), ...
        'Missing PI command: %s',cCmd);

    assert(ismember(cFb,T.Properties.VariableNames), ...
        'Missing joint feedback: %s',cFb);

    qNom = T.(cNom);
    qCmd = T.(cCmd);
    qFb = T.(cFb);

    D.Nominal(:,i) = double(qNom(ix));
    D.Command(:,i) = double(qCmd(ix));
    D.Feedback(:,i) = double(qFb(ix));

    cPI = [base '_PICorrection_rad'];

    if ismember(cPI,T.Properties.VariableNames)
        qPI = T.(cPI);
        D.PICorrection(:,i) = double(qPI(ix));
    else
        D.PICorrection(:,i) = D.Command(:,i)-D.Nominal(:,i);
    end

    cVel = [base '_VelocityFeedback_rad_s'];
    cTau = [base '_TorqueFeedback_Nm'];

    if ismember(cVel,T.Properties.VariableNames)
        value = T.(cVel);
        D.Velocity(:,i) = double(value(ix));
    end

    if ismember(cTau,T.Properties.VariableNames)
        value = T.(cTau);
        D.Torque(:,i) = double(value(ix));
    end
end

end

function v = metricsForJoint(D,i,window,maxShift,kind)

v = NaN(1,7);

if isempty(D)
    return
end

mask = D.Time >= window(1) & D.Time <= window(2);
t = D.Time(mask);

if strcmp(kind,'nominal')
    r = D.Nominal(mask,i);
else
    r = D.Command(mask,i);
end

y = D.Feedback(mask,i);
valid = isfinite(t) & isfinite(r) & isfinite(y);

if nnz(valid)<10
    return
end

t = t(valid);
r = r(valid);
y = y(valid);
e = r-y;

v(1) = sqrt(mean(e.^2));
v(2) = mean(abs(e));
v(3) = max(abs(e));
v(4) = mean(e);
v(5) = responseShift(t,r,y,maxShift);

vv = D.Velocity(mask,i);
vv = vv(isfinite(vv));

if ~isempty(vv)
    v(6) = max(abs(vv));
end

tau = D.Torque(mask,i);
tau = tau(isfinite(tau));

if ~isempty(tau)
    v(7) = max(abs(tau));
end

end

function shift_ms = responseShift(t,r,y,maxShift)

shift_ms = NaN;

if numel(t)<10 || any(diff(t)<=0)
    return
end

dt = median(diff(t));

if ~isfinite(dt) || dt<=0
    return
end

maxLag = min(round(maxShift/dt),floor(numel(t)/4));

if maxLag<1
    return
end

r = r-mean(r);
y = y-mean(y);

if norm(r)<1e-10 || norm(y)<1e-10
    return
end

best = -Inf;

for k = 0:maxLag
    if k==0
        a = r;
        b = y;
    else
        a = r(1:end-k);
        b = y(k+1:end);
    end

    score = (a.'*b)/(norm(a)*norm(b)+eps);

    if score>best
        best = score;
        shift_ms = 1000*k*dt;
    end
end

end

function createFigure(sim,expData,indices,window,dpi,folder)

fig = figure('Color','white', ...
    'Name','Whole-Body Motion Comparison', ...
    'Position',[80 80 1420 820]);

tile = tiledlayout(fig,2,2, ...
    'TileSpacing','compact','Padding','compact');

titles = {'Left Hip Pitch','Left Knee','Right Hip Pitch','Right Knee'};

cNomSim = [0.05 0.70 0.92];
cNomExp = [0.49 0.25 0.72];
cSim = [0.40 0.64 0.13];
cExp = [0.92 0.05 0.05];

for j = 1:4
    i = indices(j);
    ax = nexttile(tile,j);
    hold(ax,'on');

    simMask = [];
    expMask = [];

    if ~isempty(sim)
        simMask = sim.Time >= window(1) & sim.Time <= window(2);
    end

    if ~isempty(expData)
        expMask = expData.Time >= window(1) & expData.Time <= window(2);
    end

    if ~isempty(sim) && ~isempty(expData)
        tCompare = sim.Time(simMask);
        tCompare = tCompare(tCompare>=expData.Time(1) & ...
            tCompare<=expData.Time(end));

        if isempty(tCompare)
            equalNominal = false;
        else
            simNom = interp1(sim.Time,sim.Nominal(:,i),tCompare,'linear',NaN);
            expNom = interp1(expData.Time,expData.Nominal(:,i), ...
                tCompare,'linear',NaN);

            difference = abs(simNom-expNom);
            difference = difference(isfinite(difference));

            equalNominal = ~isempty(difference) && max(difference)<=1e-3;
        end
    else
        equalNominal = true;
    end

    if ~isempty(sim)
        if equalNominal
            nominalLabel = 'Nominal Reference';
        else
            nominalLabel = 'Sim. Nominal Reference';
        end

        plot(ax,sim.Time(simMask),sim.Nominal(simMask,i),':', ...
            'Color',cNomSim,'LineWidth',3, ...
            'DisplayName',nominalLabel);
    end

    if ~isempty(expData) && (isempty(sim) || ~equalNominal)
        if isempty(sim)
            nominalLabel = 'Nominal Reference';
        else
            nominalLabel = 'Exp. Nominal Reference';
        end

        plot(ax,expData.Time(expMask),expData.Nominal(expMask,i),':', ...
            'Color',cNomExp,'LineWidth',2.5, ...
            'DisplayName',nominalLabel);
    end

    if ~isempty(sim)
        plot(ax,sim.Time(simMask),sim.Feedback(simMask,i),'-', ...
            'Color',cSim,'LineWidth',2.0, ...
            'DisplayName','Sim. Feedback');
    end

    if ~isempty(expData)
        plot(ax,expData.Time(expMask),expData.Feedback(expMask,i),'-', ...
            'Color',cExp,'LineWidth',1.7, ...
            'DisplayName','Exp. Feedback');
    end

    title(ax,titles{j},'FontWeight','bold');
    xlabel(ax,'Time [s]');
    ylabel(ax,'Position [rad]');
    xlim(ax,window);
    grid(ax,'on');
    box(ax,'on');
    legend(ax,'show','Location','best','FontSize',9);
    ax.FontSize = 10;
end

exportgraphics(fig, ...
    fullfile(folder,'whole_body_motion_comparison.png'), ...
    'Resolution',dpi);

end

function names = allJointNames()

names = { ...
    'LeftHipPitch','LeftHipRoll','LeftHipYaw','LeftKnee', ...
    'LeftAnklePitch','LeftAnkleRoll', ...
    'RightHipPitch','RightHipRoll','RightHipYaw','RightKnee', ...
    'RightAnklePitch','RightAnkleRoll', ...
    'WaistYaw','WaistRoll','WaistPitch', ...
    'LeftShoulderPitch','LeftShoulderRoll','LeftShoulderYaw', ...
    'LeftElbow','LeftWristRoll','LeftWristPitch','LeftWristYaw', ...
    'RightShoulderPitch','RightShoulderRoll','RightShoulderYaw', ...
    'RightElbow','RightWristRoll','RightWristPitch','RightWristYaw'};

end
