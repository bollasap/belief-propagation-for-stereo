% Stereo Matching using Loopy Belief Propagation (Sum-Product)
%

% Parameters
dispLevels = 16;
iterations = 80;
lambda = 5;
trunc = 2;

% Data term function
computeDataTerm = @(left,right) exp(-abs(left-right));

% Smoothness term function
computeSmoothnessTerm = @(d1,d2) exp(-lambda*min(abs(d1-d2),trunc));

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
smoothnessTerm = permute(smoothnessTerm,[3 4 1 2]);

% Initialize messages
msgFromLeft = initializeMessages(rows,cols,dispLevels);
msgFromRight = initializeMessages(rows,cols,dispLevels);
msgFromUp = initializeMessages(rows,cols,dispLevels);
msgFromDown = initializeMessages(rows,cols,dispLevels);

figure
for i = 1:iterations
    % Create messages to right
    msgToRight = computeMessages(dataTerm,msgFromLeft,msgFromUp,msgFromDown,smoothnessTerm);

    % Create messages to left
    msgToLeft = computeMessages(dataTerm,msgFromRight,msgFromUp,msgFromDown,smoothnessTerm);

    % Create messages to down
    msgToDown = computeMessages(dataTerm,msgFromUp,msgFromLeft,msgFromRight,smoothnessTerm);

    % Create messages to up
    msgToUp = computeMessages(dataTerm,msgFromDown,msgFromLeft,msgFromRight,smoothnessTerm);

    % Send messages (shift and swap buffers)
    msgFromLeft(:,2:end,:) = msgToRight(:,1:end-1,:);
    msgFromRight(:,1:end-1,:) = msgToLeft(:,2:end,:);
    msgFromUp(2:end,:,:) = msgToDown(1:end-1,:,:);
    msgFromDown(1:end-1,:,:) = msgToUp(2:end,:,:);

    % Compute beliefs
    beliefs = computeBeliefs(dataTerm,msgFromLeft,msgFromRight,msgFromUp,msgFromDown);

    % Update disparity map
    [~,ind] = max(beliefs,[],3);
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
imwrite(dispImage,'disparity_SumProduct.png')

function messages = initializeMessages(rows,cols,dispLevels)
    messages = ones(rows,cols,dispLevels);
end

function messages = computeMessages(dataTerm, incomingMsg1, incomingMsg2, incomingMsg3, smoothnessTerm)
    costs = dataTerm .* incomingMsg1 .* incomingMsg2 .* incomingMsg3;
    %messages = sumProductConvolution(costs,smoothnessTerm);
    messages = sumProductConvolution_lowMemory(costs,smoothnessTerm);
    messages = messages./sum(messages,3); % Normalize message
end

function messages = sumProductConvolution(costs, smoothnessTerm)
    messages = permute(sum(costs .* smoothnessTerm,3),[1 2 4 3]);
end

function messages = sumProductConvolution_lowMemory(costs, smoothnessTerm)
    messages = zeros(size(costs));
    levels = size(messages,3);
    for i = 1:levels
        messages(:,:,i) = sum(costs .* smoothnessTerm(1,1,:,i),3);
    end
end

function beliefs = computeBeliefs(dataTerm, incomingMsg1, incomingMsg2, incomingMsg3, incomingMsg4)
    beliefs = dataTerm .* incomingMsg1 .* incomingMsg2 .* incomingMsg3 .* incomingMsg4;
end
