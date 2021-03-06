
%LEFT BREAST
[rwos,clos]=size(xe1);

flipx(1)=0; %preallocate
flipy(1)=0; %preallocate
for num=1:rwos
flipx=xe1(num,:)'; %puts data into columns
flipy=ye1(num,:)';
ellipsecoordinatesl{num}(:,1)=flipx; %these columns are put in a matrix, which are put into the cellarray 
ellipsecoordinatesl{num}(:,2)=flipy;
end

gotitl{12,12}=0; %preallocates the cell array that will include the overlapped points
for ok=1:length(ellipsecoordinatesl)
    for f=1:length(ellipsecoordinatesl)%finds all of the overlapping pixels of the ellipses.
        gotitl{ok,f}=intersect(ellipsecoordinatesl{f},ellipsecoordinatesl{ok},'rows');
    end
end
clear ok
clear f

%RIGHT BREAST
%
[rwosr,closr]=size(xe2);

flipxr(1)=0;
flipyr(1)=0;
for numr=1:rwosr
flipxr=xe2(numr,:)'; %column of 
flipyr=ye2(numr,:)';
ellipsecoordinatesr{numr}(:,1)=flipxr;
ellipsecoordinatesr{numr}(:,2)=flipyr;
end

gotitr{12,12}=0; %preallocates the cell array that will include the overlapped points
for ok=1:length(ellipsecoordinatesr)
    for f=1:length(ellipsecoordinatesr)
        gotitr{ok,f}=intersect(ellipsecoordinatesr{f},ellipsecoordinatesr{ok},'rows');
    end
end
clear ok
clear f

%Finding the hot pixel regions again.(the entire regions)
hotPix = 0; 
lowerBound = .009*perc*numel(I); % numel(I): the number of pixels in the image
upperBound = .011*perc*numel(I);

total = 0; 
for j = 1:numel(N)  %Shouldn't it be 0 to numel(N)
    total = total+ N(bins-j); %Tells us where the 1 percent of pixels start from but some of the bins still have zero in them
    if (total >= lowerBound)  
       break
    end 
end

k = 0;
for i = bins-j:bins %Keep all values that say 256 as 256. Matlab does not have a bin called 0 so there is an extra bin.
    if (N(i)~=0) %If the bin does not equal zero then move on to the next and add it to the hotPix list 
     k = k+1; 
     hotPix(k) = i;  %This contains the 1 percent of pixels that do not contain zero
    end 
end

newI = zeros(size(I)); %new image and make the entire image black
for m = 1:k
    o = find(I==hotPix(m)); %This looks for the hotPix in the image
    newI(o) = bins; %Make any value of the bightest 1 percent white
end


%LEFT BREAST

r = 1;
for n = 1:12
    for st=1:n-1
       newcelll{r}=gotitl{n,st}; 
       r=r+1;
    end
end
newnewl=newcelll(find(~cellfun(@isempty,newcelll)));

clear n
clear r
clear newcelll
%RIGHT BREAST

r = 1;
for n = 1:12
    for st=1:n-1
       newcell{r}=gotitr{n,st}; 
       r=r+1;
    end
end
newnewr=newcell(find(~cellfun(@isempty,newcell)));


[img_y, img_x] = size(I);
global withouttakingout
withouttakingout=zeros(img_y,img_x);
%Right
clear ar2
clear br2
clear dr2
for ar2 = 1:length(newnewr)                %a,b,n,m are just used as counters in the for loops - delete at end of section
    for br2 = 1:length(newnewr{ar2}(:,1))              %get x and y data from cell array of ellipses and round so we can use them as indices
        xinr(br2) = newnewr{ar2}(br2,1);
        yinr(br2) = newnewr{ar2}(br2,2);
    end

    for dr2 = 1:length(xinr)
       withouttakingout(yinr(dr2),xinr(dr2)) = 1;      %fill in 1's wherever there is a point in the ellipse
    end
end

%Left
clear a2
clear b2
clear d2
for a2 = 1:length(newnewl)                %a,b,n,m are just used as counters in the for loops - delete at end of section
    for b2 = 1:length(newnewl{a2}(:,1))              %get x and y data from cell array of ellipses and round so we can use them as indices
        xinl(b2) = newnewl{a2}(b2,1);
        yinl(b2) = newnewl{a2}(b2,2);
    end

    for d2 = 1:length(xinl)
       withouttakingout(yinl(d2),xinl(d2)) = 1;      %fill in 1's wherever there is a point in the ellipse
    end
