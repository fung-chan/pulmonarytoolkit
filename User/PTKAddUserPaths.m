function PTKAddUserPaths(varargin)

force = nargin > 0 && strcmp(varargin{1}, 'force');

% This version number should be incremented whenever new paths are added to
% the list
PTKAddPaths_Version_Number = 1;

persistent PTK_PathsHaveBeenSet

full_path = mfilename('fullpath');
[path_root, ~, ~] = fileparts(full_path);

path_folders = {};

% List of folders to add to the path
path_folders{end + 1} = '';
path_folders{end + 1} = fullfile('Library');
path_folders{end + 1} = fullfile('Library','ViewMeshFromCMISS');
path_folders{end + 1} = fullfile('Library','canny');
path_folders{end + 1} = fullfile('mex');
path_folders{end + 1} = fullfile('Gui');
path_folders{end + 1} = fullfile('MyFiles');
path_folders{end + 1} = fullfile('MyFiles');

AddToPath(path_root, path_folders)

% Now add the plugins (have to do this afterwards, because we rely on
% library functions, so the library paths have to be set first)
path_folders = {};

plugin_folders = CoreDiskUtilities.GetRecursiveListOfDirectories(fullfile(path_root,'Gui','GuiPlugins'));
for folder = plugin_folders
    path_folders{end + 1} = folder{1}.First;
end

plugin_folders = CoreDiskUtilities.GetRecursiveListOfDirectories(fullfile(path_root,'Plugins'));
for folder = plugin_folders
    path_folders{end + 1} = folder{1}.First;
end

AddToPath('', path_folders);

PTK_PathsHaveBeenSet = PTKAddPaths_Version_Number;


end


function AddToPath(path_root, path_folders)
full_paths_to_add = {};

% Get the full path for each folder but check it exists before adding to
% the list of paths to add
for i = 1 : length(path_folders)
    full_path_name = fullfile(path_root, path_folders{i});
    if exist(full_path_name, 'dir')
        full_paths_to_add{end + 1} = full_path_name;
    end
end


% Add all the paths together (much faster than adding them individually)
if ~isempty(full_paths_to_add)
    addpath(full_paths_to_add{:});
end
end