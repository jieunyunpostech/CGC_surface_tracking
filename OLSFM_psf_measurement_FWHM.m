close all
clear all
clc
%%
addpath('C:/Users/owner/Desktop/deconv&psf/OLSFM_psf2/flat_psf/')
addpath('C:/Users/owner/Desktop/deconv&psf/OLSFM_psf2/45deg_psf/')


%% Flat sample 
file_path1 = "flat_total.csv";
data1 = readtable(file_path1);

x1 = data1{:, 1};

valid_indices = (x1 >= 200) & (x1 <= 800);
x1 = x1(valid_indices);
data1 = data1(valid_indices, :);

y_columns1 = data1.Properties.VariableNames(2:end);

figure(1);
hold on;
colors = lines(width(data1) - 1);
fwhm_values1 = zeros(1, width(data1) - 1);

for i = 2:width(data1)
    y = data1{:, i};
    y = (y - min(y)) / (max(y) - min(y));
    [~, peak_idx] = max(y);
    x_peak = x1(peak_idx);
    x1_shifted = x1 - x_peak;
    
    plot(x1_shifted, y, 'Color', colors(i-1, :), 'DisplayName', y_columns1{i-1});
    
    % FWHM 
    half_max1 = 0.5;
    indices1 = find(y >= half_max1);
    if length(indices1) >= 2
        fwhm1 = x1_shifted(indices1(end)) - x1_shifted(indices1(1));
        fwhm_um1 = fwhm1 * 0.8125 / 25;
    else
        fwhm_um1 = NaN;
    end
    fwhm_values1(i-1) = fwhm_um1;
end

% mean, standard deviation
avg_fwhm1 = nanmean(fwhm_values1);
std_fwhm1 = nanstd(fwhm_values1);
text(0, 0.6, sprintf('Avg FWHM: %.2f ± %.2f um', avg_fwhm1, std_fwhm1), 'FontSize', 12, 'Color', 'k', 'HorizontalAlignment', 'center');

hold off;
ylabel("Normalized Fit: Gaussian values");
title("Flat sample");
legend;
grid on;

disp('FWHM values for each Gaussian curve (Flat):');
disp(fwhm_values1);
disp(['Average FWHM (Flat): ', num2str(avg_fwhm1), ' ± ', num2str(std_fwhm1)]);


%% 45deg sample 
file_path2 = "45deg_total.csv";
data2 = readtable(file_path2);

x2 = data2{:, 1};

valid_indices = (x2 >= 200) & (x2 <= 800);
x2 = x2(valid_indices);
data2 = data2(valid_indices, :);

y_columns2 = data2.Properties.VariableNames(2:end);

figure(2);
hold on;
colors = lines(width(data2) - 1);
fwhm_values2 = zeros(1, width(data2) - 1);

for i = 2:width(data2)
    y = data2{:, i};

    y = (y - min(y)) / (max(y) - min(y));

    [~, peak_idx] = max(y);
    x_peak = x2(peak_idx);

    x2_shifted = x2 - x_peak;
    
    plot(x2_shifted, y, 'Color', colors(i-1, :), 'DisplayName', y_columns2{i-1});
    
    % FWHM 
    half_max2 = 0.5;
    indices2 = find(y >= half_max2);
    if length(indices2) >= 2
        fwhm2 = x2_shifted(indices2(end)) - x2_shifted(indices2(1));
        fwhm_um2 = fwhm2 * 0.8125 / 25;
    else
        fwhm_um2 = NaN;
    end
    fwhm_values2(i-1) = fwhm_um2;
end

% mean, standard deviation
avg_fwhm2 = nanmean(fwhm_values2);
std_fwhm2 = nanstd(fwhm_values2);
text(0, 0.6, sprintf('Avg FWHM: %.2f ± %.2f um', avg_fwhm2, std_fwhm2), 'FontSize', 12, 'Color', 'k', 'HorizontalAlignment', 'center');

hold off;
ylabel("Normalized Fit: Gaussian values");
title("45deg sample");
legend;
grid on;

disp('FWHM values for each Gaussian curve (45deg):');
disp(fwhm_values2);
disp(['Average FWHM (45deg): ', num2str(avg_fwhm2), ' ± ', num2str(std_fwhm2)]);
%%
[h, p] = ttest2(fwhm_values1, fwhm_values2, 'Vartype', 'unequal');
disp(['t-test p-value: ', num2str(p)]);

if p > 0.05
    disp('There is no significant difference between the two datasets (p > 0.05)');
else
    disp('There is a significant difference between the two datasets (p <= 0.05)');
end
