function plot_waves(pxp, varargin)
% plots all waverecords in a struct created by pxp2mat.py. needs at least 2020b
% or around there.
    assert(isstruct(pxp) && isfield(pxp, 'records') && isfield(pxp, 'meta'), ...
           "pxps are structs with some fields and whatnot buddy");
    f = figure();
    spacing = "tight";
    if isMATLABReleaseOlderThan("R2021a"); spacing = "none"; end
    tl = tiledlayout(f, "flow", "TileSpacing", spacing, "Padding", spacing);
    for i = reshape(find(pxp.meta(:,1) == 'w'), 1, [])
        rec = pxp.records{i};
        if isstruct(rec) && isfield(rec, "type") && strcmp(rec.type, "wave")
            ah = nexttile(tl);
            plot(ah, rec.data, varargin{:});
            title(ah, rec.name, 'interpreter', 'none');
        end
    end
end
