clc;
clear;
close all;

t_min = 3;
t_max = 5;
x_margin = 0.05;

color_sim_pitch = [0 0.4470 0.7410];       
color_sim_roll  = [0.4660 0.6740 0.1880]; 
color_exp_pitch = [1.0000 0.0000 0.0000]; 
color_exp_roll  = [0.3010 0.7450 0.9330]; 

color_reference = [0.3010 0.7450 0.9330]; 
color_sim_output = [0.4660 0.6740 0.1880]; 
color_exp_output = [1.0000 0.0000 0.0000]; 

figure('Color','w');

tiledlayout(2,2, ...
    'TileSpacing','compact', ...
    'Padding','compact');

nexttile;
plot_reference_output_signals( ...
    'ankle_pitch_signals_sim.fig', ...
    'ankle_pitch_signals_exp.fig', ...
    'Reference', ...
    'Sim. Feedback', ...
    'Exp. Feedback', ...
    'Pitch Signals', ...
    t_min, t_max, x_margin, ...
    color_reference, color_sim_output, color_exp_output);

nexttile;
plot_reference_output_signals( ...
    'ankle_roll_signals_sim.fig', ...
    'ankle_roll_signals_exp.fig', ...
    'Reference', ...
    'Sim. Feedback', ...
    'Exp. Feedback', ...
    'Roll Signals', ...
    t_min, t_max, x_margin, ...
    color_reference, color_sim_output, color_exp_output);

nexttile;
plot_four_signals( ...
    'control_signals_sim.fig', ...
    'control_signals_exp.fig', ...
    {'Pitch Command', 'Roll Command'}, ...
    'Control Signals [ PI controller ]', ...
    'Position [rad]', ...
    t_min, t_max, x_margin, ...
    color_sim_pitch, color_sim_roll, color_exp_pitch, color_exp_roll, ...
    [1 2]);

nexttile;
plot_four_signals( ...
    'delta_q_signals_sim.fig', ...
    'delta_q_signals_exp.fig', ...
    {'\Delta_q Pitch', '\Delta_q Roll'}, ...
    '\Delta_q Signals [ PI controller ]', ...
    '\Delta_q [rad]', ...
    t_min, t_max, x_margin, ...
    color_sim_pitch, color_sim_roll, color_exp_pitch, color_exp_roll, ...
    [2 1]);

drawnow;

function plot_reference_output_signals(sim_file, exp_file, ref_name, sim_name, exp_name, plot_title, t_min, t_max, x_margin, reference_color, simulation_color, experimental_color)

    [t_sim, y_sim] = read_curves_from_fig(sim_file);
    [t_exp, y_exp] = read_curves_from_fig(exp_file);

    [ref_sim_idx, ref_exp_idx] = find_common_reference(t_sim, y_sim, t_exp, y_exp);

    sim_out_idx = setdiff(1:length(y_sim), ref_sim_idx);
    exp_out_idx = setdiff(1:length(y_exp), ref_exp_idx);

    sim_out_idx = sim_out_idx(1);
    exp_out_idx = exp_out_idx(1);

    hold on;
    grid on;
    box on;

    idx_ref = t_sim{ref_sim_idx} >= t_min & t_sim{ref_sim_idx} <= t_max;
    plot(t_sim{ref_sim_idx}(idx_ref), y_sim{ref_sim_idx}(idx_ref), ':', ...
        'Color', reference_color, ...
        'LineWidth', 4.5, ...
        'DisplayName', ref_name);

    idx_sim = t_sim{sim_out_idx} >= t_min & t_sim{sim_out_idx} <= t_max;
    plot(t_sim{sim_out_idx}(idx_sim), y_sim{sim_out_idx}(idx_sim), '-', ...
        'Color', simulation_color, ...
        'LineWidth', 4.0, ...
        'DisplayName', sim_name);

    idx_exp = t_exp{exp_out_idx} >= t_min & t_exp{exp_out_idx} <= t_max;
    plot(t_exp{exp_out_idx}(idx_exp), y_exp{exp_out_idx}(idx_exp), '-', ...
        'Color', experimental_color, ...
        'LineWidth', 2.5, ...
        'DisplayName', exp_name);

    xlabel('Time [s]');
    ylabel('Position [rad]');
    title(plot_title);
    legend('Location','bestoutside');
    xlim([t_min - x_margin, t_max + x_margin]);

end

function plot_four_signals(sim_file, exp_file, signal_names, plot_title, y_label, t_min, t_max, x_margin, color_sim_pitch, color_sim_roll, color_exp_pitch, color_exp_roll, signal_order)

    [t_sim, y_sim] = read_curves_from_fig(sim_file);
    [t_exp, y_exp] = read_curves_from_fig(exp_file);

    colors_sim = {
        color_sim_pitch,
        color_sim_roll
    };

    colors_exp = {
        color_exp_pitch,
        color_exp_roll
    };

    hold on;
    grid on;
    box on;

    for i = 1:length(signal_order)

        curve_idx = signal_order(i);

        idx = t_sim{curve_idx} >= t_min & t_sim{curve_idx} <= t_max;

        plot(t_sim{curve_idx}(idx), y_sim{curve_idx}(idx), ':', ...
            'Color', colors_sim{i}, ...
            'LineWidth', 5, ...
            'DisplayName', ['Sim. ' signal_names{i}]);
    end

    for i = 1:length(signal_order)

        curve_idx = signal_order(i);

        idx = t_exp{curve_idx} >= t_min & t_exp{curve_idx} <= t_max;

        plot(t_exp{curve_idx}(idx), y_exp{curve_idx}(idx), '-', ...
            'Color', colors_exp{i}, ...
            'LineWidth', 2.3, ...
            'DisplayName', ['Exp. ' signal_names{i}]);
    end

    xlabel('Time [s]');
    ylabel(y_label);
    title(plot_title);
    legend('Location','bestoutside');
    xlim([t_min - x_margin, t_max + x_margin]);

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