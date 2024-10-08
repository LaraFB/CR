function Start_redes() 

% ler a matrix do excel
data = readmatrix('Start.csv', 'Delimiter',';','DecimalSeparator','.');

    fprintf('**********************************\n');
    fprintf('*************START****************\n');
    fprintf('**********************************\n');

%Separar os inputs e targets
inputs = (data(:, 3:end)');
targets = data(:, 2)';

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

for i=1:30
    fprintf('Simulação %d\n', i);
% Cria rede neuronal
net = feedforwardnet(10);
%Função de treino
net.trainFcn = 'trainlm'; %treino [%traingd ; traingdx ; traingdm; trainlm; trainbfg; trainscg]
%Função de Ativação
netlayers{1}.transferFcn = 'tansig'; %ativação [%purelin; logsin; tansig; softmax]
%Função de Saida
netlayers{2}.transferFcn = 'purelin'; %saida [%purelin; logsin; tansig; softmax]
%Dividir os dados
net.divideFcn = 'dividetrain';
net.divideParam.trainRatio = 0.7; %dados para treino
net.divideParam.valRatio = 0.15; %dados para validação
net.divideParam.testRatio = 0.15; %dados para teste

tic;
%Treino da rede
net = train(net, inputs, oneHotTargets);

%Simulação da rede
out = sim(net, inputs);

%plotconfusion(oneHotTargets, out);   %Matriz de confusao
    
%erro = perform(net, out,oneHotTargets);
%fprintf('Erro na classificação dos 150 exemplos %f\n', erro)
    
%Cálculo do Erro
erro = perform(net,out,oneHotTargets);
accuracy = (1-erro) * 100;
end
fprintf('Erro: %.2f\n',erro);
fprintf('Precisao %.2f\n', accuracy);
%Ver o tempo de execução
tempo_exe = toc;
fprintf('Tempo de execução: %.2f em segundos\n', tempo_exe);
end