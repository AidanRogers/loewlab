 
    %% Patient Selection (CHANGE THIS TO NEW USERS / DIRECTORY REF SYSTEM)
    [location, ptID] = pathfinder;
    
    %% Image Input
    
    % Read 15 images to cell matrix I_mat
    a=0;
    for i=1:15          
        I_mat{i} = imread([location sprintf('%04d.tif',a)]);    % Read each image into I_mat
        a=a+120;            % Go to next image (for cropped)
    end
    
    I1 = I_mat{1};              % Display first image
    I = getMatrixOutliers(I1);  % Remove outliers
    I_adj1 = I1(find(I1>0));    % Remove zero pixels
     
%% create grid over image
prompt = ('Enter size of one box on grid in pixels'); % make dialog box
dlgtitle = ('input');
num_lines = 1;
defaultans = {'20'}
ans = inputdlg(prompt,dlgtitle,num_lines,defaultans)
squareside = str2num(cell2mat(ans)); %converts ans to a number
for k = 1:15
I_mat{k}(squareside:squareside:end,:,:) = 0;% converts every nth row to black
I_mat{k}(:,squareside:squareside:end,:) = 0;% converts every nth column to black

[r,c] = size(I_mat{k})
numrows = floor(r/squareside); %calculates the number of full rows
numcols = floor(c/squareside);
figure, imshow(I_mat{k},[min(I_adj1) max(I_adj1)])

for j = 1:1:numcols
    row = squareside*(j-1)+1;
    for i = 1:1:numrows
        col = squareside*(i-1)+1 ;
square = [row, col, squareside-2, squareside-2]; %  creates the square to be averaged
averages{i,j,k} = mean2(imcrop(I_mat{k},square));
    end
end

end

