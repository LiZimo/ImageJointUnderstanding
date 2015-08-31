function images = load_images(foldername, filetype)    
    
    folder = dir(strcat(foldername, '/', ['*.', filetype]));
    images = zeros(512, 512, 3, length(folder));            % TODO-Z uniform scaling?

    for i = 1:length(folder)        
        img = imresize(imread(strcat(foldername, '/', folder(i).name)), [512 512]);        
        images(:,:,:,i) = img;
    end

end
