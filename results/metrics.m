clc;
clear;
close all;

t_min = 3;
t_max = 5;

pitch_sim_file = 'ankle_pitch_signals_sim.fig';
pitch_exp_file = 'ankle_pitch_signals_exp.fig';

roll_sim_file = 'ankle_roll_signals_sim.fig';
roll_exp_file = 'ankle_roll_signals_exp.fig';

pitch_data = extract_reference_and_output(pitch_sim_file, pitch_exp_file);
roll_data  = extract_reference_and_output(roll_sim_file, roll_exp_file);

pitch_metrics = compute_joint_metrics(pitch_data, t_min, t_max);
roll_metrics  = compute_joint_metrics(roll_data, t_min, t_max);

paper_rows = [
    {"Bilateral ankle pitch", "", "", ""};
    build_metric_rows(pitch_metrics);
    {"Bilateral ankle roll", "", "", ""};
    build_metric_rows(roll_metrics)
];

disp('QUANTITATIVE PERFORMANCE TABLE');
print_paper_table(paper_rows);

fprintf('\nSIM-REAL DISCREPANCY FOR TEXT:\n');
fprintf('Pitch: RMS = %.4f rad, Peak = %.4f rad\n', ...
    pitch_metrics.sim_real_rms, pitch_metrics.sim_real_peak);
fprintf('Roll:  RMS = %.4f rad, Peak = %.4f rad\n', ...
    roll_metrics.sim_real_rms, roll_metrics.sim_real_peak);

writecell([{"Metric","Sim","Exp","Exp/Sim [%]"}; paper_rows], ...
    'quantitative_performance_table.csv');

function rows = build_metric_rows(m)

    rows = {
        "RMS tracking error [rad]", ...
        format_number(m.rms_sim, 4), ...
        format_number(m.rms_exp, 4), ...
        format_number(m.rms_exp_sim_percent, 1);

        "Peak tracking error [rad]", ...
        format_number(m.peak_sim, 4), ...
        format_number(m.peak_exp, 4), ...
        format_number(m.peak_exp_sim_percent, 1);

        "Delay [ms]", ...
        format_number(m.delay_sim, 1), ...
        format_number(m.delay_exp, 1), ...
        format_number(m.delay_exp_sim_percent, 1);

        "Sampling rate [Hz]", ...
        format_number(m.rate_sim, 1), ...
        format_number(m.rate_exp, 1), ...
        format_number(m.rate_exp_sim_percent, 1)
    };

end

function print_paper_table(rows)

    metric_w = 32;
    sim_w = 8;
    exp_w = 8;
    ratio_w = 12;

    line = ['+' repmat('-',1,metric_w+2) ...
            '+' repmat('-',1,sim_w+2) ...
            '+' repmat('-',1,exp_w+2) ...
            '+' repmat('-',1,ratio_w+2) '+'];

    section_w = length(line) - 4;

    fprintf('\n');
    fprintf('%s\n', line);
    fprintf('| %-*s | %*s | %*s | %*s |\n', ...
        metric_w, 'Metric', ...
        sim_w, 'Sim', ...
        exp_w, 'Exp', ...
        ratio_w, 'Exp/Sim [%]');
    fprintf('%s\n', line);

    for i = 1:size(rows,1)

        metric = rows{i,1};
        sim_val = rows{i,2};
        exp_val = rows{i,3};
        ratio_val = rows{i,4};

        if sim_val == "" && exp_val == "" && ratio_val == ""
            fprintf('| %-*s |\n', section_w, metric);
            fprintf('%s\n', line);
        else
            fprintf('| %-*s | %*s | %*s | %*s |\n', ...
                metric_w, metric, ...
                sim_w, sim_val, ...
                exp_w, exp_val, ...
                ratio_w, ratio_val);
        end
    end

    fprintf('%s\n', line);
    fprintf('\n');

end

function text_value = format_number(value, decimals)

    text_value = string(sprintf(['%.' num2str(decimals) 'f'], value));

    if decimals > 0
        text_value = regexprep(text_value, '\.?0+$', '');
    end

end

function m = compute_joint_metrics(data, t_min, t_max)

    [tq_sim, ref_sim, out_sim] = align_signals( ...
        data.t_ref_sim, data.y_ref_sim, ...
        data.t_out_sim, data.y_out_sim, ...
        t_min, t_max);

    [tq_exp, ref_exp, out_exp] = align_signals( ...
        data.t_ref_exp, data.y_ref_exp, ...
        data.t_out_exp, data.y_out_exp, ...
        t_min, t_max);

    err_sim = ref_sim - out_sim;
    err_exp = ref_exp - out_exp;

    m.rms_sim = sqrt(mean(err_sim.^2));
    m.rms_exp = sqrt(mean(err_exp.^2));
    m.rms_exp_sim_percent = 100 * m.rms_exp / m.rms_sim;

    m.peak_sim = max(abs(err_sim));
    m.peak_exp = max(abs(err_exp));
    m.peak_exp_sim_percent = 100 * m.peak_exp / m.peak_sim;

    m.delay_sim = estimate_delay_ms(tq_sim, ref_sim, out_sim);
    m.delay_exp = estimate_delay_ms(tq_exp, ref_exp, out_exp);
    m.delay_exp_sim_percent = 100 * m.delay_exp / m.delay_sim;

    m.rate_sim = compute_loop_frequency(data.t_out_sim, t_min, t_max);
    m.rate_exp = compute_loop_frequency(data.t_out_exp, t_min, t_max);
    m.rate_exp_sim_percent = 100 * m.rate_exp / m.rate_sim;

    [~, sim_signal, exp_signal] = align_signals( ...
        data.t_out_sim, data.y_out_sim, ...
        data.t_out_exp, data.y_out_exp, ...
        t_min, t_max);

    sim_real_error = sim_signal - exp_signal;

    m.sim_real_rms = sqrt(mean(sim_real_error.^2));
    m.sim_real_peak = max(abs(sim_real_error));

