function [retrieved_indexes, similarities, new_case] = retrieve(case_library, new_case, threshold, pos_new_case)
    
    weighting_factors = [
        0.02
        0.02
        0.05
        0.05
        0.27
        0.23
        0.2
        0.04
        0.03
        0.03
        0.03
        0.03
    ];

    % Adicione isso após a definição dos pesos
    similarity_table = get_feature_similarity_table(weighting_factors);

    sex_sim = get_sex_similarities(); % ir buscar as similaridades do sex
    max_values = get_max_values(case_library); % ir buscar os valores maximo na case_library

    retrieved_indexes = [];
    similarities = [];
    best_similaritie = -Inf;

    list = {'Age','Sex','ALB','ALP','ALT','AST','BIL','CHE','CHOL','CREA','GGT','PROT'};
    
    for i=1:length(list)
        if ~isfield(new_case,list(i))
            weighting_factors(i) = 0; % percorrer a lista se tiver não tiver valores fica com 0
        end
    end

    for i=1:size(case_library,1)
        distances = zeros(1,length(weighting_factors));

        if isfield(new_case, 'Age')
            distances(1,1) = calculate_linear_distance(case_library{i,'Age'} / max_values('Age'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.Age / max_values('Age'));
        end

        if isfield(new_case, 'Sex')
            distances(1,2) = calculate_linear_distance(case_library{i,'Sex'} / max_values('Sex'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.Sex / max_values('Sex'));
        end

        if isfield(new_case, 'ALB')
            distances(1,3) = calculate_linear_distance(case_library{i,'ALB'} / max_values('ALB'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.ALB / max_values('ALB'));
        end

        if isfield(new_case, 'ALP')
            distances(1,4) = calculate_linear_distance(case_library{i,'ALP'} / max_values('ALP'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.ALP / max_values('ALP'));
        end

        if isfield(new_case, 'ALT')
            distances(1,5) = calculate_linear_distance(case_library{i,'ALT'} / max_values('ALT'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.ALT / max_values('ALT'));
        end

        if isfield(new_case, 'AST')
            distances(1,6) = calculate_linear_distance(case_library{i,'AST'} / max_values('AST'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.AST / max_values('AST'));
        end

        if isfield(new_case, 'BIL')
            distances(1,7) = calculate_linear_distance(case_library{i,'BIL'} / max_values('BIL'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.BIL / max_values('BIL'));
        end

        if isfield(new_case, 'CHE')
            distances(1,8) = calculate_linear_distance(case_library{i,'CHE'} / max_values('CHE'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.CHE / max_values('CHE'));
        end

        if isfield(new_case, 'CHOL')
            distances(1,9) = calculate_linear_distance(case_library{i,'CHOL'} / max_values('CHOL'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.CHOL / max_values('CHOL'));
        end

        if isfield(new_case, 'CREA')
            distances(1,10) = calculate_linear_distance(case_library{i,'CREA'} / max_values('CREA'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.CREA / max_values('CREA'));
        end

        if isfield(new_case, 'GGT')
            distances(1,11) = calculate_linear_distance(case_library{i,'GGT'} / max_values('GGT'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.GGT / max_values('GGT'));
        end

        if isfield(new_case, 'PROT')
            distances(1,12) = calculate_linear_distance(case_library{i,'PROT'} / max_values('PROT'), ... % calcular a distãncia linear de cada campo, igual a ficha do CBR
                new_case.PROT / max_values('PROT'));
        end

        final_similarity = 1 - sum(weighting_factors.*distances')/sum(weighting_factors); %verificar a similaridade entre o newcase e cada coluna da list

        if final_similarity >= threshold 
            retrieved_indexes = [retrieved_indexes i]; % se for >= ao threshold é adicionado ao veto do retrieved_indexes
            similarities = [similarities final_similarity]; % se for >= ao threshold é adicionado ao veto da similarities
        end

        % normalized_distances = distances./max(distances);
        % final_similarity = 1 - ((normalized_distances* weighting_factors') / sum(weighting_factors));
        % if final_similarity >= threshold
        %     fprintf('Case breaks threshold');
        %     retrieved_indexes = [retrieved_indexes i];
        %     similarities = [similarities final_similarity];
        % end

        %fprintf('Case %d de of %d tem semelhanca de %.2f%%...\n', i, size(case_library,1), final_similarity*100);

        % Ordenar os resultados por similaridade
        % [similarities, sortIndex] = sort(similarities, 'descend');  % Ordena em ordem decrescente
        % retrieved_indexes = retrieved_indexes(sortIndex);  % Reordena os índices de acordo com as similaridades

        if final_similarity > best_similaritie && pos_new_case ~= i
            best_similaritie = final_similarity;
            new_case.Category = case_library{i, 'Category'};
        end
    end
    % Index 2 devido a que o primeiro é ele proprio (Não se pode fazer assim)
    % new_case.Category = case_library{2,'Category'};
end

%Igual a aula

function [res] = calculate_local_distance(sim, val1, val2)

    i1 = find(sim.categories == val1);
    i2 = find(sim.categories == val2);
    res = 1 - sim.similarities(i1, i2);
end

function [res] = calculate_linear_distance(val1, val2)

    res = sum(abs(val1-val2))/length(val1);
end

function [res] = calculate_euclidean_distance(val1, val2)

    res = sqrt(sum((val1 - val2).^2))/length(val1);
end

% function [category_sim] = get_category_similarities()
% 
%     category_sim.categories = categorical({'0=Blood Donor', '0s=suspect Blood Donor', '1=Hepatitis', ...
%         '2=Fibrosis', '3=Cirrhosis'});
% 
%     category_sim.similarities = [
%          1.0 0.6 0.3 0.4 0.5
%          0.1 1.0 0.2 0.1 0.3
%          0.3 0.4 1.0 0.5 0.2
%          0.4 0.3 0.2 1.0 0.1
%          0.5 0.3 0.2 0.5 1.0
%     ];
% end

function [sex_sim] = get_sex_similarities()

    sex_sim.categories = categorical({'m', 'f'});

    sex_sim.similarities = [
          1.0 0.8
          0.8 1.0
    ];
end

%pegar os valores maximos de cada key
function [max_values] = get_max_values(case_library)
    key_set = {'Age','Sex','ALB','ALP','ALT','AST','BIL','CHE','CHOL','CREA','GGT','PROT'};
    value_set = {max(case_library{:,'Age'}), max(case_library{:,'Sex'}), ...
        max(case_library{:,'ALB'}), max(case_library{:,'ALP'}), max(case_library{:,'ALT'}), ...
        max(case_library{:,'AST'}), max(case_library{:,'BIL'}), max(case_library{:,'CHE'}), ...
        max(case_library{:,'CHOL'}), max(case_library{:,'CREA'}), max(case_library{:,'GGT'}), ...
        max(case_library{:,'PROT'})};
    max_values = containers.Map(key_set, value_set);
end

% Adicionar a função get_feature_similarity_table

function similarity_table = get_feature_similarity_table(weighting_factors)
    num_features = length(weighting_factors);
    similarity_table = zeros(num_features);

    % Calcular a similaridade entre cada par de características
    for i = 1:num_features
        for j = i:num_features
            % A similaridade entre cada par de características é o produto das ponderações correspondentes
            similarity = weighting_factors(i) * weighting_factors(j);
            similarity_table(i, j) = similarity;
            similarity_table(j, i) = similarity; % A matriz é simétrica, então preenchemos ambos os lados
        end
    end
end


