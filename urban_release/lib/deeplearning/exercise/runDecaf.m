function output = runDecaf(filelist, layer)

this_folder = pwd;
folder = 'decaf-release';
if(~exist(folder, 'dir'))
    error(['Cannot find folder: ' folder]);
end

if(~exist('layer', 'var'))
    layer = 'final';
end

if(~iscell(filelist))
    error('filelist must be a cell array');
end

modelfile = [pwd '/' folder '/models/imagenet.decafnet.epoch90'];
metafile = [pwd '/' folder '/models/imagenet.decafnet.meta'];

save([folder '/tmp_decaf_filelist.mat'], 'filelist', 'layer', 'modelfile', 'metafile');

if ~ispc
    cd(folder);
    unix(['python runDecaf.py']);
    cd(this_folder);
else
    dos(['C:\cygwin64\bin\bash.exe -c "cd ' [this_folder '/' folder] ';/usr/bin/python runDecaf.py"'])
end

output = load([folder '/tmp_decaf_output.mat']);

delete([folder '/tmp_decaf_filelist.mat']);
delete([folder '/tmp_decaf_output.mat']);