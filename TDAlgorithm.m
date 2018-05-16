% File: TDAlgorithm.m
% Authors: Matthew Stock & Richard Kneale
% Date created: 14th February 2017
% Description: Contains the temporal difference equation

function[newQ] = TDAlgorithm(previousQ, nextQ, reward, alpha, gamma)

    newQ = previousQ + alpha * (reward + (gamma * nextQ) - previousQ);

return