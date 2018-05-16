% File: CliffWalkingAlgorithm.m
% Authors: Matthew Stock & Richard Kneale
% Date created: 14th February 2017
% Description: Used to simulate a cliff-walking task

function[rewardPerEpisodeMatrix] = CliffWalkingAlgorithm(numberOfRuns, numberOfEpisodes,...
    temporalDifferenceFormula, episodesToAverageOver, alpha, gamma, epsilon, gridLength,...
    gridHeight, startingX, startingY, goalXPosition, goalYPosition)
    
    % Variables to represent the directions in which the agent can move
    northAction = 1;
    eastAction = 2;
    southAction = 3;
    westAction = 4;
    
    % Variables to represent the temporal difference formula that the user
    % has selected to use. They have been defined for readability.
    sarsa = 1;
    qLearning = 2;
    
    % Variables to represent the reward values
    moveReward = -1;
    cliffReward = -100;
    terminalReward = 0;
    
    % Initialise the matrix to represent the reward per episode. 
    % The first column must remain zero to represent the origin of the graph.
    temporaryRewardPerEpisodeMatrix = zeros(numberOfRuns, (numberOfEpisodes + 1));
    
    % Used to calulate whether an exploitative or exploratory move should be taken
    exploitativeOrExploratoryDivisor = (1 / epsilon);
    
    % Each run
    for runNumber = (1 : numberOfRuns)
                       
        % Reset the action value matrix
        actionValueMatrix = zeros(gridHeight, gridLength, 4);
    
        % Each episode
        for episodeNumber = (1 : numberOfEpisodes)
            % Move the agent to the starting position
            state2X = startingX;
            state2Y = startingY;
            
            % Reset the cumulative reward
            cumulativeReward = 0;
            
            % Reset the actionNumber
            actionNumber = 1;
        
            disp(['runNumber: ' num2str(runNumber)]);
            disp(['episodeNumber: ' num2str(episodeNumber)]);
            
            % Traverse the grid collecting rewards
            while true
                disp(['Action in this episode: ' num2str(actionNumber)]);
                
                % Select the next direction to move in
                % If it an exploratory action
                if(mod(actionNumber, exploitativeOrExploratoryDivisor) == 0) 
                   
                    disp('Agent will take an exploratory move');
                    
                    % Select a valid random direction to move in
                    while true
                        % Select a random direction to move in
                        action2_3 = randi([northAction westAction]);

                        % Leave the while loop if the direction is valid
                        if (((action2_3 == northAction) && (state2Y < gridHeight)) || ...
                            ((action2_3 == eastAction) && (state2X < gridLength)) || ...
                            ((action2_3 == southAction) && (state2Y > 1)) || ...
                            ((action2_3 == westAction) && (state2X > 1)))
                        
                            % Get the next action value
                            % Extract the action values for the agent's current space
                            currentSpaceActionValueMatrix = actionValueMatrix(state2Y, state2X, :);
                            % SARSA
                            if(temporalDifferenceFormula == sarsa)
                                actionValue2_3 = currentSpaceActionValueMatrix(action2_3);
                            % Q-Learning
                            else
                                actionValue2_3 = max(currentSpaceActionValueMatrix);
                            end
                            
                            % Leave the loop
                            break
                        end          
                    end
                   
                % It is not the first episode or an exploratory episode   
                else
                    % Extract the action values for the agent's current space                    
                    currentSpaceActionValueMatrix = actionValueMatrix(state2Y, state2X, :);
                    
                    % Ensure that the direction that provides the highest
                    % action value is selected, and that the direction is
                    % valid.
                    while true
                        % The next move will be equal to the index of the direction that has the highest
                        % action value
                        [actionValue2_3, action2_3] = max(currentSpaceActionValueMatrix);
                        
                        % Leave the while loop if the direction is valid
                        if (((action2_3 == northAction) && (state2Y < gridHeight)) || ...
                            ((action2_3 == eastAction) && (state2X < gridLength)) || ...
                            ((action2_3 == southAction) && (state2Y > 1)) || ...
                            ((action2_3 == westAction) && (state2X > 1)))
                            
                            % If Q-learning
                            if(temporalDifferenceFormula == qLearning)
                                actionValue2_3 = max(currentSpaceActionValueMatrix);
                            end

                            % Leave the loop
                            break
                                              
                        % If the direction is not valid
                        else
                            % Make the move invalid for selection
                            currentSpaceActionValueMatrix(action2_3) = min(currentSpaceActionValueMatrix) - 1;
                        end
                    end
                end
                
                disp(['Agent will move in direction: ' num2str(action2_3)]);
                             
                % Agent moves north
                if(action2_3 == northAction)
                    state3X = state2X;
                    state3Y = (state2Y + 1);
                % Agent moves east
                elseif(action2_3 == eastAction)
                    state3Y = state2Y;
                    state3X = (state2X + 1);
                % Agent moves south
                elseif(action2_3 == southAction)
                    state3X = state2X;
                    state3Y = (state2Y - 1);
                % Agent moves west
                else
                    state3Y = state2Y;
                    state3X = (state2X - 1);
                end
                
                % Determine the reward
                % The agent is now in the goal (terminal) state
                if((state2X == goalXPosition) && (state2Y == goalYPosition))
                    reward = terminalReward;
                % The agent is now on the cliff
                elseif((state2Y == 1) && ((state2X > 1) && (state2X < gridLength)))
                    reward = cliffReward;
                else
                    reward = moveReward;
                end
                
                % Update the cumulativeReward
                cumulativeReward = (cumulativeReward + reward);
                
                % Update previous action value based on next action
                % Must be delayed by one action to calculate first action
                % value
                if (actionNumber > 1)
                    actionValue1_2 = actionValueMatrix(state1Y, state1X, action1_2);
                    [newQ] = TDAlgorithm(actionValue1_2, actionValue2_3, reward, alpha, gamma);
                    actionValueMatrix(state1Y, state1X, action1_2) = newQ;
                end
                
                % state2 now becomes state1
                state1X = state2X;
                state1Y = state2Y;
                
                % state3 now becomes state2
                state2X = state3X;
                state2Y = state3Y;
                
                % The next action now becomes the previous action.
                action1_2 = action2_3;
                                      
                % Resolve any extra results of the agent's new position
                % The agent is now in the goal state
                if((state2X == goalXPosition) && (state2Y == goalYPosition))
                    % Conclude the episode
                    disp('Episode finished');
                    break               
                % The agent is now on the cliff
                elseif((state2Y == 1) && ((state2X > 1) && (state2X < gridLength)))
                    % Move the agent back to the starting position
                    state2X = startingX;
                    state2Y = startingY;
                end
                
                actionNumber = actionNumber + 1;
            end  
            
            temporaryRewardPerEpisodeMatrix(runNumber, (episodeNumber + 1)) = cumulativeReward;
        end
    end
    
    % Create the smoothed reward matrix
    if(numberOfRuns > 1)
        temporaryRewardPerEpisodeMatrix = (sum(temporaryRewardPerEpisodeMatrix) / numberOfRuns);
    end
    
    % Create the rewardPerEpisodeMatrix
    rewardPerEpisodeMatrix = zeros(1, (numberOfEpisodes + 1));
    
    % Each episode
    for episodeNumber = (1 : numberOfEpisodes)

        % Write the cumulativeReward to the rewardPerEpisodeMatrix
        if(episodeNumber >= episodesToAverageOver)
            rewardPerEpisode = (sum(temporaryRewardPerEpisodeMatrix(1, ((episodeNumber - episodesToAverageOver + 2) : (episodeNumber + 1)))) / episodesToAverageOver);
            rewardPerEpisodeMatrix(1, (episodeNumber + 1)) = rewardPerEpisode;
        else 
            rewardsForAverage = temporaryRewardPerEpisodeMatrix(1, (2 : (episodeNumber + 1)));
            rewardPerEpisode = (sum(rewardsForAverage) / numel(rewardsForAverage));
            rewardPerEpisodeMatrix(1, (episodeNumber + 1)) = rewardPerEpisode;
        end
    end
return