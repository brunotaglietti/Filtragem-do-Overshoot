function [method, bits, vars] = char_config(bias,deg)
%%
global setups
fig = uifigure('Name', 'Configuration', 'Position', [680 558 360 200]);
panel = uipanel(fig);
panel.Position = fig.Position .* [0 0 1 1] + [20 20 -40 -40];
bg2 = uibuttongroup(panel,...
                  'Title','Switching',...
                  'Position', [20 60 120 80]);
uiradiobutton(bg2,...
                  'Text','PISIC',...
                  'Value',1,...
                  'UserData','pisic',...
                  'Position',[15 35 100 15]);              
uiradiobutton(bg2,...
                  'Text','MISIC',...
                  'UserData','misic',...
                  'Position',[15 15 100 15]);
              
bg3 = uibuttongroup(panel,...
                  'Title','Impulse bits',...
                  'Position', [180 40 120 100]);
uiradiobutton(bg3,...
                  'Text','160ps',...
                  'UserData',2,...
                  'Value',1,...
                  'Position',[15 55 100 15]);
uiradiobutton(bg3,...
                  'Text','320ps',...
                  'UserData',4,...
                  'Position',[15 35 100 15]);
uiradiobutton(bg3,...
                  'Text','640ps',...
                  'UserData',8,...
                  'Position',[15 15 100 15]);
              
uilabel(panel,'Position', panel.Position .* [.5 0 0 0] + [15 30 150 20],...
                  'Text','Select scope:');

uibutton(panel,'Text','Single',...
                  'Position', panel.Position .* [.5 0 0 0] + [10 10 50 20],...
                  'ButtonPushedFcn', @(btn,event) plotButtonPushed(fig,bg2,bg3));
uibutton(panel,'Text','Whole',...
                  'Position', panel.Position .* [.5 0 0 0] + [70 10 50 20],...
                  'ButtonPushedFcn', @(btn2,event) plotButtonPushed2(fig,bg2,bg3));
uiwait(fig);

method = setups.tech;
bits = setups.bits;
if strcmp(setups.scope,'whole'), vars.bias = bias; vars.deg = deg;
elseif strcmp(setups.scope,'single')
        select_curve(bias,deg);
        vars.bias = setups.bias; vars.deg = setups.deg;
end
end

function plotButtonPushed(fig,bg2,bg3)
    global setups;
    setups.tech = bg2.SelectedObject.UserData;
    setups.bits = bg3.SelectedObject.UserData;
    setups.scope = 'single';
    delete(fig);
end
function plotButtonPushed2(fig,bg2,bg3)
    global setups;
    setups.tech = bg2.SelectedObject.UserData;
    setups.bits = bg3.SelectedObject.UserData;
    setups.scope = 'whole';
    delete(fig);
end

function select_curve(bias,deg)
%%
if length(deg)> 1 fig = uifigure('Name', 'Selection', 'Position', [680 558 480 250]);
else, fig = uifigure('Name', 'Selection', 'Position', [680 558 280 250]); end
panel = uipanel(fig);
panel.Position = fig.Position .* [0 0 1 1] + [20 20 -40 -40];

kb = uiknob(panel,'discrete',...
    'ValueChangedFcn',@(kb,event) knob1Turned(kb));
kb.Position = [80 panel.Position(4)-150 80 80];

kbItems = cell(1,length(bias)); kbItemsData = kbItems;
for i = 1:length(bias), kbItems{i} = num2str(bias(i)*1e3); kbItemsData{i} = bias(i); end
kb.Items = kbItems; kb.ItemsData = kbItemsData; kb.Value = 0.08;

uilabel(panel, 'Position', [kb.Position(1:2)+[0 110], 150, 20],...
    'fontweight','bold','Text', 'SOA bias (mA)');
if exist('deg','var') && length(deg)>1
kb2 = uiknob(panel,'discrete',...
    'Position', [panel.Position(3)-160, panel.Position(4)-150, 80, 80],...
    'ValueChangedFcn',@(kb2,event) knob2Turned(kb2));
kb2Items = cell(1,length(deg)); kb2ItemsData = kb2Items;
for i = 1:length(deg), kb2Items{i} = num2str(deg(i)); kb2ItemsData{i} = deg(i); end;
kb2.Items = kb2Items; kb2.ItemsData = kb2ItemsData; kb2.Value = 1.2;

uilabel(panel, 'Position', [kb2.Position(1:2)+[15 110], 150, 20],...
    'fontweight','bold','Text', 'Step (V)');
else, kb2.Value = deg;
end

uibutton(panel, 'Position', [panel.Position(3)/2-35 10 70 20],...
    'Text', 'Set',...
    'ButtonPushedFcn', @(btn,event) plotButtonPushed3(fig,kb,kb2));
uiwait(fig);
end

function knob1Turned(kb)
global setups;
setups.bias = kb.Value;
end
function knob2Turned(kb2)
global setups;
setups.deg = kb2.Value;
end
function plotButtonPushed3(fig,kb,kb2)
global setups;
setups.bias = kb.Value;
setups.deg = kb2.Value;
delete(fig);
end