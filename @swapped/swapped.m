classdef swapped < handle
    % S = swapped(n)
    % S = swapped(sz1, ..., szN)
    % S = swapped(sz)
    %
    % S = swapped(folder, ___)
    % S = swapped(filename)
    %
    % SWAPPED data type provides a standard cell array interface to store
    % data. This is a rigid variable, location and size are defined upon
    % creation. The created variable, S, is a handle or reference, it does
    % not create a new instance when it is copied or renamed, i.e. if 
    % A = S, then both A and S refers to the same datastructure: they are
    % handles (or references). Only when both handles are cleared will the
    % main oject file update!
    %
    % S = swapped(n) creates n x n swapped array
    %
    % S = swapped(sz1, ..., szN) creates array of N dimensions with sz1 ...
    % SzN size of each
    %
    % S = swapped(sz) creates array with dimensions given as a vector sz
    %
    % S = swapped(folder, ___) creates a swapped array under the given
    % folder
    %
    % S = swapped(filename) loads an existing swapped array
    %
    % Data access is performed through standard cell array interface
    % Set a value:          S{1} = obj
    % Retreive a value:     x = S{1}
    % To check occupancy:   S(1)
    %
    % File operations take place whenever a value is (re)written, if the
    % value is an empty vector ([]), the file is removed and the occupancy
    % matrix is set to zero.
    %
    % Properties
    % ----------------
    % size: Array dimensions
    % numel: Number of elements 
    % occupancy: Size of data on harddisk
    %
    % Created by Viktor Horvath (Epstein lab at Brandeis) with 
    % MATLAB Version: 9.2.0.556344 (R2017a)
    % 2017-07-12

    properties
        folder = '.';       % Data location (read only)
    end
    
    properties(SetAccess = protected)
        UUID = char(java.util.UUID.randomUUID);    % Unique identifier (read only)
        bitmap = [];                               % Indices where data is stored (read only)
        path = [];                                 % Path to data (read only)
        size = [];                                 % Array dimensions
        numel = 0;                                 % Number of elements
        occupancy                                  % Size on harddisk
    end
    
    properties(SetAccess = protected, Transient = true, Hidden = true)
        ixmap = [];         % Helper for indexing (invisible)
        o_path = '';        % Object path
        cleanup             % Helper for destructing upon clear
    end
    
    properties(Access = private, Hidden = true)
        varname = '';       % Original variable name
    end
    
    methods
        function obj = swapped(filename, varargin)
            % Construction according to the usage scenarios            
            if isa(filename, 'char')
                [pathstr, name, ext] = fileparts(filename);
                if strcmp('.mat', ext)          % First arugment is a file
                    if numel(varargin) > 0
                        warning('Array dimensions are ignored');
                    end
                    obj = obj.cast_swapped(filename);
                else                            % First argument is a folder
                    obj.folder = fullfile(pathstr, [name, ext]);
                    assert(numel(varargin) > 0, 'Missing array dimensions');
                end
                size_args = varargin;
            else
                size_args = {filename, varargin{:}};
            end
            
            if isempty(obj.bitmap)              % Array from scratch
                obj.bitmap = zeros(size_args{:});
                obj.ixmap = reshape(1:numel(obj.bitmap), size(obj.bitmap));
                obj.size = size(obj.bitmap);
                obj.numel = prod(obj.size);
                obj.o_path = fullfile(obj.folder, sprintf('%s.mat', obj.UUID));
            end
            
            obj.cleanup = onCleanup(@() delete(obj));    % Making sure destructor is called when clearing
        end
        
        varargout = subsref(obj, S)
        obj = subsasgn(obj, S, varargin)
        
        function path = get.path(obj)
            path = fullfile(obj.folder, obj.UUID);
        end
        
        function occupancy = get.occupancy(obj)
            % Calculate the number of bytes the data occupies on harddisk 
            o_stats = dir(obj.o_path);
            d_stats = dir(obj.path);
            d_stats = d_stats(~[d_stats.isdir]);
            d_stats = d_stats(~arrayfun(@(x) isempty(x), strfind({d_stats.name}, '.mat')));
            occupancy = sum([d_stats.bytes]) + o_stats.bytes;
        end
               
        function delete(obj)
            if ~isempty(obj.size)
                obj.write_out;
            end
        end
    end
    
    methods (Access = private)
        function [f_paths, ixs] = f_paths(obj, subs_)
            % Get data file paths
            try
                obj.bitmap(subs_{:});
            catch
                error('Dimension mismatch array size = [%d %d].', size(obj.bitmap));
            end
            ixs = obj.ixmap(subs_{:});
            ixs = [ixs(:)];
            f_paths = arrayfun(@(x) fullfile(obj.folder, obj.UUID, sprintf('%d.mat', x)), ixs, 'UniformOutput', false);            
        end
        
        function write_out(obj)
            % Writing temporary object file
            if exist(obj.path, 'dir') ~= 7
                mkdir(obj.path)
            end
            tmp = struct('maindata', obj);
            save(obj.o_path, '-struct', 'tmp');
        end
        
        obj = cast_swapped(obj, filename)
    end
end

