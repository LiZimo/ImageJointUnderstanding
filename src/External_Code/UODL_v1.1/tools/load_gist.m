

function gist_feat = load_gist(img_path)

load([ img_path(1:end-4), '_gist.mat' ], 'gist_feat');