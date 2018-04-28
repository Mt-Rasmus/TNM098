% Lab 3.2

charCells = {};

textfiles ='textfiles';
txtfiles=dir(fullfile(textfiles,'\*.txt*'));
n=numel(txtfiles);
deleteList = [];

for i = 1:n
    
   file=fopen(fullfile(textfiles,txtfiles(i).name));
   A = textscan(file, '%c'); % split into single spring (char).
   str = A{1};
   charCells{i} = strsplit(str', '.');
    
   size = length(charCells{i});
   ait = charCells{i};
   delInd = 1;
   
   for t = 1:size % Loop to delete shorter sentences
       
       str = ait{t};

       if(numel(str) < 50)
           deleteList(delInd) = t; 
           delInd = delInd + 1;
       end
        
   end
    
   charCells{i}(deleteList) = [];
   deleteList = [];
   
end


%%

Lia = {};
matchCount = 1:n;
ind = 6;

for i = 1:n
    
    Lia{i} = ismember(charCells{ind},charCells{i}); % Which words (indices) in charCells{ind} matched with the other textfiles?
    matchCount(i) = sum(Lia{i}); % How many words matched in each of the 10 textfiles?
                                 % Check what textfiles words were matched in  
end

matchIndex = 2; % Index of one textfile with a match

acell = charCells{ind};
acell = acell{3}; % Look up in one of the files in Lia to see which slots = 1
                  % (which words were matched). Pick one. acell is now that word.
disp(acell);
                  
size = length(charCells{matchIndex});
acell2 = charCells{matchIndex};

for j = 1:size
    
    if(strcmp(acell,acell2{j}))
        disp('matches with: ');
        disp(acell2(j));
    end
    
end



