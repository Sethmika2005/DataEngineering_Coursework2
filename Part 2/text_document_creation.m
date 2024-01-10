
% Reading the orginial dataset
Dataset=readtable('Womens Clothing E-Commerce Reviews.csv');

% Get a reviews column from the table which is row 5
Col = Dataset(:,5);

% Getting the necessary columns of the dataset
FinalTable = Col(1:50,:);

% Save the reviews column data to a new CSV file
writetable(FinalTable,'reviews.csv');


% Create the "preprocessed images" folder if it doesn't exist
folder="original_text";
if ~exist(folder, 'dir')
    mkdir(folder);
end


% Initialize the counter
counter = 1;

% Loop through each row of the table
for i = 1:height(FinalTable)

    % Get the row data as a cell array
    row_data = table2cell(FinalTable(i,:));
    
    % Convert the cell array to a string
    row_string = strjoin(row_data, ' ');
    
    % Create the file name based on the counter
    file_name = sprintf('document_%02d.txt',i);
    
    % Combine the folder path and the file name
    full_name = fullfile(folder, file_name);
    
    % Write the value to the file
    fid = fopen(full_name,'w'); % Use full_name here
    fprintf(fid,'%s',row_string);
    fclose(fid);
    
    % Increment the counter
    counter = counter + 1;
end
