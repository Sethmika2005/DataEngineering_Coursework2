T = readtable('Womens Clothing E-Commerce Reviews.csv');
%Getting the necessary collumn and 50 rows
Text=T.ReviewText(1:50);

    %Lowercase
    LowerCaseText=lower(Text);

    % Erase punctuation
    NoPunctuationText = erasePunctuation(LowerCaseText);

    % Tokenize the text
    Tokens = tokenizedDocument(NoPunctuationText);

    %Remove the stop words from the list of tokens, using MATLAB's default stopWords list
    StopWords = {'the', 'and', 'is', 'in', 'it', 'to', 'of', 'a', 'for', 'i',...
    'you', 'he', 'she', 'it', 'they', 'them', 'theirs', 'us', 'me'}; %For reference the list of the stopwords
    FilteredTokens=removeWords(Tokens,StopWords);%% experiemented with lists of stop words too but after even removing deafult version of stopwords tokens had meaning, and processed more faster as the deafult versions covers a large area of stop words.
    
    % Stemming and lemmatization

    %Stemming tokens
    StemmedTokens=normalizeWords(FilteredTokens,'Style','stem');

    %Lemmatising tokens - preserves the meaning
    LemmatisedTokens=normalizeWords(FilteredTokens,'Style','lemma');

    %% Text Vectorization
    % Bag-of-Words
    
    BoWFilteredTokens=bagOfWords(FilteredTokens);
    BoWStemmedTokens=bagOfWords(StemmedTokens);
    BoWLemmatisedTokens=bagOfWords(LemmatisedTokens);
    

    % Term Frequency–Inverse Document Frequency
    
    TfidFilteredTokens = tfidf(BoWFilteredTokens,FilteredTokens);
    TfidStemmedTokens = tfidf(BoWStemmedTokens,StemmedTokens);
    TfidLemmatisedTokens = tfidf(BoWLemmatisedTokens,LemmatisedTokens);

    
    %figure
    %wordcloud(BoWFiltered); %%With the use of the word cloud sentiments were collected



% Create a structure to store information
CurrentTextInfo.Text = (Text);
CurrentTextInfo.BagofWordsTokens = (BoWFilteredTokens.Vocabulary);
CurrentTextInfo.TFIDF = num2cell(full(TfidFilteredTokens));

% Convert the cell array to JSON format
JsonString = jsonencode(CurrentTextInfo, 'PrettyPrint', true);

% Write the JSON string to a file
JsonFilePath = 'w1985751_part2.json';
Fid = fopen(JsonFilePath, 'w');
fprintf(Fid, '%s\n', JsonString);
fclose(Fid);