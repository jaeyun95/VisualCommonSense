function retrieve_relationship_label(root, search_description, model, use_threshold, ...
    use_merged_relationships, use_feature_difference, min_num_images, min_images_unlabeled, ...
    min_num_edges, use_approx, save_str)
    display([search_description ' ' model]);
    
    %Cross Validation
    [truth_cubic_result, ~, ~, ~] = ...
        run_cross_validation(root, search_description, 1, use_feature_difference, ...
        true, model, use_threshold, use_merged_relationships, min_num_images, ...
        min_num_edges, use_approx, save_str);

    %Results on unknown edges
    [cubic_result, ~] = run_classify_unlabeled(root, ... 
        search_description, false, use_feature_difference, true, model, ...
        use_threshold, use_merged_relationships, min_num_images, min_num_edges, ...
        min_images_unlabeled, use_approx, save_str);

    combined_header = [truth_cubic_result(1, :) cubic_result(1, ~ismember(cubic_result(1,:), truth_cubic_result(1, :)))];
    combined_result = cell(size(truth_cubic_result,1)+size(cubic_result,1)-1, length(combined_header)+1);
    combined_result(1,:) =[combined_header, 'Has Truth'];
    [loc, lia] = ismember(combined_result(1,:), truth_cubic_result(1, :));
    combined_result(2:size(truth_cubic_result,1), loc) = truth_cubic_result(2:end, lia(loc));
    combined_result(2:size(truth_cubic_result,1), end) = {1};
    [loc, lia] = ismember(combined_result(1,:), cubic_result(1, :));
    combined_result(size(truth_cubic_result,1)+1:end, loc) = cubic_result(2:end, lia(loc));
    combined_result(size(truth_cubic_result,1)+1:end, end) = {0};

    combined_save = sprintf('%s/transfer/multi_class_%s_%s.txt', root, search_description, save_str);
    cell2csv(combined_save, combined_result, '\t');

    header = {'Classifier', 'Accuracy', 'Recall' , 'Precision', 'Recall@3', 'Precision@3'};
    error_rates_result = [header; [{'Cubic'; 'Gauss'}, num2cell(error_rates)]];
    save_path = sprintf('%s/transfer/%s_%s_multi_class_error.txt', root, search_description, save_str);
    cell2csv(save_path, error_rates_result, '\t');
end
