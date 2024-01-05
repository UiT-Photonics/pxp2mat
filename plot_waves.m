function plot_waves(pxp)
% plots all waverecords in a struct created by pxp2mat.py. needs at least 2020b
% or around there.
    assert(isstruct(pxp), "pxps are structs buddy");
    waves = [];
    flds = reshape(fieldnames(pxp), 1, []);
    for i = 1:length(flds)
        fld = flds{i};
        if isstruct(pxp.(fld)) && isfield(pxp.(fld), "type") && ...
                strcmp(pxp.(fld).type, "wave")
            waves(end+1) = i; %#ok<AGROW> i'm ok with it.
        end
    end
    f = figure();
    spacing = "tight";
    if isMATLABReleaseOlderThan("R2021a"); spacing = "none"; end
    tl = tiledlayout(f, "flow", "TileSpacing", spacing, "Padding", spacing);
    for i = 1:length(waves)
        ah = nexttile(tl);
        plot(ah, pxp.(flds{waves(i)}).data);
        title(ah, flds{waves(i)}, 'interpreter', 'none');
    end
end
