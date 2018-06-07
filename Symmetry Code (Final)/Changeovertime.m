close all
clear, clc
answer = questdlg('ID Patient Type:','Patient Type','Patient','Volunteer','Patient');
if (strcmp(answer, 'Patient'))
    ptID = patientselect;    % Dialog Box for patient selection
    prompt = {'Enter User name:','Enter length of square in pixels:','Enter total number of pictures:'};
    dlgtitle = 'Input';
    defaultans = {'Jacob','50','14'};
    numlines = 1;
    answers = inputdlg(prompt,dlgtitle,numlines,defaultans);
    name = answers{1};
    location = (['C:\Users\' name '\Documents\GitHub\loewlab\Symmetry Code (Final)\Images\Patient Images\' ptID '\Cropped\']);
    
end
if (strcmp(answer, 'Volunteer'))
    vtID = volunteerselect;
    prompt = {'Enter User name:','Enter length of square in pixels:','Enter total number of pictures:'};
    dlgtitle = 'Input';
    defaultans = {'Jacob','50','14'};
    numlines = 1;
    answers = inputdlg(prompt,dlgtitle,numlines,defaultans);
    name = answers{1};
    location = (['C:\Users\' name '\Documents\GitHub\loewlab\Symmetry Code (Final)\Images\Volunteers\' vtID '\']);
    
end
    
    %% Image Input
    numpics = str2double(answers{3}); % allocates number of pictures
    % Read images to cell matrix I_mat
    a=120; % set equal to the number of the first picture
    I_mat = cell(1,numpics);
    for i=1:numpics % set equal to total number of pictures being ran          
        I_mat{i} = imread([location sprintf('%04d.tif',a)]);    % Read each image into I_mat
        a=a+120;            % Go to next image (for cropped)
    end
    
    I1 = I_mat{1};              % Display first image
    I = getMatrixOutliers(I1);  % Remove outliers
    I_adj1 = I1(find(I1>0));    % Remove zero pixels
    
     
%% create grid over image and find averages
prompt = ('Enter size of one box on grid in pixels'); % make dialog box
dlgtitle = ('input');
num_lines = 1;
defaultans = {'50'};
squareside = str2double(answers{2}); %converts ans to a number
for k = 1:numpics
I_mat{k}(squareside:squareside:end,:,:) = 0;% converts every nth row to black
I_mat{k}(:,squareside:squareside:end,:) = 0;% converts every nth column to black

[r,c] = size(I_mat{k});
numrows = floor(r/squareside); %calculates the number of full rows
numcols = floor(c/squareside); %calculates the number of full columns


for j = 1:1:numcols
    row = squareside*(j-1)+1;
    for i = 1:1:numrows
        col = squareside*(i-1)+1 ;
square = [row, col, squareside-2, squareside-2]; %  creates the square to be averaged
averages{i,j,k} = mean2(imcrop(I_mat{k},square)); % takes the average of each block

    end
end
figure, imshow(I_mat{k},[min(I_adj1) max(I_adj1)]) % displays each image at each minute

end

%% standard Deviation
for k = 1:numpics
I_mat{k}(squareside:squareside:end,:,:) = 0;% converts every nth row to black
I_mat{k}(:,squareside:squareside:end,:) = 0;% converts every nth column to black

[r,c] = size(I_mat{k});
numrows = floor(r/squareside); %calculates the number of full rows
numcols = floor(c/squareside); %calculates the number of full columns


for j = 1:1:numcols
    row = squareside*(j-1)+1;
    for i = 1:1:numrows
        col = squareside*(i-1)+1 ;
square = [row, col, squareside-2, squareside-2]; %  creates the square to be averaged
stdv{i,j,k} = std2(imcrop(I_mat{k},square)); % takes the average of each block

    end
end
end
%% find good data via standard deviations
for i = 1:numrows
    for j = 1:numcols
        for k = 1:numpics
            if stdv{i,j,k} > 500 %possibly include an if loop to eliminate entire columns
                line{i,j,k} = '--'; %used in 
               % averages{i,j,k} = NaN; %eliminates bad data
            else 
                line{i,j,k} = '-';
                gooddata{i,j,k} = averages{i,j,k}; %separates good data into separate array
                
            end
        end
    end
end

%% find good data for 

for i = 1:numrows
    for j = 1:numcols
        for k = 1:numpics 
            if abs(stdv{i,j,k}) >500  % eliminates data that deviates too, mostly edge squares
                for d = 1:15 % total number of pictures
                averages{i,j,d} = NaN;
                end   
            elseif averages{i,j,k} == 0
                for d = 1:15
                    averages{i,j,k} = NaN;
                end
            end
        end
    end
end

%% determining y-value limits
ylim_array = gooddata;
for i = 1:numrows
    for j = 1:numcols
        for k = 1:numpics
            if isempty(ylim_array{i,j,k}) % makes empty cells NaN
                ylim_array{i,j,k} = NaN;
            elseif ylim_array{i,j,k} <= 500 
                ylim_array{i,j,k} = NaN;
            elseif ylim_array{i,j,k} == 0
                for d = 1:15
                    ylim_array{i,j,d} = NaN;
                end
            end
        end
    end
end
ymin = min(cell2mat(ylim_array));
ymin = min(ymin);
ymin = min(ymin);
ymax = max(cell2mat(ylim_array));
ymax = max(ymax);
ymax = max(ymax);
%% graph averages
warning('off')
t = 1:numpics; % pictures start at t = 0
ypoints = cell(1,numpics); % preallocates y points
for i = 1:numrows
   figure(numpics + 1); 
    for j = 1:numcols
    ypoints = {};
        for k = 1:numpics
        ypoints{k} = averages{i,j,k};      
        end
      if isnan(ypoints{k}) == 0 %determines if the data is good for graphing       
        ypoints = cell2mat(ypoints); legend('show')
        coefficients = polyfit(t,ypoints,2); % creates the coefficients of the fitted curve. degree changes
        newypoints = polyval(coefficients,t); % creates new y points that are smoooth
        subplot(ceil(sqrt(numrows)),ceil(sqrt(numrows)),i) 
        plot(t,newypoints,'-','DisplayName',num2str(j)), hold on %can add real data points with t,y,'+'
        title(['row ' num2str(i)])
        xlabel('time')
        ylabel('pixel value')
        ylim([ymin,ymax]); %specify y limits
        xlim([1,numpics])
      end
    end
end

%% graph Standard deviations

% t = [0:numpics - 1];
% for i = 1:numrows
%     figure
%     for j = 1:numcols
%     xpoints = {};
%         for k = 1:numpics
%    
%         xpoints{k} = stdv{i,j,k};
%         end
%     xpoints = cell2mat(xpoints);
%     plot(t,xpoints), hold on
%     legend({'col 1','col 2', 'col 3', 'col 4', 'col 5', 'col 6', 'col 7', 'col 8', 'col 9', 'col 10'})
%     title(['Standard Deviation: row ' num2str(i)])
%     xlabel('time')
%     ylabel('pixel value')
%     end
% 
% end
