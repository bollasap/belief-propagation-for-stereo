% Stereo Matching using Loopy Belief Propagation (Min-Sum)
%

% Parameters
dispLevels = 16;
iterations = 80;
lambda = 5;
trunc = 2;

% Data term function
computeDataTerm = @(left,right) abs(left-right);

% Smoothness term function
computeSmoothnessTerm = @(d1,d2) lambda*min(abs(d1-d2),trunc);

% Read the stereo image and convert it to grayscale
left = rgb2gray(imread('Left.png'));
right = rgb2gray(imread('Right.png'));

% Apply a Gaussian filter
left = imgaussfilt(left,0.6,'FilterSize',5);
right = imgaussfilt(right,0.6,'FilterSize',5);

% Convert images to double
left = double(left);
right = double(right);

% Get the image size
[rows,cols] = size(left);

% Compute data term
dataTerm = zeros(rows,cols,dispLevels);
for d = 0:dispLevels-1
    right_d = [zeros(rows,d),right(:,1:end-d)];
    dataTerm(:,:,d+1) = computeDataTerm(left,right_d);
end

% Compute smoothness term
d = 0:dispLevels-1; % Set the disparity values
smoothnessTerm = computeSmoothnessTerm(d,d.');

% Initialize messages
msgFromLeft = initializeMessages(rows,cols,dispLevels);
msgFromRight = initializeMessages(rows,cols,dispLevels);
msgFromUp = initializeMessages(rows,cols,dispLevels);
msgFromDown = initializeMessages(rows,cols,dispLevels);
msgFromLeft2 = initializeMessages(rows,cols,dispLevels);
msgFromRight2 = initializeMessages(rows,cols,dispLevels);
msgFromUp2 = initializeMessages(rows,cols,dispLevels);
msgFromDown2 = initializeMessages(rows,cols,dispLevels);

figure
for i = 1:iterations
    for y = 2:rows-1
        for x = 2:cols-1
            % Create message to right
            msgFromLeft2(y,x+1,:) = computeMessage(dataTerm(y,x,:),msgFromLeft(y,x,:),msgFromUp(y,x,:),msgFromDown(y,x,:),smoothnessTerm);

            % Create message to left
            msgFromRight2(y,x-1,:) = computeMessage(dataTerm(y,x,:),msgFromRight(y,x,:),msgFromUp(y,x,:),msgFromDown(y,x,:),smoothnessTerm);
            
            % Create message to down
            msgFromUp2(y+1,x,:) = computeMessage(dataTerm(y,x,:),msgFromUp(y,x,:),msgFromLeft(y,x,:),msgFromRight(y,x,:),smoothnessTerm);

            % Create message to up
            msgFromDown2(y-1,x,:) = computeMessage(dataTerm(y,x,:),msgFromDown(y,x,:),msgFromLeft(y,x,:),msgFromRight(y,x,:),smoothnessTerm);
        end
    end

    % Send messages (swap buffers)
    msgFromLeft = msgFromLeft2;
    msgFromRight = msgFromRight2;
    msgFromUp = msgFromUp2;
    msgFromDown = msgFromDown2;

    % Compute beliefs
    beliefs = computeBeliefs(dataTerm,msgFromLeft,msgFromRight,msgFromUp,msgFromDown);

    % Update disparity map
    [~,ind] = min(beliefs,[],3);
    dispMap = ind-1;

    % Update disparity image
    scaleFactor = 256/dispLevels;
    dispImage = uint8(dispMap*scaleFactor);

    % Show disparity image
    imshow(dispImage)

    % Show current iteration
    fprintf('iteration %d/%d\n',i,iterations)
end

% Save disparity image
imwrite(dispImage,'disparity_MinSum.png')

function messages = initializeMessages(rows,cols,dispLevels)
    messages = zeros(rows,cols,dispLevels);
end

function message = computeMessage(dataTerm, incomingMsg1, incomingMsg2, incomingMsg3, smoothnessTerm)
    costs = squeeze(dataTerm + incomingMsg1 + incomingMsg2 + incomingMsg3);
    message = min(costs + smoothnessTerm);
    message = message - min(message); % Normalize message
end

function beliefs = computeBeliefs(dataTerm, incomingMsg1, incomingMsg2, incomingMsg3, incomingMsg4)
    beliefs = dataTerm + incomingMsg1 + incomingMsg2 + incomingMsg3 + incomingMsg4;
end
