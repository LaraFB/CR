function [] = Tp()

close all;
clear;
clc

similarity_threshold = 0.9;
%formato de leitura das colunas do excel

formatSpec = '%f%s%f%s%f%f%f%f%f%f%f%f%f%f';

case_library = readtable('Train.csv', ...
            'Delimiter', '\t', ...
            "TextType", "string", ...
            'Format', formatSpec);


for i=1:height(case_library)
    % Escolher o valor da categoria
    category_text_tipo = case_library.Category(i);
   
    % Verificar 0=Blood Donor e meter 0
    if strcmp(category_text_tipo, '0=Blood Donor')
        case_library.Category(i) = 0;
    % Verificar 0s=suspect Blood Donor e meter 1
    elseif strcmp(category_text_tipo, '0s=suspect Blood Donor')
        case_library.Category(i) = 1;
   % Verificar 1=Hepatitis e meter 2
    elseif strcmp(category_text_tipo, '1=Hepatitis')
        case_library.Category(i) = 2;
   % Verificar 2=Fibrosis e meter 3
    elseif strcmp(category_text_tipo, '2=Fibrosis')
        case_library.Category(i) = 3;
   % Verificar 3=Cirrhosis e meter 4
    elseif strcmp(category_text_tipo, '3=Cirrhosis')
        case_library.Category(i) = 4;
    else
        % Colocar ' ' se n for nenhuma das opcoes
        case_library.Category(i) = ' ';
    end
    
    % Verificar m e meter 0
    if case_library.Sex(i) == 'm'
        case_library.Sex(i) = 0;
    % Verificar f e meter 1
    elseif case_library.Sex(i) == 'f'
        case_library.Sex(i) = 1;
    end
end
case_library.Sex = str2double(case_library.Sex);

%disp(case_library);

fprintf("\nA começar a fase de Retreive...\n");

% Percorrer o case_library
for i=1:height(case_library)
    if strcmp(case_library.Category(i), ' ') % verificar se a case_library esta vazia
        new_case.ID = case_library.ID(i);
        new_case.Category = ' ';
        new_case.Age = case_library.Age(i);
        new_case.Sex = case_library.Sex(i);
        new_case.ALB = case_library.ALB(i);
        new_case.ALP = case_library.ALP(i);
        new_case.ALT = case_library.ALT(i);
        new_case.AST = case_library.AST(i);
        new_case.BIL = case_library.BIL(i);
        new_case.CHE = case_library.CHE(i);
        new_case.CHOL = case_library.CHOL(i);
        new_case.CREA = case_library.CREA(i);
        new_case.GGT = case_library.GGT(i);
        new_case.PROT = case_library.PROT(i);

        [retrieved_indexes, similarities, new_case] = retrieve(case_library, new_case, similarity_threshold, i);
        retrieved_cases = case_library(retrieved_indexes, :);
        retrieved_cases.Similarity = similarities';
    
        case_library.Category(i) = new_case.Category;
    end
    
end

fprintf('\nFase de Retrieve concluida\n');

%writetable(case_library,'retrieved_filled.csv');

end