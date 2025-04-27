data_folder = 'stratified_dataset_parts';
files = dir(fullfile(data_folder, 'Part_*.mat'));

for i = 1:length(files)
    file_path = fullfile(files(i).folder, files(i).name);
    fprintf("🛠 Fixing labels in %s...\n", files(i).name);

    load(file_path, 'part_labels', 'part_spectrograms');
    
    part_labels = regexprep(part_labels, '_SNR.*$', '');  % overwrite with cleaned labels
    
    save(file_path, 'part_spectrograms', 'part_labels', '-v7.3');  % save using same variable name
end

fprintf("✅ All part labels fixed (SNR removed, and variable name preserved).\n");
