
% Specify the folder
OriginalTextFolder = 'original_text';

% Get the list of the names of the text files
FileList = dir(fullfile(OriginalTextFolder, '*.txt'));

% Loop through the files
for i = 1:length(FileList)
    %% Text pre-processing
    % Get the file name
    FileName = FileList(i).name;

    % File path
    FilePath = fullfile(OriginalTextFolder, FileName); 

    % File reading
    Text = fileread(FilePath);

    % Lowercase
    LowerCaseText = lower(Text);

    % Erase punctuation
    NoPunctuationText = erasePunctuation(LowerCaseText);

    % Tokenize the text
    Tokens = tokenizedDocument(NoPunctuationText);

    % Remove the stop words from the list of tokens, using MATLAB's default stopWords list
    StopWords = {'the', 'and', 'is', 'in', 'it', 'to', 'of', 'a', 'for', 'i', ...
        'you', 'he', 'she', 'it', 'they', 'them', 'theirs', 'us', 'me'};
    FilteredTokens = removeWords(Tokens, StopWords);
    
    BoWAll = bagOfWords(FilteredTokens);
    figure
    wordcloud(BoWAll);

end
