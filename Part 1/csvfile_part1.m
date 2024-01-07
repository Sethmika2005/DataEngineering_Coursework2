%Specify the folders
OriginalFolder = 'noisy_images';
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
URL = 'url.xlsx'; 
UrlTable = readtable(URL);
ImageUrl = UrlTable.URL;

% Loading the image with metadata (tags)
ImageTags = 'image_tags.xlsx';
TagsTable = readtable(ImageTags);
ImageId = TagsTable.ImageId;
Tags = TagsTable.Tags;
Description = TagsTable.Description;

% Ask the user if they want to rotate the images
RotateImages = input('Do you want to rotate the images? (yes/no): ', 's');
RotateImages = strcmpi(RotateImages, 'yes');


ImageNormFeatures = table;
TextureFeatures = table;
ShapeFeatures = table;

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
    OutputFileName = sprintf('image_%02d.jpeg', i);
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
%%  Saving in CSV file
    %ImageNormFeature table
    %Storing the features
    NormRow = {sprintf('image_%02d.jpeg', i), ...
        RedMean, GreenMean, BlueMean, ...
        RedNorm, GreenNorm, BlueNorm ...
        };

    % Converting the cell array into a table
    NormTable = cell2table(NormRow);

    % Concatenating the table to ImgFeatures
    ImageNormFeatures = [ImageNormFeatures; NormTable];

    %Texture feature table
    % Storing the texture features
    TextureRow = {sprintf('image_%02d.jpeg', i), ...
        MeanE, StdE, MeanS, StdS, MeanLBP, StdLBP, MeanHOG, StdHOG ...
    };
    
    % Converting the cell array into a table
    TextureTable = cell2table(TextureRow);

    % Concatenating the table to TextureFeatures
    TextureFeatures = [TextureFeatures; TextureTable];

    %Shape feature table
     % Storing the shape features
    ShapeRow = {sprintf('image_%02d.jpeg', i), ...
        MeanArea, StdArea, MeanCircularity, StdCircularity, ...
        MeanMajorAxisLength, StdMajorAxisLength, MeanMinorAxisLength, StdMinorAxisLength, ...
        MeanEccentricity, StdEccentricity, MeanOrientation, StdOrientation, ...
        MeanFilledArea, StdFilledArea, MeanPerimeter, StdPerimeter ...
    };
    % Converting the cell array into a table
    ShapeTable = cell2table(ShapeRow);

    % Concatenating the table to ShapeFeatures
    ShapeFeatures = [ShapeFeatures; ShapeTable];
    %% Save in JSON File


    % Create a structure for the current image
    CurrentImageInfo.ImageId = ImageId{i};
    CurrentImageInfo.ImageAddress = ImageUrl{i};
    CurrentImageInfo.Tags = Tags{i};
    CurrentImageInfo.Description = Description{i};
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

%Norm table
%Creating column names to be included in the CSV File
NormColumn_Names = {'Image_Name', ...
                'Mean_Red', 'Mean_Green', 'Mean_Blue', ...
                'Norm_Red', 'Norm_Green', 'Norm_Blue', ...
                };
% Assigning column names
ImageNormFeatures.Properties.VariableNames = NormColumn_Names;
%Saving the features in a CSV file
NormCSVFilePath = fullfile(pwd, 'ImageNormFeatures.csv');
writetable(ImageNormFeatures, NormCSVFilePath, 'Delimiter', ',', 'WriteVariableNames',true);


%Texture table
%Creating column names to be included in the Texture CSV File
TextureColumnNames = {'Image_Name', ...
    'Entropy_Mean', 'Entropy_Std', 'StdDev_Mean', 'StdDev_Std', 'LBP_Mean', 'LBP_Std', 'HOG_Mean', 'HOG_Std' ...
};
% Assigning column names
TextureFeatures.Properties.VariableNames = TextureColumnNames;
% Saving the texture features in a CSV file
TextureCSVFilePath = fullfile(pwd, 'Texture_Feature.csv');
writetable(TextureFeatures, TextureCSVFilePath, 'Delimiter', ',', 'WriteVariableNames', true);

%Shape Table
%Creating column names to be included in the Shape CSV File
ShapeColumnNames = {'Image_Name', ...
    'Area_Mean', 'Area_Std', 'Circularity_Mean', 'Circularity_Std', ...
    'MajorAxisLength_Mean', 'MajorAxisLength_Std', 'MinorAxisLength_Mean', 'MinorAxisLength_Std', ...
    'Eccentricity_Mean', 'Eccentricity_Std', 'Orientation_Mean', 'Orientation_Std', ...
    'FilledArea_Mean', 'FilledArea_Std', 'Perimeter_Mean', 'Perimeter_Std' ...
};
% Assigning column names
ShapeFeatures.Properties.VariableNames = ShapeColumnNames;
% Saving the shape features in a CSV file
ShapeCSVFilePath = fullfile(pwd, 'Shape_Features.csv');
writetable(ShapeFeatures, ShapeCSVFilePath, 'Delimiter', ',', 'WriteVariableNames', true);