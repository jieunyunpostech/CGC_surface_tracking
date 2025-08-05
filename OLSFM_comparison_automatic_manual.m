close all
clear all
clc
%%
addpath("C:\Users\owner\Desktop\oblsm\rabbit\fornix\")
load('manual_centroids.mat');  % [N_manual x 2]
load('auto_centroids.mat');    % [N_auto x 2]

threshold = 10;  % pixel distance
gt_matched = false(size(manual_centroids,1),1);
pred_matched = false(size(auto_centroids,1),1);

for i = 1:size(manual_centroids,1)
    dists = sqrt(sum((auto_centroids - manual_centroids(i,:)).^2, 2));
    [min_dist, min_idx] = min(dists);
    if min_dist <= threshold
        gt_matched(i) = true;
        pred_matched(min_idx) = true;
    end
end

TP = sum(gt_matched);
FN = sum(~gt_matched);
FP = sum(~pred_matched);

precision = TP / (TP + FP);
recall = TP / (TP + FN);
accuracy = TP / (TP + FP + FN);

fprintf('TP: %d, FP: %d, FN: %d\n', TP, FP, FN);
fprintf('Precision: %.2f\n', precision);
fprintf('Recall: %.2f\n', recall);
fprintf('Accuracy: %.2f\n', accuracy);