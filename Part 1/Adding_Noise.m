%Specify the folders
ImageFolder = '50_images';
NoisyFolder = 'noisy_images';

% Create the "noisy_images" folder if it doesn't exist
if ~exist(NoisyFolder, 'dir')
    mkdir(NoisyFolder);
end

% Get the list of the names of the image files with jpeg extension
ImageList = dir(fullfile(ImageFolder, '*.jpeg'));


% loop through each image file
for i = 1:length(ImageList)
    
    % read the image
    Image_Name = ImageList(i).name;
    ImagePath = fullfile(ImageFolder,Image_Name );
    Image = imread(ImagePath);
    
    % add noise to the image
    NoiseImage = imnoise(Image, 'gaussian', 0, 0.01);
    
    % save the noisy image in the new folder
    noisy_image_path = fullfile(NoisyFolder, Image_Name);
    imwrite(NoiseImage, noisy_image_path);
end

