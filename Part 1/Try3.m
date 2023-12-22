% Specify the original folder and the new folder
original_folder = 'images';
new_folder = 'image_renamed';

% Create the new folder if it does not exist
if ~exist(new_folder, 'dir')
    mkdir(new_folder);
end

% Get the names of the image files in the original folder
image_files = dir(fullfile(original_folder, '*.jpeg')); % Assuming the images are in jpeg format
image_names = {image_files.name};

% Loop over the image files and rename them
for i = 1:length(image_names)
    % Get the old name and the new name
    old_name = image_names{i};
    new_name = sprintf('image_%d.jpeg', i); % You can change the format of the new name as you wish

    % Move the file from the original folder to the new folder with the new name
    copyfile(fullfile(original_folder, old_name), fullfile(new_folder, new_name));
    
    disp(['Renamed and moved: ', old_name, ' to ', new_name])
end

% Get the list of renamed files in the 'image_renamed' folder
renamedFiles = dir(fullfile(new_folder, '*.jpeg'));
destinationFolder = new_folder;

for i = 1:length(renamedFiles)
    currentImagePath = fullfile(destinationFolder, renamedFiles(i).name);
    Original_Image = imread(currentImagePath);

    % Resizing the image to 500x500 pixels - "resizedImage"
    resizedImage = imresize(Original_Image, [500, 500]);
    
    % Opening an interactive window to rotate the image
    figure(3);
    imshow(resizedImage);
    title('Resized image');
    rotatedImage = imrotate(resizedImage, input('Enter rotation angle (in degrees): '));
    close;

    % Image Filtering
    % Reduce the noise of the image using a Gaussian Filter
    denoised = imgaussfilt(rotatedImage, 6);

    % Display the original & resized & rotated image & denoised image
    figure(5);
    subplot(2, 2, 1);
    imshow(Original_Image);
    title('Original image');
    subplot(2, 2, 2);
    imshow(resizedImage);
    title('Resized Image');
    subplot(2, 2, 3);
    imshow(rotatedImage);
    title('Rotated image');
    subplot(2, 2, 4);
    imshow(denoised);
    title('Denoised Image (Gaussian)');

end
