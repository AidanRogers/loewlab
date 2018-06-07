function [ClustStruct,ClustData] = symmetry_cluster1(ImageMatrix, epsilon, minPts, percent, ptID) %CHANGED PERCENT to PERCENT_VAL

I = getMatrixOutliers(ImageMatrix);   % Remove Outliers
I_adj = I(find(I>0));
[r c] = find(I);


% Find xyz info
for a = 1:length(r)
    xyz(a,1) = c(a); %X-coordinate
    xyz(a,2) = r(a); %Y-coordinate
    xyz(a,3) = I(r(a), c(a)); %value at that x,y coordinate
end  


[Clusters, isNoise] = DBSCAN(xyz,epsilon,minPts); % Run DBSCAN on Pixels above Intensity Percentage
ClustersNew = Clusters;
ClustersNew(isNoise) = [];      % Remove all Noise Pixels from Clusters

figure('Name','Pre-Symmetrical Cluster Analysis')
imshow(I,[min(I_adj) max(I_adj)]);                          % Display Image w Contrast
hold on;
PlotClusterinResult(I,ClustersNew); hold on;              % Plot Clusters on Image
% plot([c1(1) c2(1)],[c1(2) c2(2)],'r');                      % Create red box region on Image Display
% plot([c2(1) c3(1)],[c2(2) c3(2)],'r');
% plot([c3(1) c4(1)],[c3(2) c4(2)],'r');
% plot([c4(1) c1(1)],[c4(2) c1(2)],'r');
title(sprintf('%s - Pre Symmetrical Cluster Analysis',ptID));
xlabel(sprintf('Top %.2f of Pixels',percent2*100));
hold off;
hold off;
ClusterData(:,(1:2)) = hotregionNew;    % Columns 1,2 are X,Y Indices
ClusterData(:,3) = ClustersNew;         % Column 3 is Cluster Number
numClusters = max(ClusterData(:,3));    % Number of Clusters in Image

% Allocate Cluster Structure with Necessary Fields for Data Tracking
ClusterStruct(1:numClusters) = struct('ClusterNumber',0,'ClusterIndices',[],'ClusterMeanIntensity',[],'ClusterStdIntensity',[],'StdDivMean',[],'ClusterCentroid',[],'RemoveCluster',0,'NormalizedCluster',[]);

% Cluster Number
for c = 1:numClusters   
    ClusterStruct(c).ClusterNumber = c;
end

% Cluster Indices
for a = 1:length(ClusterData) %Sort Through ClusterData Matrix
    b = ClusterData(a,3); %B is the Cluster Number of Indices in Column A
    if isempty(ClusterStruct(b).ClusterIndices) %If ClusterStruct entry has no indices, input the first indices from the cluster
        ClusterStruct(b).ClusterIndices(1,:) = ClusterData(a,(1:2));
    else %If Cluster entry already has indices, place new ones in end+1 row
        ClusterStruct(b).ClusterIndices(end+1,:) = ClusterData(a,(1:2));
    end
end

%Cluster Centroids
for j = 1:numClusters
    %Make Binary Mask of Full Image with Cluster Isolated
    ImBinMask = zeros(size(I));
    for a = 1:length(ClusterStruct(j).ClusterIndices)
        ImBinMask(ClusterStruct(j).ClusterIndices(a,2),ClusterStruct(j).ClusterIndices(a,1)) = 1;
    end
    centroid = regionprops(true(size(ImBinMask)), ImBinMask, 'WeightedCentroid');
    ClusterStruct(j).ClusterCentroid = round(centroid.WeightedCentroid);
end

% Calculate Statistics 
for i = 1:numClusters %For each cluster, calculate the Mean and Standard Deviation for Intensity 
    ClusterStruct(i).ClusterMeanIntensity = mean2(I(ClusterStruct(i).ClusterIndices(:,2),ClusterStruct(i).ClusterIndices(:,1)));
    ClusterStruct(i).ClusterStdIntensity = std2(I(ClusterStruct(i).ClusterIndices(:,2),ClusterStruct(i).ClusterIndices(:,1)));

    %StandardDeviation / Mean is the indicator from Li Jiang Paper 
    ClusterStruct(i).StdDivMean = ClusterStruct(i).ClusterStdIntensity / ClusterStruct(i).ClusterMeanIntensity;
     %Matrix Referral is (Row,Column) so must reverse the indices when calling the statistics
end

ClustStruct = ClusterStruct;
ClustData = ClusterData;
end