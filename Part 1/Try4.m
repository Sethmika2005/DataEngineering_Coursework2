function preprocessImage(imageName, destinationFolder)
    % This function preprocesses an image file and saves it to a destination folder
    % Inputs:
    % imageName: a string that contains the name of the image file
    % destinationFolder: a string that contains the name of the destination folder
    % Outputs: none
    
    % Define the source folder for the image files
    sourceFolder = 'images';
    
    % Create the destination folder if it does not exist
    if ~exist(destinationFolder, 'dir')
        mkdir(destinationFolder);
    end
    
    % Get the full path of the image file
    imagePath = fullfile(sourceFolder, imageName);
    
    % Read the image data
    originalImage = imread(imagePath);
    
    % Define the desired image size and rotation angle
    imageSize = [500, 500]; % in pixels
    rotationAngle = input('Enter rotation angle (in degrees): '); % user input
    
    % Resize the image to the desired size
    resizedImage = imresize(originalImage, imageSize);
    
    % Rotate the image by the desired angle
    rotatedImage = imrotate(resizedImage, rotationAngle);
    
    % Reduce the noise of the image using a Gaussian filter
    denoisedImage = imgaussfilt(rotatedImage, 3);
    
    % Generate a new name for the preprocessed image
    outputName = sprintf('image_%d.jpeg', i);
    
    % Save the preprocessed image to the destination folder
    outputPath = fullfile(destinationFolder, outputName);
    imwrite(denoisedImage, outputPath);
    
    % Display a message to indicate the progress
    disp(['Preprocessed and saved: ', imageName, ' to ', outputName])
end

% Define the source and destination folders for the image files
sourceFolder = 'images';
destinationFolder = 'preprocessed images';

% Get the list of image files in the source folder
imageFiles = dir(fullfile(sourceFolder, '*.jpeg'));

% Loop over the image files and preprocess them using the function
for i = 1:length(imageFiles)
    % Get the current image file name
    imageName = imageFiles(i).name;
    
    % Call the function to preprocess the image and save it to the destination folder
    preprocessImage(imageName, destinationFolder);
end
