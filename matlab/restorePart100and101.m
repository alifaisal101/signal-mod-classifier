data_folder = 'stratified_dataset_parts';

for i = [100, 101]
    file_path = fullfile(data_folder, sprintf('Part_%d_MixedStratified.mat', i));
    fprintf("🔁 Renaming fixed_labels to part_labels in Part_%d.mat\n", i);

    load(file_path, 'fixed_labels', 'part_spectrograms');
    part_labels = fixed_labels;  % rename back
    save(file_path, 'part_spectrograms', 'part_labels', '-v7.3');
end

fprintf("✅ fixed_labels renamed back to part_labels for Part_100 and Part_101.\n");
