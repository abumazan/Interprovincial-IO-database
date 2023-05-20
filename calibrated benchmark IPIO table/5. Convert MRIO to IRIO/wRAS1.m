function [b,num,getornot] = wRAS1(a,r_ctrl,c_ctrl,weight,num_intr,accu,deal)
% wRAS1, balances a inputed 2-d matrix with controls of row and column
% sums, with weight for the row sums (Chen Pan, 2022.3.3).
% [b,num,getornot] = wRAS1(a,r_ctrl,c_ctrl,weight,num_intr,accu,deal)
% output arguments:
% b - the adjuted matrix, whether it is balanced or not.
% num - number of actual interations.
% getornot - 1:got it!; 0:no solution found.
% input arguments:
% a - an m*n 2-d matrix which will be balanced;
% r_ctrl - vector with length being m, sum control of rows;
%          r_ctrl could be an empty vector while c_ctrl is not empty. When
%          r_ctrl is empty, the function will take row sum of 'a' as the 
%          row control;
% c_ctrl - vector with length being n, sum control of columns;
%          c_ctrl could be an empty vector while r_ctrl is not empty. When
%          c_ctrl is empty, the function will take column sum of 'a' as the 
%          column control;
% weight - weights for the row sums (consistent weight for each row)
% Caution: The sum of r_ctrl should be equal to the sum of c_ctrl!
%              
% num_intr - number of interations;
% accu - accuracy of the balance. range of error claimed as the percentage of the
%        control values.
% deal - deal with no-solution situations:
%        zero row with non-zero r_ctrl;
%        zero column with non-zero c_ctrl;
%        '-deal' - let the initial zero row/col be non-zero;
%        empty - do not;


getornot = 1;
if accu==0
    accu = 10^(-15);
end

if isempty(r_ctrl)
    r_ctrl = sum(a,2);
elseif isempty(c_ctrl)
    c_ctrl = sum(a,1);
end

% check shape
if length(r_ctrl)~=size(r_ctrl,1)
    r_ctrl = r_ctrl';
end
if length(c_ctrl)~=size(c_ctrl,2)
    c_ctrl = c_ctrl';
end

% check input arguments
if length(r_ctrl)~=size(a,1)% check dimensions
    error('Length of r_ctrl(2nd arg) and row number of a(1st arg) mismatch!');
end
if length(c_ctrl)~=size(a,2)% check dimensions
    error('Length of c_ctrl(3nd arg) and column number of a(1st arg) mismatch!');
end


% deal with no-solution situations
c_sum = sum(a,1);
r_sum = sum(a,2);
check_c = (c_sum==0)-(c_ctrl==0);
check_r = (r_sum==0)-(r_ctrl==0);
if sum(check_c,2)>0
    if nargin==7 && strcmp('-deal',deal)
        a(:,c_sum==0) = 10^(-10);
    else
        error('Zero column with non-zero column control! Check the initial matrix or use ''-deal''(7th argin).')
    end
end
if sum(check_r,1)>0
    if nargin==7 && strcmp('-deal',deal)
        a(r_sum==0,:) = 10^(-10);
    else
        error('Zero row with non-zero row control! Check the initial matrix or use ''-deal''(7th argin).')
    end
end

message = '';
for i = 1:num_intr
    

    a(isnan(a)) = 0;
    r_sum = a*weight;
    if sum(r_sum > (r_ctrl+accu))>0||sum(r_sum < (r_ctrl-accu))>0
          prop = r_ctrl./r_sum;
          prop(isnan(prop)) = 0;
          a = a.* repmat(prop,1,3);
          a(isnan(a)) = 0;
        
    else
        c_sum = sum(a,1);
        if sum((c_ctrl-accu)<= c_sum)==length(c_ctrl) &&...
                sum(c_sum<= (c_ctrl+accu))==length(c_ctrl)
            message = 'Got it!';
%             disp(message)
            break;
        end
    end
    
    c_sum = sum(a,1);
    if sum(c_sum<(c_ctrl-accu))>0||sum(c_sum > (c_ctrl+accu))>0
        prop = a./repmat(c_sum,length(r_ctrl),1);
        prop(isnan(prop)) = 0;
        a = prop.*repmat(c_ctrl,length(r_ctrl),1);
        a(isnan(a)) = 0;
    else
        r_sum = a*weight;
        if sum((r_ctrl-accu)<=r_sum)==length(r_ctrl) &&...
                sum(r_sum<= (r_ctrl+accu))==length(r_ctrl)
                message = 'Got it!';
%                             disp(message)
                break;
            end
    end
    
end

b = a;
num = i;

if ~strcmp('Got it!',message)
%    disp('No solution is found. Try more interations, or improve the function.')
   getornot = 0;
end
