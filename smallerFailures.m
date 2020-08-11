function [] = smallerFailures(scratch)

% Usage:  smallerFailures(Temp);
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
% Figure: Figure S4 of 'Effect of an extreme flood event on solute transport and
% resilience of a mine water treatment system in a mineralised catchment'
% by Mayes et al (2020).

cd(scratch); % Use the pre-assigned temporary space

% Download the data files from Zenodo
websave('M3C2output.txt', 'https://zenodo.org/record/3979280/files/M3C2output.txt?download=1'); % DoD (March - Dec 2016)
websave('coledale_tif.tif', 'https://zenodo.org/record/3979280/files/coledale_tif.tif?download=1'); % Download Coledale basemap

% Download additional scripts from GitHub
websave('b2r.m', 'https://raw.githubusercontent.com/CatchmentSci/ColedaleChangeDetection/master/b2r.m'); % Download dependancy
websave('replace_num.m', 'https://raw.githubusercontent.com/CatchmentSci/ColedaleChangeDetection/master/replace_num.m'); % Download dependancy

%% Load the basemap image
[A, R] = geotiffread([scratch '\coledale_tif']); % Load in the background image
info = geotiffinfo([scratch '\coledale_tif']);

height = info.Height; % Integer indicating the height of the image in pixels
width = info.Width; % Integer indicating the width of the image in pixels
[rows,cols] = meshgrid(1:width,1:height);
[X,Y] = pix2map(R, cols,rows);
f00 = figure();
f00.Units='normalized';
set(f00,'DefaultTextFontName','Arial') 
set(f00,'Position',[0.5003    0.0285    0.4994    0.9125])
hold on;
ax1 = subplot(1,2,1); hold on;
set(ax1,'fontname','Arial') 
set(ax1,'fontweight','normal')

transparentMap = double(A(:,:,1) ~= 0);
p1 = imagesc(X(1,:),Y(:,1),A);
set(p1, 'AlphaData', transparentMap);
xlabel('X Coordinates [BNG m]', 'fontweight','bold');
ylabel('Y Coordinates [BNG m]', 'fontweight','bold');
set(ax1,'fontsize',20)
axis equal
axis tight
xLim = xlim;
yLim = ylim;
view([0,90])
set(ax1,'YDir','normal')

% Area one
xlim([321564.951447255,321629.464602935]);
ylim([522508.302183204,522562.614906203]);

NumTicks = 4;
L = get(ax1,'XLim');
set(gca,'XTick',linspace(L(1),L(2),NumTicks))
L2 = get(ax1,'YLim');
set(gca,'YTick',linspace(L2(1),L2(2),NumTicks))

% Load the DoD
filenameIn = [scratch '\M3C2output.txt'];
B = readmatrix(filenameIn);

rem1 = find(B(:,6) > -0.2); % not deposition
rem2 = find(B(:,6) < -3.0); % upto approx 99 percentile 99% = 3.2; 0.1% = 1.81
rem3 = find(B(:,4) == 0); % not signifcant change
distChange = B(:,6);
distChange(rem1) = NaN;
distChange(rem2) = NaN;
distChange(rem3) = NaN;
ploter = find(~isnan(distChange));

scatter (B(ploter,1),B(ploter,2),3,distChange(ploter),'filled');
d3 = colorbar;
set(d3, 'ylim', [-2 -0.2])
colormap(b2r(-2,2))
ylabel(d3, 'Surface elevation change [m]','fontweight','bold');
d3.FontSize = 20;
d3.Location = 'northoutside';
set(d3,'fontname','Arial')
set(ax1, 'Layer', 'top')

% Create textbox
annotation(f00,'textbox',...
    [0.0446384126067575 0.73208523592085 0.0251942237661936 0.0342465753424654],...
    'String','A)',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

%% Second area of interest

ax2 = subplot(1,2,2); hold on;
transparentMap = double(A(:,:,1) ~= 0);
p2 = imagesc(X(1,:),Y(:,1),A);
set(p2, 'AlphaData', transparentMap);

set(ax2,'fontname','Arial') 
set(ax2,'fontweight','normal')
xlabel('X Coordinates [BNG m]', 'fontweight','bold');
ylabel('Y Coordinates [BNG m]', 'fontweight','bold');
set(ax2,'fontsize',20)
axis equal
axis tight
xLim = xlim;
yLim = ylim;
view([0,90])
set(ax2,'YDir','normal')

% Area two
xlim([321940.109466234,322012.961057003]);
ylim([522703.293171517,522764.625906332]);

NumTicks = 4;
L = get(ax2,'XLim');
set(ax2,'XTick',linspace(L(1),L(2),NumTicks))
L2 = get(ax2,'YLim');
set(ax2,'YTick',linspace(L2(1),L2(2),NumTicks))

rem1 = find(B(:,6) > -0.2); % not deposition
rem2 = find(B(:,6) < -3.0); % upto approx 99 percentile 99% = 3.2; 0.1% = 1.81
rem3 = find(B(:,4) == 0); % not signifcant change
distChange2 = B(:,6);
distChange2(rem1) = NaN;
distChange2(rem2) = NaN;
distChange2(rem3) = NaN;
ploter = find(~isnan(distChange2));

scatter (B(ploter,1),B(ploter,2),3,distChange2(ploter),'filled');
d4 = colorbar;
set(d4, 'ylim', [-3 -0.2])
colormap(b2r(-3,3))
ylabel(d4, 'Surface elevation change [m]','fontweight','bold');
d4.FontSize = 20;
d4.Location = 'northoutside';
set(d4,'fontname','Arial');
set(ax2, 'Layer', 'top');
   
% Create textbox
annotation(f00,'textbox',...
    [0.514970252675304 0.73208523592085 0.0251942237661937 0.0342465753424654],...
    'String','B)',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

% Set export options and export the image
set(gcf,'renderer','opengl')
%print -depsc -tiff -r600 S4.eps % Uncomment to export the Figure



