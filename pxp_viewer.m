function pxp_viewer(pxp, varargin)
% Viewer for records that have been produced by pxp2mat.py. needs at least 2020b
% or around there.
% Variables in the pxp-file are presented in a copy-pasteable way and wave-data
% can be exported by right-clicking the table in which they are presented. Note
% that wave-data is padded with NaNs in the table view (needed to make it work
% in a plain old figure as opposed to uifigure), these NaNs are not exported
% unless explicitly selected.
%
% Usage:
% pxp = load('converted_pxp_file.mat');
% pxp_viewer(pxp);
    assert(isstruct(pxp) && isfield(pxp, 'records') && isfield(pxp, 'meta'), ...
           'pxps are structs with some fields and whatnot buddy');
    f = figure('Name','PXP viewer');
    tg = uitabgroup(f, 'Units', 'normalized', 'Position', [0 0 1 1]);
    % one tab for each type of row
    types = unique(pxp.meta, 'rows');
    for i = 1:size(types, 1)
        % pxp.meta is a char matrix we trim it to make a title
        tt = types(i, types(i,:) ~= ' ');
        tt(1) = upper(tt(1));
        t = uitab(tg, 'Title', tt);
        if startsWith(types(i,:), 'history') || startsWith(types(i,:), 'packedFile')
            % these we just dump out as text
            dump_text(pxp, types(i,:), t);
        elseif startsWith(types(i,:), 'variables')
            % these too, but it needs some fiddling to do so
            vars = [pxp.records{startsWith(string(pxp.meta), 'variables')}];
            % a cell array of chars/strings will put each cell on a new line in
            % an edit-control, hence this thing
            struc2cell_str = @(s) strcat(fieldnames(s), ...
                                         sprintfc(' = %g;', struct2array(s))');
            vw = 1/numel(vars);
            for ii = 1:numel(vars)
                uicontrol(t, 'Style', 'edit', 'Max', 100, 'Min', 1, ...
                          'Units', 'normalized', ...
                          'Position', [(ii-1)*vw, 0, vw, 1], ...
                          'HorizontalAlignment', 'left', ...
                          'String', [{'% User variables:'}; ...
                                     struc2cell_str(vars(ii).userVars); ...
                                     {''; '% System variables:'}; ...
                                     struc2cell_str(vars(ii).sysVars)]);
            end
        elseif startsWith(types(i,:), 'wave')
            waves = [pxp.records{startsWith(string(pxp.meta), 'wave')}];
            if numel(waves) > 1; t.Title(end+1) = 's'; end
            % waves are presented in two additional tabs, a table and as plots
            wtg = uitabgroup(t, 'Units', 'normalized', 'Position', [0 0 1 1]);
            wtt = uitab(wtg, 'Title', 'Table');
            % exporting to workspace-menu
            cm = uicontextmenu(f);
	        uimenu('Parent', cm, ...
		           'Label', 'Export selected values to workspace', ...
		           'Callback', @(~,~) save2ws(waves, 1), ...
                   'Enable', 'off');
	        uimenu('Parent', cm, ...
		           'Label', 'Export wave(s) with selected cell(s) to workspace', ...
		           'Callback', @(~,~) save2ws(waves, 2), ...
                   'Enable', 'off');
	        uimenu('Parent', cm, ...
		           'Label', 'Export all waves to workspace', ...
		           'Callback', @(~,~) save2ws(waves, 3));
            % the selection callback just stores the selected cells' indices in
            % the table's UserData
            w_tbl = uitable('Parent', wtt, 'Units', 'normalized', ...
                            'Position', [0, 0, 1, 1], ...
                            'ColumnName', {waves.name}, ...
                            'Data', cell2padded_mat({waves.data}, NaN), ...
                            'ContextMenu', cm, ...
                            'CellSelectionCallback', @tbl_sel_cb);

            % plots tab just dumps out all the waves in a tight flow layout
            wtp = uitab(wtg, 'Title', 'Plots');
            spacing = 'tight';
            if isMATLABReleaseOlderThan('R2021a'); spacing = 'none'; end
            tl = tiledlayout(wtp, 'flow', 'TileSpacing', spacing, ...
                             'Padding', spacing);
            for wv = reshape(waves, 1, [])
                ah = nexttile(tl);
                plot(ah, wv.data, varargin{:});
                title(ah, wv.name, 'interpreter', 'none');
            end
        else
            error('Unknown type "%s" in pxp.meta', types(i,:));
        end
    end

    % helpers
    function dump_text(pxp, type, parent)
        idxs = find(startsWith(string(pxp.meta), type));
        if numel(idxs) > 1; parent.Title(end+1) = 's'; end
        tw = 1/numel(idxs);
        flds = {'text', 'data'};
        fld = flds{isfield(pxp.records{idxs(1)}, flds)};
        for j = 1:numel(idxs)
            uicontrol(parent, 'Style', 'edit', 'Max', 100, 'Min', 1, ...
                      'Units', 'normalized', 'Position', [(j-1)*tw,0,tw,1], ...
                      'HorizontalAlignment', 'left', ...
                      'String', pxp.records{idxs(j)}.(fld));
        end
    end
    function save2ws(w, val)
        si = w_tbl.UserData; % Nx2 selected ([row, col]) table indices
        if numel(si) < 1 && val < 3
            % the MenuSelectedData.InteractionInformation.Row*/Column* stuff is
            % only available in uifigures. This shouldn't be possible tho (with
            % these items being dis/enabled in tbl_sel_cb)
            warndlg('You have to actually select a cell before doing that.', ...
                    'Export selection warning', 'modal');
            return;
        end
        switch val
            case 1 % selected values
                dat = zeros(size(si, 1), 1);
                for j = 1:size(si, 1)
                    if si(j,1) > numel(w(si(j,2)).data); dat(j) = NaN;
                    else; dat(j) = w(si(j,2)).data(si(j,1));
                    end
                end
            case 2 % waves with selected values
                wi = unique(si(:,2));
                dat = repmat(w(wi(1)), 1, numel(wi));
                for j = 1:numel(wi); dat(j) = w(wi(j)); end
            case 3 % all waves
                dat = w;
            otherwise
                error('Unknown export type');
        end
        var_name = inputdlg({'Variable name to export wave data to:'}, ...
                            'Export settings', [1 40], ...
                            {'wave_data'}, struct('WindowStyle', 'modal'));
        if (isempty(var_name)); return; end % canceled by user
        try
            assignin('base', var_name{1}, dat);
        catch e
            errordlg(sprintf('Exporting wave(s) failed:\n%s', e.message), ...
                     'Export error', 'modal');
        end
    end
    function tbl_sel_cb(tbl, e)
        tbl.UserData = e.Indices;
        if size(e.Indices, 1) > 0
            set(tbl.ContextMenu.Children(2:end), 'Enable', 'on');
        else
            set(tbl.ContextMenu.Children(2:end), 'Enable', 'off');
        end
    end
    function m = cell2padded_mat(c, pad_v)
        % also converts to double and reshapes all numerics in the cells
        sz = cellfun(@numel, c);
        m = cell2mat(cellfun(@(x,ln) double([reshape(x,[],1); ones(ln,1).*pad_v]), ...
                             c, num2cell(max(sz)-sz), 'uni', false));
    end
end
