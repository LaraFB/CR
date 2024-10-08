function [testeGlobal, tempoExec,erroGlobal, Cate]= Teste_redes(nomeConfig, dados)


    dataConfig = load(nomeConfig,'net');

    %dataConfig = load('treinoRede_config2.mat','net');

    %dataConfig = load('treinoRede_config3.mat','net');
    
    % Extract the trained neural network from the loaded data
    net = dataConfig.net;
   
    dataTeste = readmatrix('Test.csv', 'Delimiter',';','DecimalSeparator','.');
    
    if ~isempty(dados)
         inputs = dados';
            
    else
         inputs = dataTeste(:, 3:end)';   
    end
    targets = dataTeste(:, 2)';
    
    % Iniciar one-hot encoded targets
    numClasses = 5;  
    oneHotTargets = zeros(numClasses, length(targets)); % verificar se as classes abaixo pertencem se sim fica 1 senao fica 0
    
    for i = 1:length(targets)
        switch targets(i)
            %tipos de doadores
            case 0
                oneHotTargets(:, i) = [1 0 0 0 0]';
            case 1
                oneHotTargets(:, i) = [0 1 0 0 0]';
            case 2
                oneHotTargets(:, i) = [0 0 1 0 0]';
            case 3
                oneHotTargets(:, i) = [0 0 0 1 0]';
            case 4
                oneHotTargets(:, i) = [0 0 0 0 1]';
        end
    end
    
    fprintf('**********************************\n');
    fprintf('A COMPARAR OS OUTPUTS E OS TARGETS\n');
    fprintf('**********************************\n');

    % Inicializar vetores para armazenar as precisões
    accuracy_total = [];
    tempos_execucao = [];

    for i = 1:30
        fprintf('Simulação %d\n', i);

        tic; % Iniciar contagem de tempo
        out = sim(net, inputs);

        %VISUALIZAR DESEMPENHO
        %plotconfusion(oneHotTargets, out);

        %erro
        erro = perform(net, out,oneHotTargets);

        r=0;
        for i=1:size(out,2)                 % Para cada classificacao  
          [a b] = max(out(:,i));            %b guarda a linha onde encontrou valor mais alto da saida obtida
          [c d] = max(oneHotTargets(:,i));        %d guarda a linha onde encontrou valor mais alto da saida desejada
            if b == d                         % se estao na mesma linha, a classificacao foi correta (incrementa 1)
              r = r+1;
            end
        end

        % Transformar os outputs da rede em valores binários
        out = (out > 0.5);
        
        % Calcular a quantidade de classificações corretas para precisão total
        r_total = sum(out == oneHotTargets, 2);
        
        % Calcular a precisão total
        accuracyTotal = r_total / size(oneHotTargets, 2) * 100;
        accuracy_total = [accuracy_total, accuracyTotal]; % Armazenar precisão total

        % Calcular a quantidade de classificações corretas para precisão de teste
        r_teste = sum(out == oneHotTargets);
        
        % Tempo de execução
        tempo_execucao = toc;
        tempos_execucao = [tempos_execucao, tempo_execucao]; % Armazenar tempo de execução
    end


    testeGlobal = mean(accuracy_total,"all");
    tempoExec = mean(tempo_execucao);
    erroGlobal = erro;

    fprintf('Métrica de Acerto = %.2f\n', testeGlobal);
    fprintf('Tempo Médio de Execução = %.2f segundos\n',tempoExec);
    fprintf('Erro: %.2f\n',erroGlobal);

    % Para passar um caso extra (App)
if ~isempty(dados)
    % Calcula a categoria prevista para o caso fornecido
    [v, Cate] = max(out);
    Cate = Cate - 1;
    fprintf('Categoria suposta para o exemplo: %d, valor da rede: %.2f\n', Cate, v);
else
    Cate = zeros(1, size(out, 2)); % Inicializa um vetor de zeros com o mesmo tamanho que o número de exemplos na saída
    for i = 1:size(out, 2) % Para cada exemplo na saída
        [v, Cate] = max(out(:, i)); % Valor previsto
        [~, f] = max(oneHotTargets(:, i)); % Valor desejado
        Cate = Cate - 1; % Ajuste ao índice
        f = f - 1;
        fprintf('Categoria suposta para o exemplo %d: %d, valor da rede: %.2f, valor desejado: %d\n', i, Cate, v, f);
        Cate(i) = Cate;
    end
end
end
