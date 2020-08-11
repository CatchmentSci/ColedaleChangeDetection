function [totVolume] = mainLandslideDiff(scratch)

% Usage:  [totVolume] = mainLandslideDiff(Temp);
%
% Requirements: 
% MATLAB v9.7
% Mapping Toolbox 4.9
% Statistics and Machine Learning Toolbox v11.6
% b2r (downloaded automatically)
% replace_num (downloaded automatically)

% Temp: The working directory where the raw data files, and dependancies
% will be downloaded to. It is recommended that pwd is used as this is 
% commonly the MATLAB folder. If an alternative folder is desired this 
% should be assigned using quotation marks e.g. Temp = 'C:\Users\nm785\Documents'

% Outputs:
% totVolume: Total erosional volume of a major hillslope failure (m3)
% Figure: Figure 2 of 'Effect of an extreme flood event on solute transport and
% resilience of a mine water treatment system in a mineralised catchment'
% by Mayes et al (2020).

cd(scratch); % Use the pre-assigned temporary space

% Download the data files from Zenodo
websave('mainSlide_raster0.1.tif', 'https://zenodo.org/record/3979280/files/mainSlide_raster0.1.tif?download=1'); % Main landslide raster March 2016
websave('scarPoints.mat', 'https://zenodo.org/record/3979280/files/scarPoints.mat?download=1'); % Main landslide outline
websave('M3C2output.txt', 'https://zenodo.org/record/3979280/files/M3C2output.txt?download=1'); % DoD (March - Dec 2016)

% Download additional scripts from GitHub
websave('b2r.m', 'https://raw.githubusercontent.com/CatchmentSci/ColedaleChangeDetection/master/b2r.m'); % Download dependancy
websave('replace_num.m', 'https://raw.githubusercontent.com/CatchmentSci/ColedaleChangeDetection/master/replace_num.m'); % Download dependancy

%% Calculate and plot the initial effects of Storm Desmond

filenameIn = [scratch '\mainSlide_raster0.1.tif'];
[A,~] = geotiffread(filenameIn);
A = replace_num(A,0,NaN);
I = geotiffinfo(filenameIn); 
[x,y]=pixcenters(I);
[X,Y]=meshgrid(x,y);

% load the outline of the main landslide (mapped maually)
load([scratch '\scarPoints.mat']);
B = scarArea;
pgon = polyshape(B(:,1),B(:,2));

for a = 1:length(B(:,1))
    x = B(a,1); %// define point
    y = B(a,2);
    d = (x-X).^2+(y-Y).^2; %// compute squared distances
    [~, ind] = min(d(:)); %// minimize distance and obtain (linear) index of minimum
    resultX = X(ind); %// use that index to obtain the result
    resultY = Y(ind);
    B(a,3) = A(ind);
end

z1 = griddata(B(:,1),B(:,2),B(:,3),X,Y,'natural'); % natural neighbor
[in,on] = inpolygon(X,Y,pgon.Vertices(:,1),pgon.Vertices(:,2));
z1(~in) = NaN; 
A(~in) = NaN;

% Compute differences
diff1 = A - z1;
rep1 = find(diff1 < -3);
rep2 = find(diff1 > 0);
diff1(rep1) = NaN;
diff1(rep2) = NaN;

% Create plots
f0 = figure();hold on
ax1 = subplot(1,2,1);
set(ax1,'DefaultTextFontName','Arial') 
f0.Units='normalized';
set(f0,'Position',[0.5003    0.0285    0.4994    0.9125])
mesh(X,Y,diff1);
axis equal
axis tight
xLim = xlim;
yLim = ylim;
view([0,90])
set(ax1,'fontname','Arial') 
set(ax1,'fontweight','normal')
xlabel('X Coordinates [BNG m]', 'fontweight','bold');
ylabel('Y Coordinates [BNG m]', 'fontweight','bold');
set(ax1,'fontsize',20)
NumTicks = 4;
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1),L(2),NumTicks))

d1 = colorbar;
set(d1, 'ylim', [-1.6 0])
colormap(b2r(-1.6,1.6))
ylabel(d1, 'Surface elevation change [m]', 'fontweight','bold');
d1.FontSize = 20;
d1.Location = 'northoutside';
set(d1,'fontname','Arial')
grid on
set(ax1, 'Layer', 'top')

annotation(f0,'textbox',...
    [0.0685042609270661 0.929193302891933 0.0251942237661938 0.0342465753424658],...
    'String','A)',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

% Summary statistics
ave_depth = nanmean(diff1(:));
sumDepth = nansum(diff1(:));
num_cells = sum(~isnan(diff1(:)));
area_m(1) = num_cells./100;
volumeCalc(1) = area_m(1).*ave_depth;
totVolume = sum(volumeCalc);

%% Show the continuing change in the second subplot
filenameIn2 = [scratch '\M3C2output.txt'];
C = readmatrix(filenameIn2);
rem1 = find(C(:,6) > 0);
rem2 = find(C(:,6) < -2);
distChange = C(:,6);
distChange(rem1) = NaN;
distChange(rem2) = NaN;

ax2 = subplot(1,2,2);
hold on;
set(ax2,'DefaultTextFontName','Arial') 
set(ax2,'fontname','Arial') 
xlabel('X Coordinates [BNG m]', 'fontweight','bold');
ylabel('Y Coordinates [BNG m]', 'fontweight','bold');
axis equal
axis tight

scatter (C(:,1),C(:,2),3,distChange,'filled'); hold on;
d2 = colorbar;
set(d2, 'ylim', [-0.4 0])
colormap(b2r(-0.4,0.4))

ylabel(d2, 'Surface elevation change [m]', 'fontweight','bold');
d2.FontSize = 20;
xlim(xLim);
ylim(yLim);
NumTicks = 4;
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1),L(2),NumTicks))
set(ax2,'fontsize',20)
d2.Location = 'northoutside';
set(d2,'fontname','Arial')

plot(B(:,1),B(:,2),... % Plot the outline of the original scar area
    'LineStyle' ,'--',...
    'Color', [17 17 17]/255)
grid on
set(ax2, 'Layer', 'top')

% Create textbox
annotation(f0,'textbox',...
    [0.51264187722942 0.929193302891933 0.0251942237661937 0.0342465753424658],...
    'String','B)',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

% Set export options and export the image
set(gcf,'renderer','opengl')
%print -depsc -tiff -r600 Figure2.eps % Uncomment to export the Figure


