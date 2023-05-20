function [ s ] = summ( matrix )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
s = squeeze(sum(sum(matrix,1),2));

end

