OriginalFolder = 'noisy images';
PreprocessedFolder = 'preprocessed images';

% Create the "preprocessed images" folder if it doesn't exist
if ~exist(PreprocessedFolder, 'dir')
    mkdir(PreprocessedFolder);
end

% Get the list of the names of the image files with jpeg extension
ImageList = dir(fullfile(OriginalFolder, '*.jpeg'));

% Preallocating FeaturesArray to improve efficiency(requested by MATLAB)
FeaturesArray = cell(1, length(ImageList));

% Load URLs from the CSV file
URL = 'url.xlsx'; 
UrlTable = readtable(URL);
ImageUrl = UrlTable.URL;

% Loading the image with metadata (tags)
ImageTags = 'image_tags.xlsx';
TagsTable = readtable(ImageTags);
Tags = TagsTable.Tags;

% Ask the user if they want to rotate the images
RotateImages = input('Do you want to rotate the images? (yes/no): ', 's');
RotateImages = strcmpi(RotateImages, 'yes');

% A loop for image pre-processing and image feature extraction for each 50 images
for i = 1:length(ImageList)
    %% Image Pre-processing 
    InputImagePath = fullfile(OriginalFolder, ImageList(i).name);
    OriginalImage = imread(InputImagePath);

    % Resizing the image to 500x500 pixels 
    ResizedImage = imresize(OriginalImage, [500, 500]);
    
    % Rotate the image if the user wants to rotate
    if RotateImages
        % Opening an interactive window to rotate the image
        figure(1);
        imshow(ResizedImage);
        title('Resized image');
        
        % Prompt the user to enter the rotation angle
        RotationAngle = input('Enter rotation angle (in degrees): ');
        RotatedImage = imrotate(ResizedImage, RotationAngle); 
        close;
    else
        RotatedImage = ResizedImage; 
    end

    % Reduce the noise of the image using a Gaussian Filter
    Denoised = imgaussfilt(RotatedImage, 0.5); %%experimented with several values and decided 0.5 was the optimal value to denoise without bluring the image much

    % Saving the pre-processed images in 'preprocessed images' folder
    OutputFileName = sprintf('image_%d.jpeg', i);
    OutputFilePath = fullfile(PreprocessedFolder, OutputFileName);
    imwrite(Denoised, OutputFilePath);
    
    %% Image Feature Extraction

    % Read the preprocessed image
    PreprocessedImage = imread(OutputFilePath);
    
    % MEAN of channel pixel intensity - using mean2 function
    RedMean = mean2(PreprocessedImage(:,:,1));
    GreenMean = mean2(PreprocessedImage(:,:,2));
    BlueMean = mean2(PreprocessedImage(:,:,3));

    % NORM of channel pixel intensity - using norm function
    RedNorm = norm(double(PreprocessedImage(:,:,1)));
    GreenNorm = norm(double(PreprocessedImage(:,:,2)));
    BlueNorm = norm(double(PreprocessedImage(:,:,3)));
    
    %*Texture Features*

    % GLCM features - statistics of the GLCM
    GreyImage = rgb2gray(PreprocessedImage);
    Glcm = graycomatrix(GreyImage, 'Offset', [0 1; -1 1; -1 0; -1 -1]); %%[0 1; -1 1; -1 0; -1 -1] was chosen as there is no domient orientation for the images therefore it will take the pixel relationship horizontally, vertically, and diagonally, and since the images are resized to 500x500 used a smaller offset of 1 pixel displacement to avoid losing information
    GlcmStats = graycoprops(Glcm, {'Contrast', 'Energy', 'Correlation', 'Homogeneity'});
    
    % Entropy
    E = entropyfilt(GreyImage); % Local entropy of the image
    MeanE = mean(E(:)); % Mean of the local entropy
    StdE = std(E(:)); % Standard deviation of the local entropy
    
    % Standard deviation
    S = stdfilt(GreyImage); % Local standard deviation of the image
    MeanS = mean(S(:)); % Mean of the local standard deviation
    StdS = std(S(:)); % Standard deviation of the local standard deviation
    
    % LBP
    LBP = extractLBPFeatures(GreyImage); % Extract the LBP features
    MeanLBP = mean(LBP); % Mean of the LBP features
    StdLBP = std(LBP); % Standard deviation of the LBP features
    
    % HOG
    HOG = extractHOGFeatures(GreyImage); % Extract the HOG features
    MeanHOG = mean(HOG); % Mean of the HOG features
    StdHOG = std(HOG); % Standard deviation of the HOG features
    
    % *Shape Features*
    % Applying binarization and connected components before getting the region props of the image
    % Applying binarization to easily identify and measure the regions of interest in the image
    BinaryImages = imbinarize(GreyImage, 'global'); %% The global binarization method was used to binarize the images of animals, because most of them have high contrast with the background.
    
    % Invert the image if mean binary value is greater than 0.5
    MeanBinaryImage = mean(BinaryImages(:));
    if MeanBinaryImage > 0.5 %% 0.5 was used as it the midpoint of the binary range values
        % Use imcomplement to invert the image
        ImImages = imcomplement(BinaryImages);
    else
        ImImages = BinaryImages;
    end
    
    % To obtain the total number of connected components
    CcImages = bwconncomp(ImImages);
    
    % To measure geometric properties of the image
    GeoFeatures = regionprops(CcImages, 'Area', 'Centroid', 'Circularity', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity', 'Orientation', 'FilledArea', 'Perimeter');

    % Calculate mean and standard deviation for each measurement
    MeanArea = mean([GeoFeatures.Area]);
    StdArea = std([GeoFeatures.Area]);

    MeanCircularity = mean([GeoFeatures.Circularity]);
    StdCircularity = std([GeoFeatures.Circularity]);

    MeanMajorAxisLength = mean([GeoFeatures.MajorAxisLength]);
    StdMajorAxisLength = std([GeoFeatures.MajorAxisLength]);

    MeanMinorAxisLength = mean([GeoFeatures.MinorAxisLength]);
    StdMinorAxisLength = std([GeoFeatures.MinorAxisLength]);

    MeanEccentricity = mean([GeoFeatures.Eccentricity]);
    StdEccentricity = std([GeoFeatures.Eccentricity]);

    MeanOrientation = mean([GeoFeatures.Orientation]);
    StdOrientation = std([GeoFeatures.Orientation]);

    MeanFilledArea = mean([GeoFeatures.FilledArea]);
    StdFilledArea = std([GeoFeatures.FilledArea]);

    MeanPerimeter = mean([GeoFeatures.Perimeter]);
    StdPerimeter = std([GeoFeatures.Perimeter]);
        
    %% Save in JSON File
    % Get the list of preprocessed image files
    OutputImageList = dir(fullfile(PreprocessedFolder, '*.jpeg'));

    % Create a structure for the current image
    CurrentImageInfo.ID = OutputImageList(i).name;
    CurrentImageInfo.ImageAddress = ImageUrl{i};
    CurrentImageInfo.Tags = Tags{i};
    CurrentImageInfo.Size = CcImages.ImageSize;
    CurrentImageInfo.Mean = struct('Red', RedMean, 'Green', GreenMean, 'Blue', BlueMean);
    CurrentImageInfo.Normalization = struct('Red', RedNorm, 'Green', GreenNorm, 'Blue', BlueNorm);
    CurrentImageInfo.TextureFeatures.GLCM = GlcmStats;
    CurrentImageInfo.TextureFeatures.Entropy = struct('Mean', MeanE, 'Standard_Deviation', StdE);
    CurrentImageInfo.TextureFeatures.StandardDeviation = struct('Mean', MeanS, 'Standard_Deviation', StdS);
    CurrentImageInfo.TextureFeatures.LBP = struct('Mean', MeanLBP, 'Standard_Deviation', StdLBP);
    CurrentImageInfo.TextureFeatures.HOG = struct('Mean', MeanHOG, 'Standard_Deviation', StdHOG);
    CurrentImageInfo.ShapeFeatures.Area = struct('Mean', MeanArea, 'Standard_Deviation', StdArea);
    CurrentImageInfo.ShapeFeatures.Circularity = struct('Mean', MeanCircularity, 'Standard_Deviation', StdCircularity);
    CurrentImageInfo.ShapeFeatures.MajorAxisLength = struct('Mean', MeanMajorAxisLength, 'Standard_Deviation', StdMajorAxisLength);
    CurrentImageInfo.ShapeFeatures.MinorAxisLength = struct('Mean', MeanMinorAxisLength, 'Standard_Deviation', StdMinorAxisLength);
    CurrentImageInfo.ShapeFeatures.Eccentricity = struct('Mean', MeanEccentricity, 'Standard_Deviation', StdEccentricity);
    CurrentImageInfo.ShapeFeatures.Orientation = struct('Mean', MeanOrientation, 'Standard_Deviation', StdOrientation);
    CurrentImageInfo.ShapeFeatures.FilledArea = struct('Mean', MeanFilledArea, 'Standard_Deviation', StdFilledArea);
    CurrentImageInfo.ShapeFeatures.Perimeter = struct('Mean', MeanPerimeter, 'Standard_Deviation', StdPerimeter);

    % Store the current image info in the cell array
    FeaturesArray{i} = CurrentImageInfo;

end

% Convert the cell array to JSON format
JsonString = jsonencode(FeaturesArray, 'PrettyPrint', true);

% Write the JSON string to the file
JsonFilePath = 'w1985751_part1.json';
Fid = fopen(JsonFilePath, 'w');
fprintf(Fid, '%s\n', JsonString);
fclose(Fid);