end

function data = extract_reference_and_output(sim_file, exp_file)

    [t_sim, y_sim] = read_curves_from_fig(sim_file);
    [t_exp, y_exp] = read_curves_from_fig(exp_file);

    [ref_sim_idx, ref_exp_idx] = find_common_reference(t_sim, y_sim, t_exp, y_exp);

    sim_out_idx = setdiff(1:length(y_sim), ref_sim_idx);
    exp_out_idx = setdiff(1:length(y_exp), ref_exp_idx);

    sim_out_idx = sim_out_idx(1);
    exp_out_idx = exp_out_idx(1);

    data.t_ref_sim = t_sim{ref_sim_idx};
    data.y_ref_sim = y_sim{ref_sim_idx};

    data.t_ref_exp = t_exp{ref_exp_idx};
    data.y_ref_exp = y_exp{ref_exp_idx};

    data.t_out_sim = t_sim{sim_out_idx};
    data.y_out_sim = y_sim{sim_out_idx};

    data.t_out_exp = t_exp{exp_out_idx};
    data.y_out_exp = y_exp{exp_out_idx};

end

function [tq, y1q, y2q] = align_signals(t1, y1, t2, y2, t_min, t_max)

    t1 = t1(:);
    y1 = y1(:);
    t2 = t2(:);
    y2 = y2(:);

    [t1, idx1_unique] = unique(t1);
    y1 = y1(idx1_unique);

    [t2, idx2_unique] = unique(t2);
    y2 = y2(idx2_unique);

    idx1 = t1 >= t_min & t1 <= t_max;
    idx2 = t2 >= t_min & t2 <= t_max;

    t_start = max([t_min, min(t1(idx1)), min(t2(idx2))]);
    t_end = min([t_max, max(t1(idx1)), max(t2(idx2))]);

    n_samples = min(sum(idx1), sum(idx2));

    tq = linspace(t_start, t_end, n_samples)';

    y1q = interp1(t1, y1, tq, 'linear');
    y2q = interp1(t2, y2, tq, 'linear');

    valid = ~isnan(y1q) & ~isnan(y2q);

    tq = tq(valid);
    y1q = y1q(valid);
    y2q = y2q(valid);

end

function delay_ms = estimate_delay_ms(t, reference, output)

    dt = mean(diff(t));

    reference = reference - mean(reference);
    output = output - mean(output);

    max_lag_seconds = min(0.5, (t(end) - t(1)) / 3);
    max_lag_samples = floor(max_lag_seconds / dt);

    best_rmse = inf;
    best_lag = 0;

    for lag = -max_lag_samples:max_lag_samples

        if lag >= 0
            ref_shifted = reference(1:end-lag);
            out_shifted = output(1+lag:end);
        else
            lag_abs = abs(lag);
            ref_shifted = reference(1+lag_abs:end);
            out_shifted = output(1:end-lag_abs);
        end

        current_rmse = sqrt(mean((ref_shifted - out_shifted).^2));

        if current_rmse < best_rmse
            best_rmse = current_rmse;
            best_lag = lag;
        end
    end

    delay_ms = best_lag * dt * 1000;

end

function rate_hz = compute_loop_frequency(t, t_min, t_max)

    t = t(:);
    idx = t >= t_min & t <= t_max;
    t_crop = t(idx);

    dt = diff(t_crop);

    rate_hz = 1 / mean(dt);

end

function [all_t, all_y] = read_curves_from_fig(fig_name)

    fig = openfig(fig_name, 'new', 'invisible');

    objects = findobj(fig, '-property', 'YData');

    all_t = {};
    all_y = {};

    counter = 1;

    for k = length(objects):-1:1

        if isprop(objects(k), 'XData') && isprop(objects(k), 'YData')

            x = objects(k).XData;
            y = objects(k).YData;

            if ~isempty(x) && ~isempty(y) && numel(x) > 1 && numel(y) > 1
                all_t{counter} = x(:);
                all_y{counter} = y(:);
                counter = counter + 1;
            end
        end
    end

    close(fig);

end

function [ref_sim_idx, ref_exp_idx] = find_common_reference(t_sim, y_sim, t_exp, y_exp)

    best_error = inf;
    ref_sim_idx = 1;
    ref_exp_idx = 1;

    for i = 1:length(y_sim)

        for j = 1:length(y_exp)

            t_start = max(min(t_sim{i}), min(t_exp{j}));
            t_end = min(max(t_sim{i}), max(t_exp{j}));

            if t_end <= t_start
                continue;
            end

            tq = linspace(t_start, t_end, 1000)';

            [t1, ia1] = unique(t_sim{i});
            y1_data = y_sim{i}(ia1);

            [t2, ia2] = unique(t_exp{j});
            y2_data = y_exp{j}(ia2);

            y1 = interp1(t1, y1_data, tq, 'linear');
            y2 = interp1(t2, y2_data, tq, 'linear');

            valid = ~isnan(y1) & ~isnan(y2);

            if sum(valid) > 10
                error_value = mean((y1(valid) - y2(valid)).^2);

                if error_value < best_error
                    best_error = error_value;
                    ref_sim_idx = i;
                    ref_exp_idx = j;
                end
            end
        end
    end

end