% Specifyed the folder path
OriginalTextFolder = 'original_text'; 
PreprocessedTextFolder = 'preprocessed_text';

% Create the PreprocessedTextFolder if it doesn't exist
if ~exist(PreprocessedTextFolder, 'dir')
    mkdir(PreprocessedTextFolder);
end

% Loaded sentiment data from 'sentiments.csv'
SentimentsTable = readtable('sentiment.csv');
Sentiments = SentimentsTable.Sentiment;

% List of the Document names
TextList = dir(fullfile(OriginalTextFolder, '*.txt'));

% Initialized arrays to store text and corresponding IDs
TextDataAll = cell(length(TextList), 1);
DocIdsAll = cell(length(TextList), 1);

% Loop through each document
for i = 1:length(TextList)
    % Used the actual filename obtained from dir
    FileName = fullfile(OriginalTextFolder, TextList(i).name); 
    
    % Read the text from the document
    Text = fileread(FileName);
    
    % Stored the text and document ID
    TextDataAll{i} = Text;
    DocIdsAll{i} = sprintf('document_%02d', i);
end

%% Text Preprocessing

% Converted text to lowercase
LowercaseDataAll = lower(TextDataAll);

% Erased punctuation
NpunctDataAll = erasePunctuation(LowercaseDataAll);

% Tokenized the text
TokensAll = tokenizedDocument(NpunctDataAll);

% Removed stop words
StopWords = {'the', 'and', 'is', 'in', 'it', 'to', 'of', 'a', 'for', 'i',...
    'you', 'he', 'she', 'it', 'they', 'them', 'theirs', 'us', 'me'};
FiltTokensAll = removeWords(TokensAll, StopWords);

%% Saving in CSV
for j = 1:length(FiltTokensAll)
    
    TextArray = string(FiltTokensAll(j));

    % Joining the processed reviews into a single string
    TextArrayStr = strjoin(TextArray, ' ');

    % Saving the processed text document as a single line
    ProcessedTextPath = fullfile('preprocessed_text/', sprintf('pre-processed_document%02d.txt', j));
    writelines(TextArrayStr, ProcessedTextPath);
end

%% Text Vectorization

% Bag-of-Words Vectorization
% Created Bag-of-Words once for filtered tokens
BoWAll = bagOfWords(FiltTokensAll);
% Encoded the documents
VectorizedDocsAll = encode(BoWAll, FiltTokensAll);
VectorsAll = full(VectorizedDocsAll);

%Term Frequency–Inverse Document Frequency
TfidfAll = tfidf(BoWAll, FiltTokensAll);% Calculated TF-IDF once for filtered tokens


%% Create a JSON file to store the meata data, features and sentiments*

% *Extrating the Bag-of-Words*
% Transformed tokens to a cell array
Tok2CellAll = doc2cell(FiltTokensAll);

% Extracted the vocabulary from the Bag-of-Words
ExtBowAll = BoWAll.Vocabulary;

% Created a table with vectors to store Bag-of-Words
VdfTableAll = array2table(VectorsAll, 'VariableNames', ExtBowAll);
VdfStructAll = table2struct(VdfTableAll);

% Converted the Bag-of-Words struct to a cell array
VdfCellAll = cell(length(TextList), 1);
for i = 1:length(TextList)
    VdfCellAll{i, 1} = VdfStructAll(i);
end

% *Extracting Term Frequency–Inverse Document Frequency*
% Created a table with TF-IDF vectors
TfidfTableAll = array2table(full(TfidfAll), 'VariableNames', ExtBowAll);
TfidfStructAll = table2struct(TfidfTableAll);

% Converted the struct to a cell array
TfidfCellAll = cell(length(TextList), 1);
for i = 1:length(TextList)
    TfidfCellAll{i, 1} = TfidfStructAll(i);
end

% Created a review object for the JSON file
ReviewObjectAll = struct('DocumentID', DocIdsAll, ...
    'Sentiment', Sentiments,...
    'Tokens', Tok2CellAll, ...
    'Vectors', VdfCellAll, ...
    'TFIDF', TfidfCellAll);

% Converted the review object to JSON
ReviewEncodeAll = jsonencode(ReviewObjectAll, 'PrettyPrint', true);

% Provided a file name to store the review objects
ReviewJsonFilePathAll = 'w1985751_part2.json';

% Wrote the JSON string to a file
FidAll = fopen(ReviewJsonFilePathAll, 'w');
fprintf(FidAll, ReviewEncodeAll);
fclose(FidAll);

%%  Create a JSON file to store the text and sentiments

%Extracting the tokenized texts
TextStructAll = FiltTokensAll;

% Converted the struct to a cell array
TextCellAll = cell(length(TextList), 1);
for i = 1:length(TextList)
    TextCellAll{i, 1} = FiltTokensAll(i);
end

%Create a text object for the JSON file
TextObjectAll = struct('DocumentID', DocIdsAll, ...
    'Text',TextCellAll,...
    'Sentiment', Sentiments);

% Converted the review object to JSON
TextEncodeAll = jsonencode(TextObjectAll, 'PrettyPrint', true);

% Provided a file name to store the review objects
TextJsonFilePathAll = 'w1985751_part2_text_sentiment.json';

% Wrote the JSON string to a file
TextFidAll = fopen(TextJsonFilePathAll, 'w');
fprintf(TextFidAll, TextEncodeAll);
fclose(TextFidAll);