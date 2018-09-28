%% Introduction to Computer Vision
% Homework 2 Question 4

close all
clear all
imtool close all

% read video
movieObj_in = VideoReader('fiveCCC.wmv');
nFrames = movieObj_in.NumberOfFrames;
width = movieObj_in.Width;
height = movieObj_in.Height;
S = [1 1 1; 1 1 1; 1 1 1];

movieObj_out = VideoWriter('HW2Q4_result.avi');
open(movieObj_out);

for frame = 1:nFrames
    RGB = read(movieObj_in, frame);
    text_str = ['Frame ' num2str(frame)];
    RGB = insertText(RGB,[10,10],text_str);
    
    imshow(RGB, [])
    
    W = im2bw(RGB,graythresh(RGB)); % take white circle
    W = imopen(W,S);                % get rid of small noise
    [LW,numWhite] = bwlabel(W);     % label white circle
    statsWhite = regionprops(LW);   % get region properties
    
    B = imcomplement(W);            % take black circle
    [LB,numBlack] = bwlabel(B);     % label black circle
    statsBlack = regionprops(LB);   % get region properties
    
    % threshold distance to find CCCs
    threshDis = 0.9;
    
    numCCC = 0;
    for i = 1:numWhite
        for j = 1:numBlack
            if norm(statsWhite(i).Centroid-statsBlack(j).Centroid) < threshDis
                if statsWhite(i).Area < statsBlack(j).Area
                    whitePerim = statsWhite(i).BoundingBox(3)+statsWhite(i).BoundingBox(4);
                    blackPerim = statsBlack(j).BoundingBox(3)+statsBlack(j).BoundingBox(4);
                    
                    if blackPerim > whitePerim
                        % count the number of CCCs
                        numCCC = numCCC+1;
                        
                        % get CCC locations
                        CCC(numCCC,1) = round(statsBlack(j).Centroid(1));   % row
                        CCC(numCCC,2) = round(statsBlack(j).Centroid(2));   % column
                        
                        % remember boundingboxes of CCCs
                        BoundingBoxes(numCCC,:) = statsBlack(j).BoundingBox;
                    end
                end
            end
        end
    end
    
    % a, b are possible UL, UR & c, d are possible LL, LR
    a = 0; b = 0; c = 0; d = 0;
    
    % threshold distance to find UM
    threshDis = 3;
    um_found = false;
    
    % find UM and possible UL, UR
    for um = 1:size(CCC,1);
        for a = 1:size(CCC,1)-1
            if a ~= um
                for b = 1:size(CCC,1)
                    if (b ~= um) & (b ~= a)
                        mid(1,1) = round((CCC(b,1)+CCC(a,1))/2);
                        mid(1,2) = round((CCC(b,2)+CCC(a,2))/2);
                        if norm(CCC(um,:) - mid) < threshDis
                            % found UM
                            um_found = true;
                            RGB = insertText(RGB,CCC(um,:),'UM');
                            break
                        end
                    end
                end
            end
            if um_found
                break
            end
        end
        if um_found
            break
        end
    end
    
    % the others are possible LL, LR
    for c = 1:size(CCC,1);
        if (c ~= a) & (c ~= b) & (c ~= um)
            break
        end
    end
    
    for d = 1:size(CCC,1);
        if (d ~= a) & (d ~= b) & (d ~= c) & (d ~= um)
            break
        end
    end
    
    % mid point between LL and LR
    mid(1,1) = round((CCC(c,1)+CCC(d,1))/2);
    mid(1,2) = round((CCC(c,2)+CCC(d,2))/2);
    
    % angle of 5 CCCs figure
    angle = atan2(mid(1,2)-CCC(um,2),mid(1,1)-CCC(um,1));
    
    if -pi*3/4 >= angle && angle > pi*3/4
        if CCC(a,2) > CCC(b,2)  % a is UR, b is UL
            RGB = insertText(RGB,CCC(a,:),'UR');
            RGB = insertText(RGB,CCC(b,:),'UL');
        else                    % a is UL, b is UR
            RGB = insertText(RGB,CCC(a,:),'UL');
            RGB = insertText(RGB,CCC(b,:),'UR');
        end
        if CCC(c,2) > CCC(d,2)  % c is LR, d is LL
            RGB = insertText(RGB,CCC(c,:),'LR');
            RGB = insertText(RGB,CCC(d,:),'LL');
        else                    % c is LL, d is LR
            RGB = insertText(RGB,CCC(c,:),'LL');
            RGB = insertText(RGB,CCC(d,:),'LR');
        end
    elseif -pi*3/4 < angle && angle <= -pi/4
        if CCC(a,1) > CCC(b,1)  % a is UL, b is UR
            RGB = insertText(RGB,CCC(a,:),'UL');
            RGB = insertText(RGB,CCC(b,:),'UR');
        else                    % a is UR, b is UL
            RGB = insertText(RGB,CCC(a,:),'UR');
            RGB = insertText(RGB,CCC(b,:),'UL');
        end
        if CCC(c,1) > CCC(d,1)  % c is LL, d is LR
            RGB = insertText(RGB,CCC(c,:),'LL');
            RGB = insertText(RGB,CCC(d,:),'LR');
        else                    % c is LR, d is LL
            RGB = insertText(RGB,CCC(c,:),'LR');
            RGB = insertText(RGB,CCC(d,:),'LL');
        end
    elseif -pi/4 < angle && angle <= pi/4
        if CCC(a,2) > CCC(b,2)  % a is UL, b is UR
            RGB = insertText(RGB,CCC(a,:),'UL');
            RGB = insertText(RGB,CCC(b,:),'UR');
        else                    % a is UR, b is UL
            RGB = insertText(RGB,CCC(a,:),'UR');
            RGB = insertText(RGB,CCC(b,:),'UL');
        end
        if CCC(c,2) > CCC(d,2)  % c is LL, d is LR
            RGB = insertText(RGB,CCC(c,:),'LL');
            RGB = insertText(RGB,CCC(d,:),'LR');
        else                    % c is LR, d is LL
            RGB = insertText(RGB,CCC(c,:),'LR');
            RGB = insertText(RGB,CCC(d,:),'LL');
        end
    elseif pi/4 < angle && angle <= pi*3/4
        if CCC(a,1) > CCC(b,1)  % a is UR, b is UL
            RGB = insertText(RGB,CCC(a,:),'UR');
            RGB = insertText(RGB,CCC(b,:),'UL');
        else                    % a is UL, b is UR
            RGB = insertText(RGB,CCC(a,:),'UL');
            RGB = insertText(RGB,CCC(b,:),'UR');
        end
        if CCC(c,1) > CCC(d,1)  % c is LR, d is LL
            RGB = insertText(RGB,CCC(c,:),'LR');
            RGB = insertText(RGB,CCC(d,:),'LL');
        else                    % c is LL, d is LR
            RGB = insertText(RGB,CCC(c,:),'LL');
            RGB = insertText(RGB,CCC(d,:),'LR');
        end
    end
    
    % insert texts, UL, UR, LL, LR
    imshow(RGB, [])
    
    % draw bounding boxes of CCCs
    for i = 1:numCCC
        rectangle('Position', BoundingBoxes(i,:), 'EdgeColor', 'r');
    end
    
    newframeOut = getframe;
    writeVideo(movieObj_out, newframeOut);
end

close(movieObj_out);