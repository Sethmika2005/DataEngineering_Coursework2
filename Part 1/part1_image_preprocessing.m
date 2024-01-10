%Specify the folders
OriginalFolder = 'original_images';
PreprocessedFolder = 'preprocessed_images';


% Create the "preprocessed images" folder if it doesn't exist
if ~exist(PreprocessedFolder, 'dir')
    mkdir(PreprocessedFolder);
end

% Get the list of the names of the image files with jpeg extension
ImageList = dir(fullfile(OriginalFolder, '*.jpeg'));

% Preallocating FeaturesArray to improve efficiency(requested by MATLAB)
FeaturesArray = cell(1, length(ImageList));

% Load URLs from the CSV file
URL = 'image_address.xlsx'; 
ImageAddressTable = readtable(URL);
WebImageAddress = ImageAddressTable.WebImageAddress;
GithubOriginalImageAddress = ImageAddressTable.GithubOriginalImageAddress;
GithubPreprocessedImageAddress = ImageAddressTable.GithubPreprocessedImageAddress;

% Loading the image with metadata (tags)
ImageTags = 'image_tags.xlsx';
TagsTable = readtable(ImageTags);
ImageId = TagsTable.ImageId;
Tags = TagsTable.Tags;
Description = TagsTable.Description;

%Ask the user if they wish to see the original and denoised image side by side
DenoiseImages = input('Do you wish to see the original and denoised image side by side? (yes/no): ', 's');
DenoiseImages = strcmpi(DenoiseImages, 'yes');

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
    
    % Reduce the noise of the image using a Gaussian Filter
    DenoisedImage = imgaussfilt(ResizedImage, 1); 

    if DenoiseImages
       figure();
       subplot(1,2,1);
       imshow(ResizedImage);
       title('Resized image');
       subplot(1,2,2)
       imshow(DenoisedImage);
       title('Denoised Image');
    end

    % Rotate the image if the user wants to rotate
    if RotateImages
        % Opening an interactive window to rotate the image
        figure(2);
        imshow(DenoisedImage);
        title('Denoised image');
        
        % Prompt the user to enter the rotation angle
        RotationAngle = input('Enter rotation angle (in degrees): ');
        RotatedImage = imrotate(DenoisedImage, RotationAngle); 
        close;
    else
        RotatedImage = DenoisedImage; 
    end

   
    % Saving the pre-processed images in 'preprocessed images' folder
    OutputFileName = sprintf('image_%02d.jpeg', i);
    OutputFilePath = fullfile(PreprocessedFolder, OutputFileName);
    imwrite(RotatedImage, OutputFilePath);
    
    
    %% Image Feature Extraction

    % Read the preprocessed image
    PreprocessedImage = imread(OutputFilePath);
    
    %* Colour Features*
    
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
    Glcm = graycomatrix(GreyImage, 'Offset', [0 1; -1 1; -1 0; -1 -1]); 
    GlcmStats = graycoprops(Glcm, {'Contrast', 'Energy', 'Correlation', 'Homogeneity'});
    
    % Entropy
    E = entropyfilt(GreyImage); % Local entropy of the image
    MeanE = mean(E(:)); % Mean of the local entropy
    StdE = std(E(:)); % Standard deviation of the local entropy
    SkewE = skewness(E(:)); % Skewness of the local entropy
    
    % Standard deviation
    S = stdfilt(GreyImage); % Local standard deviation of the image
    MeanS = mean(S(:)); % Mean of the local standard deviation
    StdS = std(S(:)); % Standard deviation of the local standard deviation
    SkewS = skewness(S(:)); % Skewness of the local standard deviation
    
    % LBP
    LBP = extractLBPFeatures(GreyImage); % Extract the LBP features
    MeanLBP = mean(LBP); % Mean of the LBP features
    StdLBP = std(LBP); % Standard deviation of the LBP features
    SkewLBP = skewness(LBP); % Skewness of the LBP features
    

    % *Shape Features*
    % Binarize the image using golbal threshold
    BinaryImages = imbinarize(GreyImage, 'global');

    % Invert the image if mean binary value is greater than 0.5
    MeanBinaryImage = mean(BinaryImages(:));
    if MeanBinaryImage > 0.5 
        % Use imcomplement to invert the image
        ImImages = imcomplement(BinaryImages);
    else
        ImImages = BinaryImages;
    end
    
    % To obtain the total number of connected components
    CcImages = bwconncomp(ImImages);
    
    % To measure geometric properties of the image
    GeoFeatures = regionprops(CcImages, 'Area', 'Centroid', 'Circularity', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity', 'Orientation', 'FilledArea', 'Perimeter');

    % Calculate mean,standard deviation and skewness for each measurement
    % Area
    MeanArea = mean([GeoFeatures.Area]); % Mean area
    StdArea = std([GeoFeatures.Area]);   % Standard deviation of the area
    SkewArea = skewness([GeoFeatures.Area]); % Skewness of the area
    
    %Centroid
    MeanCentroid = mean([GeoFeatures.Centroid]); % Mean Centroid
    StdCentroid = std([GeoFeatures.Centroid]);   % Standard deviation of the Centroid
    SkewCentroid = skewness([GeoFeatures.Centroid]); % Skewness of the Centroid

    % Circularity
    MeanCircularity = mean([GeoFeatures.Circularity]); % Mean circularity
    StdCircularity = std([GeoFeatures.Circularity]);   % Standard deviation of the circularity
    SkewCircularity = skewness([GeoFeatures.Circularity]); % Skewness of the circularity
    
    % Major Axis Length
    MeanMajorAxisLength = mean([GeoFeatures.MajorAxisLength]); % Mean major axis length
    StdMajorAxisLength = std([GeoFeatures.MajorAxisLength]);   % Standard deviation of the major axis length
    SkewMajorAxisLength = skewness([GeoFeatures.MajorAxisLength]); % Skewness of the major axis length
    
    % Minor Axis Length
    MeanMinorAxisLength = mean([GeoFeatures.MinorAxisLength]); % Mean minor axis length
    StdMinorAxisLength = std([GeoFeatures.MinorAxisLength]);   % Standard deviation of the minor axis length
    SkewMinorAxisLength = skewness([GeoFeatures.MinorAxisLength]); % Skewness of the minor axis length
    
    % Eccentricity
    MeanEccentricity = mean([GeoFeatures.Eccentricity]); % Mean eccentricity
    StdEccentricity = std([GeoFeatures.Eccentricity]);   % Standard deviation of the eccentricity
    SkewEccentricity = skewness([GeoFeatures.Eccentricity]); % Skewness of the eccentricity
    
    % Orientation
    MeanOrientation = mean([GeoFeatures.Orientation]); % Mean orientation
    StdOrientation = std([GeoFeatures.Orientation]);   % Standard deviation of the orientation
    SkewOrientation = skewness([GeoFeatures.Orientation]); % Skewness of the orientation
    
    % Filled Area
    MeanFilledArea = mean([GeoFeatures.FilledArea]); % Mean filled area
    StdFilledArea = std([GeoFeatures.FilledArea]);   % Standard deviation of the filled area
    SkewFilledArea = skewness([GeoFeatures.FilledArea]); % Skewness of the filled area
    
    % Perimeter
    MeanPerimeter = mean([GeoFeatures.Perimeter]); % Mean perimeter
    StdPerimeter = std([GeoFeatures.Perimeter]);   % Standard deviation of the perimeter
    SkewPerimeter = skewness([GeoFeatures.Perimeter]); % Skewness of the perimeter

    %% Save in JSON File

    % Create a structure for the current image
    CurrentImageInfo.ImageId = ImageId{i};
    CurrentImageInfo.WebImageAddress = WebImageAddress{i};
    CurrentImageInfo.GithubOriginalImageAddress = GithubOriginalImageAddress {i};
    CurrentImageInfo.GithubPreprocessedImageAddress = GithubPreprocessedImageAddress{i};
    CurrentImageInfo.Tags = Tags{i};
    CurrentImageInfo.Description = Description{i};
    CurrentImageInfo.Size = CcImages.ImageSize;
    
    % Channel pixel intensities
    CurrentImageInfo.ColourFeatures.Mean = struct('Red', RedMean, 'Green', GreenMean, 'Blue', BlueMean);
    CurrentImageInfo.ColourFeatures.Normalization = struct('Red', RedNorm, 'Green', GreenNorm, 'Blue', BlueNorm);

    % Texture Features
    CurrentImageInfo.TextureFeatures.GLCM = GlcmStats;
    CurrentImageInfo.TextureFeatures.Entropy = struct('Mean', MeanE, 'Standard_Deviation', StdE, 'Skewness', SkewE);
    CurrentImageInfo.TextureFeatures.StandardDeviation = struct('Mean', MeanS, 'Standard_Deviation', StdS, 'Skewness', SkewS);
    CurrentImageInfo.TextureFeatures.LBP = struct('Mean', MeanLBP, 'Standard_Deviation', StdLBP, 'Skewness', SkewLBP);

    % Shape Features
    CurrentImageInfo.ShapeFeatures.Area = struct('Mean', MeanArea, 'Standard_Deviation', StdArea, 'Skewness', SkewArea);
    CurrentImageInfo.ShapeFeatures.Centroid = struct('Mean', MeanCentroid, 'Standard_Deviation', StdCentroid, 'Skewness', SkewCentroid);
    CurrentImageInfo.ShapeFeatures.Circularity = struct('Mean', MeanCircularity, 'Standard_Deviation', StdCircularity, 'Skewness', SkewCircularity);
    CurrentImageInfo.ShapeFeatures.MajorAxisLength = struct('Mean', MeanMajorAxisLength, 'Standard_Deviation', StdMajorAxisLength, 'Skewness', SkewMajorAxisLength);
    CurrentImageInfo.ShapeFeatures.MinorAxisLength = struct('Mean', MeanMinorAxisLength, 'Standard_Deviation', StdMinorAxisLength, 'Skewness', SkewMinorAxisLength);
    CurrentImageInfo.ShapeFeatures.Eccentricity = struct('Mean', MeanEccentricity, 'Standard_Deviation', StdEccentricity, 'Skewness', SkewEccentricity);
    CurrentImageInfo.ShapeFeatures.Orientation = struct('Mean', MeanOrientation, 'Standard_Deviation', StdOrientation, 'Skewness', SkewOrientation);
    CurrentImageInfo.ShapeFeatures.FilledArea = struct('Mean', MeanFilledArea, 'Standard_Deviation', StdFilledArea, 'Skewness', SkewFilledArea);
    CurrentImageInfo.ShapeFeatures.Perimeter = struct('Mean', MeanPerimeter, 'Standard_Deviation', StdPerimeter, 'Skewness', SkewPerimeter);

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


