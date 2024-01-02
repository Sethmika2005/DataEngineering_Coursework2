% get the list of image files in the folder
image_files = dir('50_images/*.jpeg'); % change the extension if needed
% create a new folder to store the noisy images
if ~exist('noisy images', 'dir')
    mkdir('noisy images');
end
% loop through each image file
for i = 1:length(image_files)
    % read the image
    image_name = image_files(i).name;
    image_path = fullfile('50_images', image_name);
    I = imread(image_path);
    % add noise to the image
    J = imnoise(I, 'gaussian', 0, 0.01);
    % save the noisy image in the new folder
    noisy_image_path = fullfile('noisy images', image_name);
    imwrite(J, noisy_image_path);
end

