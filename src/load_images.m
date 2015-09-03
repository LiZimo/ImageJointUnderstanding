function images = load_images(foldername, filetype)        
    folder = dir(strcat(foldername, '/', ['*.', filetype]));
%     images = zeros(512, 512, 3, length(folder));            % TODO-Z uniform scaling?
    images = cell(length(folder), 1);
    for i = 1:length(folder)        
        images{i} = imread(strcat(foldername, '/', folder(i).name));
%         img = imresize(
%         images(:,:,:,i) = img;
    end

end
