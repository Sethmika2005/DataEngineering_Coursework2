%Specify the folder
OriginalTextFolder = 'datasets';
PreprocessedTextFolder = 'preprocessed_text';

% Create the "preprocessed_text" folder if it doesn't exist
if ~exist(PreprocessedTextFolder, 'dir')
    mkdir(PreprocessedTextFolder);
end

% Initialize accumulators for Bag-of-Words and TF-IDF
TotalBoW = bagOfWords;
TotalTFIDF = bagOfWords;

%Get the list of the names of the text files
FileList = dir(fullfile(OriginalTextFolder, '*.txt'));

%Loop through the files
for i = 1:length(FileList)
    %% Text pre-processing
    %Get the file name
    FileName = FileList(i).name;

    %File path
    FilePath = fullfile(OriginalTextFolder,FileName ); 

    %File reading
    Text = fileread(FilePath);

    %Lowercase
    LowerCaseText=lower(Text);

    % Erase punctuation
    NoPunctuationText = erasePunctuation(LowerCaseText);

    % Tokenize the text
    Tokens = tokenizedDocument(NoPunctuationText);

    %Remove the stop words from the list of tokens, using MATLAB's default stopWords list
    StopWords = {'the', 'and', 'is', 'in', 'it', 'to', 'of', 'a', 'for', 'i',...
    'you', 'he', 'she', 'it', 'they', 'them', 'theirs', 'us', 'me '}; %For reference the list of the stopwords
    FilteredTokens=removeWords(Tokens,StopWords);%% experiemented with lists of stop words too but after even removing deafult version of stopwords tokens had meaning, and processed more faster as the deafult versions covers a large area of stop words.
    
    % Stemming and lemmatization

    %Stemming tokens
    StemmedTokens=normalizeWords(FilteredTokens,'Style','stem');

    %Lemmatising tokens
    LemmatisedTokens=normalizeWords(FilteredTokens,'Style','lemma');

    %% Text Vectorization
    % Bag-of-Words
    
    BoWFiltered=bagOfWords(FilteredTokens);
    BoWStem=bagOfWords(StemmedTokens);
    BoWLemma=bagOfWords(LemmatisedTokens);
    
    % Accumulate Bag-of-Words
    TotalBoW = add(TotalBoW, BoWFiltered);
    TotalBoW = add(TotalBoW, BoWStem);
    TotalBoW = add(TotalBoW, BoWLemma);

    % Term Frequency–Inverse Document Frequency

    TfidTokens = tfidf(BoWFiltered);
    TfidStem = tfidf(BoWStem);
    TfidLemma = tfidf(BoWLemma);

    % Accumulate TF-IDF
    TotalTFIDF = add(TotalTFIDF, TfidTokens);
    TotalTFIDF = add(TotalTFIDF, TfidStem);
    TotalTFIDF = add(TotalTFIDF, TfidLemma);

    %figure
    %wordcloud(BoWFiltered); %%With the use of the word cloud sentiments were collected
    
end
addterms