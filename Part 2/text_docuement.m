% Reading the orginial dataset
T=readtable('Womens Clothing E-Commerce Reviews.csv');

% Get a reviews column from the table which is row 5
col = T(:,5);

% Getting the necessary columns of the dataset
rows = col(1:50,:);

% Save the reviews column data to a new CSV file
writetable(rows,'reviews.csv');


% Create the "preprocessed images" folder if it doesn't exist
folder="datasets";
if ~exist(folder, 'dir')
    mkdir(folder);
end

% Read the CSV file and store it in a table
table = readtable('reviews.csv');

% Initialize the counter
counter = 1;

% Loop through each row of the table
for i = 1:height(table)

    % Get the row data as a cell array
    row_data = table2cell(table(i,:));
    
    % Convert the cell array to a string
    row_string = strjoin(row_data, ' ');
    
    % Create the file name based on the counter
    file_name = ['document_', num2str(counter), '.txt'];
    
    % Combine the folder path and the file name
    full_name = fullfile(folder, file_name);
    
    % Write the value to the file
    fid = fopen(full_name,'w'); % Use full_name here
    fprintf(fid,'%s',row_string);
    fclose(fid);
    
    % Increment the counter
    counter = counter + 1;
end
