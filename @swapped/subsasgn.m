function obj = subsasgn(obj, S, varargin)
    % Created by Viktor Horvath (Epstein lab at Brandeis) with 
    % MATLAB Version: 9.2.0.556344 (R2017a)
    % 2017-07-12
    
    % Data setting methods
    L1 = S(1);      % Top level indexing
    if strcmp(L1.type, '.')  % standard interface for properties
        if strcmp(L1.subs, 'folder')
            assert(~any(obj.bitmap), 'Folder cannot be changed after data storage');
        end

        obj.(L1.subs) = varargin{1};

    elseif strcmp(L1.type, '{}') % interface for writingout data
        if ~any(obj.bitmap(:))
            obj.write_out();
        end
        [f_paths, ixs] = obj.f_paths(L1.subs);
        for i = 1:numel(varargin)
            f_path = f_paths{i};
            if ~isempty(varargin{i})
                if numel(S) == 1
                    data = varargin{i};
                elseif numel(S) > 1
                    data = subsref(obj, struct('type', '{}', 'subs', {{ixs(i)}}));
                    data = subsasgn(data, [S(2:end)], varargin{i});
                end
                
                try
                    save(f_path, 'data');
                catch
                    warning('Error saving %d at file %s.', ixs(i), f_paths{i});
                end
            else
                if exist(f_path, 'file') == 2
                    delete(f_paths{i});
                end
            end

            obj.bitmap(ixs(i)) = ~isempty(varargin{i});
        end

    elseif strcmp(L1.type, '()') % Bitmap write acess is denied
        error('%s.bitmap is read-only, use curly braces to access content.', obj.varname);
    end
end