end
% okay=bwmorph(withouttakingout,'bridge');
% okay2=bwmorph(okay,'thicken');
% okay3=bwmorph(okay2,'bridge');
% okay4=bwmorph(okay3,'thicken');

figure, imshow(I,[]), title('Pixels Where Ellipses Overlapped')
% red on top on figure
yellow = cat(3, ones(size(I)), ones(size(I)), zeros(size(I))); %yellow has RGB value 1 1 0
hold on 
displ = imshow(yellow); 
hold off 
% Use our diff1 as the AlphaData for the solid red image. 
set(displ, 'AlphaData', withouttakingout) 

[e,f]=size(withouttakingout);
okaynow=zeros(e,f);
for fir=1:f
    y=find(withouttakingout(:,fir)==1);
    if ~isempty(y)
    okaynow(y(end),fir)=1;
    end
end

% okaynow1=bwmorph(okaynow,'bridge');
% okaynow2=bwmorph(okaynow1,'thicken');
% okaynow3=bwmorph(okaynow2,'bridge');
% okaynow4=bwmorph(okaynow3,'thicken');


figure, imshow(I,[]), title('Lower Half Overlapped Pixels')
% red on top on figure
blue = cat(3, zeros(size(I)), zeros(size(I)), ones(size(I))); %blue has RGB value 0 0 1
hold on 
displ = imshow(blue); 
hold off 
% Use our diff1 as the AlphaData for the solid red image. 
set(displ, 'AlphaData', okaynow) 


global ellinhotpix
ellinhotpix=zeros(img_y,img_x);

%Right
clear ar2
clear br2
clear dr2
for ar2 = 1:length(newnewr)                %a,b,n,m are just used as counters in the for loops - delete at end of section
    for br2 = 1:length(newnewr{ar2}(:,1))              %get x and y data from cell array of ellipses and round so we can use them as indices
        xinr(br2) = newnewr{ar2}(br2,1);
        yinr(br2) = newnewr{ar2}(br2,2);
    end

    for dr2 = 1:length(xinr)
       ellinhotpix(yinr(dr2),xinr(dr2)) = 1;      %fill in 1's wherever there is a point in the ellipse
    end
    for n = 1:img_y
        for m = 1:img_x
            if newI(n,m) == 0
                ellinhotpix(n,m)=0;              %THIS IS NOT WORKING COMPLETELY YET!! Some pixels are still there
                %break;                              %if hotpixel = 0, then we want to remove that pixel of ellipse if its there
            end
        end
    end
end

%Left
clear a2
clear b2
clear d2
for a2 = 1:length(newnewl)                %a,b,n,m are just used as counters in the for loops - delete at end of section
    for b2 = 1:length(newnewl{a2}(:,1))              %get x and y data from cell array of ellipses and round so we can use them as indices
        xinl(b2) = newnewl{a2}(b2,1);
        yinl(b2) = newnewl{a2}(b2,2);
    end

    for d2 = 1:length(xinl)
       ellinhotpix(yinl(d2),xinl(d2)) = 1;      %fill in 1's wherever there is a point in the ellipse
    end
    for n = 1:img_y
        for m = 1:img_x
            if newI(n,m) == 0
                ellinhotpix(n,m)=0;              %THIS IS NOT WORKING COMPLETELY YET!! Some pixels are still there
                %break;                              %if hotpixel = 0, then we want to remove that pixel of ellipse if its there
            end
        end
    end
end


% now=bwmorph(ellinhotpix,'bridge');
% now2=bwmorph(now,'thicken');
% now3=bwmorph(now2,'bridge');
% now4=bwmorph(now3,'thicken');

figure, imshow(I,[]), title('HotPixel&Ellipses')
% red on top on figure
red = cat(3, ones(size(I)), zeros(size(I)), zeros(size(I))); %red has RGB value 1 0 0
hold on 
displ = imshow(red); 
hold off 
% Use our diff1 as the AlphaData for the solid red image. 
set(displ, 'AlphaData', ellinhotpix)

clear ar2 br2 dr2 a2 b2 d2
