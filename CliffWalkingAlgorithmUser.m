% File: CliffWalkingAlgorithmUser.m
% Authors: Matthew Stock & Richard Kneale
% Date created: 14th February 2017
% Description: Used to compare SARSA and Q-learning in a cliff-walking task

% The number of episodes over which the agent will learn
numberOfEpisodes = 500;

% Used to achieve a smoothing effect
numberOfRuns = 3;
episodesToAverageOver = 10;

% Set up the episodes matrix for the x-axis
episodes = (0 : numberOfEpisodes);

% The values of epsilon to be used in training the agents
epsilon = 0.02;

% The specification of the cliff
gridLength = 12;
gridHeight = 4;
startingX = 1;
startingY = 1;
goalXPosition = gridLength;
goalYPosition = 1;

alpha = 0.1;
gamma = 1;

% Variables to represent the temporal difference formula that is used
sarsa = 1;
qLearning = 2;

% Calculate the results
% Using SARSA
[sarsaRewardPerEpisode] = CliffWalkingAlgorithm(numberOfRuns, numberOfEpisodes,... 
    sarsa, episodesToAverageOver, alpha, gamma, epsilon, gridLength, gridHeight,... 
    startingX, startingY, goalXPosition, goalYPosition);

% Using Q-learning
[qLearningRewardPerEpisode] = CliffWalkingAlgorithm(numberOfRuns, numberOfEpisodes,... 
    qLearning, episodesToAverageOver, alpha, gamma, epsilon, gridLength, gridHeight,... 
    startingX, startingY, goalXPosition, goalYPosition);

% Output the figure
figure(1)
plot(episodes, sarsaRewardPerEpisode, episodes, qLearningRewardPerEpisode);
title(['Epsilon = ' num2str(epsilon)])
xlabel('Episodes');
ylabel('Reward per episode');
legend('SARSA', 'Q-learning', 'Location', 'southeast');