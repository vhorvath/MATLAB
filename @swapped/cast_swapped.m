function obj = cast_swapped(~, filename)
    % Created by Viktor Horvath (Epstein lab at Brandeis) with 
    % MATLAB Version: 9.2.0.556344 (R2017a)
    % 2017-07-12
    
    pathstr = fileparts(filename);
    
    S = load(filename);         % Need to update data location
    f_fields = fieldnames(S);   % because the structure may have
    obj = S.(f_fields{1});      % been moved 
    obj.folder = pathstr;
    obj.o_path = filename;

    obj.ixmap = reshape(1:numel(obj.bitmap), size(obj.bitmap));
    % Checking if reconstruction of data consistency
    o_stats = dir(obj.o_path);
    d_stats = dir(obj.path);
    d_stats = d_stats(~[d_stats.isdir]);
    d_stats = d_stats(~arrayfun(@(x) isempty(x), strfind({d_stats.name}, '.mat')));

    % If any files were created after the main file, we reconstruct
    % the object, but do not update the file, that is the job of
    % the destructor
    if any([d_stats.datenum] > o_stats.datenum)
        warning('Inconsistency between object and data, reconstructing bitmap');
        ixs = {d_stats.name};
        obj.bitmap = obj.bitmap * 0;
        for ix = ixs
            obj.bitmap(str2double(ix{1}(1:(end-4)))) = 1;
        end
        obj.write_out();
    end

end

