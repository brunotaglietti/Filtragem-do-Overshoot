close all; clear all

root_dir = 'C:/Users/Bruno/Documents/Projetos Colaborativos/';
addpath([root_dir 'MatLab/'], [root_dir 'chav-amo-SOA-prbs'], 'functions', 'plots');
global fignum; fignum = 1;

SOA = 'CIP-L';
tech = 'misic';

bits_r = 4; deg_r = 1.2; imp_r = 1.2; bias_r = 0.1;
char_var = [bias_r, deg_r, imp_r];
method = sprintf([tech '-%i'],bits_r);

%% 
signal = syncd_import(SOA,char_var,method);

tic;
[switched, s_info] = sync_sw_frag(signal);
sw_res = sw_filter(switched, s_info);
toc;