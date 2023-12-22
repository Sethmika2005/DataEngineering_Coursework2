% Get the list of renamed files in the 'images' folder
renamedFiles = dir(fullfile('images', '*.jpeg'));
destinationFolder = 'images';
preprocessedFolder = 'preprocessed images';

% Create the "preprocessed images" folder if it doesn't exist
if ~exist(preprocessedFolder, 'dir')
    mkdir(preprocessedFolder);
end

for i = 1:length(renamedFiles)
    currentImagePath = fullfile(destinationFolder, renamedFiles(i).name);
    Original_Image = imread(currentImagePath);

    % Resizing the image to 500x500 pixels - "resizedImage"
    resizedImage = imresize(Original_Image, [500, 500]);
    
    % Opening an interactive window to rotate the image
    figure(3);
    imshow(resizedImage);
    title('Resized image');
    rotationAngle = input('Enter rotation angle (in degrees): ');
    rotatedImage = imrotate(resizedImage, rotationAngle);
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
    
    outputFileName = sprintf('image_%d.jpeg', i);
    outputFilePath = fullfile(preprocessedFolder, outputFileName);
    imwrite(denoised, outputFilePath);
end

