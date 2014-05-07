% main_isocluststats
%
% Clustering result analysis

% requires
fidx;
% SubjectList;


initdata;

if (~exist('ClustType','var')),  ClustType = 'ISOCLUST'; end;

if (~exist('DoSave', 'var')), DoSave = true; end;   % save result

fidxel = fb_getelements(fidx);
if (~exist('SimSetID','var')), SimSetID = [SubjectList{1} fidxel{2:end}]; end;

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

filename = dbfilename(Repository, 'prefix', ClustType, 'suffix', SimSetID, 'subdir', 'ISO');
load(filename, 'ClusteringResults', 'seglist', 'Classlist', 'Partlist');

if (~exist('plotvisible','var')),  plotvisible = 'off'; end;
fh = figure('visible', plotvisible);


switch lower(ClusteringMethod)
	case 'hierarchical'
		fprintf('\n%s: Compute dendrogram...', mfilename);
		if (~exist('colorthreshold','var')),  colorthreshold = 7; end;
		if (~exist('leaves','var')),  leaves = 20; end;
		[H,T] = dendrogram(ClusteringResults.link, leaves, 'colorthreshold', colorthreshold, 'orientation', 'right');
		% plotfmt(fh, 'prfig', 'dendrogram.fig');
		% hgload dendrogram.fig

		%rows = 10;
		%hfh = figure; subplot(3,6,1);
		allclasses = unique(seglist(:,4))';
		classassoc = zeros(1,length(unique(T)));  bestratio = zeros(1,length(unique(T)));
		xtlstring = cell(1,length(unique(T)));
		for stumb = 1:length(unique(T))
			%sh = subplot(rows,round(length(unique(T))/rows), stumb);
			h = hist(seglist((T==stumb), 4), 1:length(allclasses));
			%bar(h); title(['stumb=' int2str(stumb)]);
			[dummy classassoc(stumb)] = max(h);
			bestratio(stumb) = h(classassoc(stumb)) / sum(h);
			xtlstring{stumb} = [ Classlist{classassoc(stumb)}(3:end) ' (' num2str(bestratio(stumb)*100, '%2.0f%%') ')' ];
		end;
		%plotfmt(fh, 'xtl', classassoc);
		%th = plotfmt(fh, 'extl90', Classlist(classassoc));
		% th = plotfmt(fh, 'extl90', xtlstring, 'yl', 'Eclidean distance');
		fpos = str2num(get(gca, 'YTickLabel'));
		th = plotfmt(fh, 'ytl', xtlstring(fpos), 'xl', 'Euclidean distance');
		if (DoSave)
			fprintf('\n%s:   Save %s...', mfilename, filename);
			filename = dbfilename(Repository, 'prefix', SimSetID, 'suffix', 'dendrogram', 'subdir', 'EVAL', 'extension', 'pdf');
			plotfmt(fh, 'prpdf', filename);
			fprintf('done.\n');
		end;
		fprintf('\n%s: Not covered classes: %s', mfilename, mat2str(allclasses(~findn(allclasses, unique(classassoc), 'eq'))));

		% identify PI
		partoffsets = cla_getpartsize(Repository, Partlist, 'OffsetMode', true);
		PIs = cell(1,length(unique(T)));
		for stumb = 1:length(unique(T))
			PIs{stumb} = Partlist(repos_findpartfromlabels(seglist((T==stumb), :), partoffsets));
		end;
		for stumb = length(unique(T)):-1:1
			fprintf('\n%s: Hive: %s (%2u)  PIs: %s', mfilename, xtlstring{fpos(stumb)}, fpos(stumb), cell2str(PIs(fpos(stumb))));
		end;
		fprintf('\n');

		
		
	case 'som'
		
		sH = som_show(ClusteringResults.sM, 'umat', 'all', 'bar', 'none', 'footnote', '');
		plotfmt(fh, 'ti', '');

		%ClusteringResults.sM = som_autolabel(ClusteringResults.sM, ClusteringResults.sD);
		%som_show_add('label',ClusteringResults.sM,'Textsize',8,'TextColor','r');
		
		%som_show(ClusteringResults.sM,'umat','all','empty','Labels');
		%som_show_add('label',ClusteringResults.sM,'Textsize',8,'TextColor','r','Subplot',2)
		
		cmap = autumn(length(thisTargetClasses));
		h = cell(1,length(thisTargetClasses));
		for class = 1:length(thisTargetClasses)
			h{class} = som_hits(ClusteringResults.sM, ClusteringResults.sD.data(seglist(:,4)==class,:));
			som_show_add('hit', h{class}, 'MarkerColor', cmap(class,:));
		end;
		
		%som_show_clear(h);
% 		h2 = som_hits(sMap,sDiris.data(51:100,:));
% 		h3 = som_hits(sMap,sDiris.data(101:150,:));
% 		som_show_add('hit',[h1, h2, h3],'MarkerColor',[1 0 0; 0 1 0; 0 0 1],'Subplot',1)

		if (SOM3DPlot)
			%     - A surface plot of distance matrix: both color and
			%       z-coordinate indicate average distance to neighboring
			%       map units. This is closely related to the U-matrix.
			Co=som_unit_coords(ClusteringResults.sM);
			U=som_umat(ClusteringResults.sM); U=U(1:2:size(U,1),1:2:size(U,2));
			som_grid(ClusteringResults.sM,'Coord',[Co, U(:)],'Surf',U(:),'Marker','none');
			view(-80,45), axis tight, title('Distance matrix')
		end;

		if (SOMCluster)
			[ClusteringResults.c,ClusteringResults.p,ClusteringResults.err,ClusteringResults.ind] = ...
				kmeans_clusters(ClusteringResults.sM, 20); % find at most 7 clusters
			%som_cplane(sM,Code,Dm)
			som_cplane(ClusteringResults.sM, ClusteringResults.p{end});
			figure; hist((ClusteringResults.p{end}), unique(ClusteringResults.p{end}));
		end;
		
		if (DoSave)
			fprintf('\n%s:   Save %s...', mfilename, filename);
			filename = dbfilename(Repository, 'prefix', SimSetID, 'suffix', 'umatrix', 'subdir', 'EVAL', 'extension', 'pdf');
			plotfmt(fh, 'prpdf', filename);
			fprintf('done.\n');
		end;

		
end; % switch lower(ClusteringMethod)
