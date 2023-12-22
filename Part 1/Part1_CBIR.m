originalFolder = 'images';
preprocessedFolder = 'preprocessed images';

% Create the "preprocessed images" folder if it doesn't exist
if ~exist(preprocessedFolder, 'dir')
    mkdir(preprocessedFolder);
end

% Get the list of the names of the image files with jpeg extension
ImageList = dir(fullfile('images', '*.jpeg'));

for i = 1:length(ImageList)
    currentImagePath = fullfile(originalFolder, ImageList(i).name);
    Original_Image = imread(currentImagePath);

    % Resizing the image to 500x500 pixels 
    resizedImage = imresize(Original_Image, [500, 500]);
    
    % Opening an interactive window to rotate the image
    figure(1);
    imshow(resizedImage);
    title('Resized image');
    %Prompt user to enter the roation angle
    rotationAngle = input('Enter rotation angle (in degrees): ');
    rotatedImage = imrotate(resizedImage, rotationAngle); 
    close;

    % Reduce the noise of the image using a Gaussian Filter
    denoised = imgaussfilt(rotatedImage, 3);
    
    %For the preprocessed image generate a new image, and save the
    ...preprocessed image in 'preprocessed images' folder
    outputFileName = sprintf('image_%d.jpeg', i);
    outputFilePath = fullfile(preprocessedFolder, outputFileName);
    imwrite(denoised, outputFilePath);
end

