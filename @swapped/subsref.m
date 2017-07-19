function varargout = subsref(obj, S)
    % Created by Viktor Horvath (Epstein lab at Brandeis) with 
    % MATLAB Version: 9.2.0.556344 (R2017a)
    % 2017-07-12
    
    % Accessing data and properties
%     assert(numel(S) == 1, 'Only single level indexing is supported.');
    varargout = cell(1, nargout);
    
    L1 = S(1);  % Level 1 indexing happens here

    if strcmp(L1.type, '.')              % Property access standard interface
        assert(nargout <= numel(L1.subs), 'Not enough output arguments');

        subs_ = L1.subs;
        if numel(L1.subs) == 1
            subs_ = {subs_};
        end

        for i = 1:numel(subs_)
            varargout{i} = obj.(subs_);
            if i == nargout
                continue;
            end
        end
    elseif strcmp(L1.type, '{}')         % Data access
        [f_paths, ixs] = obj.f_paths(L1.subs);

        if any(obj.bitmap(ixs))
            for i = 1:numel(f_paths)
                data = [];
                if obj.bitmap(ixs(i))
                    try
                        load(f_paths{i});
                    catch
                        warning('Error loading %d at file %s.', ixs(i), f_paths{i});
                    end
                end
                if numel(S) == 1
                    varargout{i} = data;
                elseif numel(S) > 1
                    varargout{i} = subsref(data, [S(2:end)]);
                end
                
                if i == nargout
                    continue;
                end
            end
        else
            varargout = cell(1, numel(f_paths));
            return;
        end

    elseif strcmp(L1.type, '()') % Bitmap access using parenthesis
        varargout{1} = obj.bitmap(S.subs{:});
    end

end
