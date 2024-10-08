%Melhores Configurações

% Configuração_1	[30]	[2]	[5 , 5]	[tansig, purelin]	[trainlm]	[dividerand = {0.7, 0.15, 0.15}]	[0,88]	[0,01]	[0,02]	[94,8]	[97,13]
											
% Configuração_2	[30]	[2]	[10 , 10] 	[tansig, purelin]	[trainlm]	[dividerand = {0.7, 0.15, 0.15}]	[0,9]	[0,02]	[0,04]	[95,68]	[97,04]

% Configuração_1	[30]	[1]	[10]	[logsig, purelin]	[trainlm]	[dividerand = {0.7, 0.15, 0.15}]	[0,81]	[0,03]	[0,04]	[94,91]	[96,84]
											
											
function [testeGlobal, tempoExec, erroGlobal] = treino_redes(numNeuro, fcnTrain, fcnAtiv, fncSaid, ratioTrain, ratioValidatio, ratioTest)
  close all;
   clc;
data = readmatrix('retrieved_filled.csv', 'Delimiter', ',', 'DecimalSeparator', '.');

    fprintf('**********************************\n');
    fprintf('************TREINO****************\n');
    fprintf('**********************************\n');
%Separar os inputs e targets
inputs = data(:, 3:end)';
targets = data(:, 2)';

% Iniciar one-hot encoded targets
numClasses = 5;  
oneHotTargets = zeros(numClasses, length(targets)); % verificar se as classes abaixo pertencem se sim fica 1 senao fica 0

for i = 1:length(targets)
    switch targets(i)
        
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

accuracy_total=[]; % matriz para guardar a accuracy_total
accuracy_teste=[]; % matriz para guardar a accuracy_teste

for rep = 1 :30
    %fprintf('Simulação %d\n', rep);
    tic;
    % Cria rede neuronal
    net = feedforwardnet(numNeuro);
    
    %Função de treino
    net.trainFcn = fcnTrain; %treino [%traingd ; traingdx ; traingdm; trainlm; trainbfg; trainscg; trainbfg]

    net.layers{1:end-1}.transferFcn = fcnAtiv; %ativação [%purelin; logsin; tansig; softmax]
    net.layers{end}.transferFcn = fncSaid;    %saida [%purelin; logsin; tansig; softmax]
    % MUDAR AS DISTRIBUIÇÕES
    net.divideFcn = 'dividerand';
    net.divideParam.trainRatio = ratioTrain; %dados para treino
    net.divideParam.valRatio = ratioValidatio; %dados para validação
    net.divideParam.testRatio = ratioTest; %dados para teste
    net.trainParam.showWindown = 0;
    
    %treinar a rede
    [net,tr] = train(net, inputs, oneHotTargets);
    
    %simular a rede
    out = sim(net, inputs);
    
    %plotconfusion(oneHotTargets, out);   %Matriz de confusao
    %plotperf(tr);  %Grafico com desempenho da rede % n preciso de mexer no epoches pq o verde ta gucci
    
    erro = perform(net, out,oneHotTargets);
    %fprintf('Erro na classificação dos 150 exemplos %f\n', erro)
    
    r=0;
    for i=1:size(out,2)                 % Para cada classificacao  
      [a b] = max(out(:,i));            %b guarda a linha onde encontrou valor mais alto da saida obtida
      [c d] = max(oneHotTargets(:,i));        %d guarda a linha onde encontrou valor mais alto da saida desejada
      if b == d                         % se estao na mesma linha, a classificacao foi correta (incrementa 1)
          r = r+1;
      end
    end
    
    accuracyTeste = r/size(out,2)*100;
    %fprintf('Precisao total (nos 150 exemplos) %f\n', accuracyTeste)
    accuracy_total=[accuracy_total accuracyTeste];
    

    %Separar para a parte do Teste
    TInput = inputs(:,tr.testInd);
    TTargets = oneHotTargets(:,tr.testInd);
    out = sim(net, TInput);
    
    erroT = perform(net, out,TTargets);
    %fprintf('Erro na classificação do conjunto de teste %f\n', erro)
    
    r=0;
    for i=1:size(tr.testInd,2)          % Para cada classificacao  
      [a b] = max(out(:,i));            %b guarda a linha onde encontrou valor mais alto da saida obtida
      [c d] = max(TTargets(:,i));       %d guarda a linha onde encontrou valor mais alto da saida desejada
      if b == d                         % se estao na mesma linha, a classificacao foi correta (incrementa 1)
          r = r+1;
      end
    end
    
    %transformar em 0 ou 1
    out = (out>0.5);
    r = sum(out == TTargets,2);
    accuracyTeste = r/size(tr.testInd,2)*100;
    accuracy_teste = [accuracy_teste accuracyTeste];

    % plotconfusion(targets, out);
    %plotperf(tr);

    tempo_execucao = toc;
    tempo_execucao = [tempo_execucao tempo_execucao];
end

testeGlobal = mean(accuracy_total,"all");
tempoExec = mean(tempo_execucao);
erroGlobal = erro;

fprintf('Média Global = %.2f\n' , mean(accuracy_total,"all"));
fprintf('Media Teste = %.2f\n' ,testeGlobal);
fprintf('Tempo Médio de Execução = %.2f segundos\n', tempoExec);
fprintf('Erro: %.2f\n',erroGlobal);
fprintf('Erro do Conjunto do Teste: %.2f\n',erroT);

%Ciclo para verificar que se guarda a melhor a rede
accuracyI = accuracy_total(1);
accuracyThree = [accuracyI -Inf -Inf];
for i=2:length(accuracy_total)
    if (accuracyI >= accuracy_total(i))
        for j=1:3
            if (accuracyI >= accuracyThree(j))
                accuracyThree(j) = accuracyI;
            end
        end
    end
end


%save('treinoRede_config1.mat','net');
% save('treinoRede_config2.mat','net');
% save('treinoRede_config3.mat','net');

end