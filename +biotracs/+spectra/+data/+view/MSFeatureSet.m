% BIOASTER
%> @file 		MSFeatureSet.m
%> @class 		biotracs.spectra.data.view.MSFeatureSet
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef MSFeatureSet < biotracs.data.view.DataSet
    
    properties(SetAccess = protected)      
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods

        function h = viewQcDriftPlot( this, varargin )
            p = inputParser();
            p.addParameter('FeatureIndexes', 1:4);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            featureMatrix = this.model;
            [ iQcFeatureSetContainer, ~ ] = featureMatrix.split();

            process = this.model.getProcess();
            if process.isNil()
                error('SPECTRA:FeatureSetView:NoProcessDefined','No process defined');
            end
            
            originalFeatureSet = process.getInputPortData('FeatureSet');
            [ iQcOriginalFeatureSetSetContainer, ~ ] = originalFeatureSet.split();

            nbBatches = getLength(iQcFeatureSetContainer);
            h = cell(1,nbBatches);
            for ii=1:nbBatches
                qcFeatureSet = iQcFeatureSetContainer.getAt(ii);
                qcOriginalFeatureSet = iQcOriginalFeatureSetSetContainer.getAt(ii);
                if hasEmptyData(qcFeatureSet) || hasEmptyData(qcOriginalFeatureSet)
                    break;
                end
                
                [qcSeqNum] = qcFeatureSet.getSequenceNumbers();
                [qcSeqNum, qcSeqIdx] = sort(qcSeqNum);
                qcFeatureSet = qcFeatureSet.selectByRowIndexes( qcSeqIdx );

                [qcOriginalSeqNum] = qcOriginalFeatureSet.getSequenceNumbers();
                [qcOriginalSeqNum, qcOriginalSeqIdx] = sort(qcOriginalSeqNum);
                qcOriginalFeatureSet = qcOriginalFeatureSet.selectByRowIndexes( qcOriginalSeqIdx );
                h{ii} = figure();
                qcOriginalFeatureSet.view(...
                    'DistributionPlot', ...
                    'Direction', 'row', ...
                    'LineStyle', '.-', ...
					'Color', 'b', ...
                    'ShowErrorBar', false, ...
                    'NewFigure', false, ...
                    'Subplot', {3,3,1});
                qcFeatureSet.view(...
                    'DistributionPlot', ...
                    'Direction', 'row', ...
                    'LineStyle', 'r.-', ...
					'Color', 'r', ...
                    'ShowErrorBar', false, ...
                    'NewFigure', false, ...
                    'Subplot', {3,3,1});
                hold on;
                legend({'Orig.','Corr.'});
                title(['Mean/Std, Batch ' num2str(ii)], 'FontSize', 8);
                set(gca, 'FontSize', 8);
                set(h{ii}, 'Unit', 'normalized', 'Position', [0.15 0.15 0.7 0.7]);
                
                [~,n] = getSize(qcFeatureSet); 
                for i=1:min(8,n)
                    if isempty(p.Results.FeatureIndexes) || i > length(p.Results.FeatureIndexes)
                        k = i;
                    else
                        k = p.Results.FeatureIndexes(i);
                    end
                    subplot(3,3,i+1);
                    
                    featureName = qcFeatureSet.getColumnName(k);
                    plot( qcOriginalSeqNum, qcOriginalFeatureSet.getDataByColumnName(['^',featureName,'$']), 'b.-' );
                    hold on;
                    plot( qcSeqNum, qcFeatureSet.data(:,k), 'r.-' );
                    xlim( [min(qcSeqNum), max(qcSeqNum)] );
                    grid;
                    featureName = regexprep(featureName, '(M\d+\.\d{1,3}).+_(T\d+\.\d{1,3}).+', '$1_$2');
                    title(strrep(featureName,'_','-'), 'FontSize', 8);
                    set(gca, 'FontSize', 8);
                end
            end
        end
        
        
        function h = viewFeatureCountPlot( this, varargin )
            p = inputParser();
            p.addParameter('LoQ', 0, @isnumeric);
            p.addParameter('Title', 'Feature counts', @ischar);
            p.addParameter('LabelFormat', 'long', @(x)(ischar(x) || iscell(x)));
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            featureMatrix = this.model;
            [m,~] = getSize(featureMatrix);
            labels = biotracs.core.utils.formatLabelForPlot( featureMatrix.rowNames, 'LabelFormat', p.Results.LabelFormat );
            [sortedLabels, idx] = sort(labels);
            featureMatrix = featureMatrix.selectByRowIndexes(idx);
            
            isDetected = featureMatrix.data > p.Results.LoQ;
            nbDetectedFeatures = sum(isDetected, 2);
            h = figure;
            plot(1:m, nbDetectedFeatures, '-.o' );
            ax = gca;
            ax.XTickLabel = sortedLabels;
            ax.XTickLabelRotation = 40;
            ax.XTick = 1:m;
            xlim([1,m]);
            yLim = ylim();
            ylim([0, yLim(2)]);
            ylabel('Number of features');
            title(p.Results.Title);
            set(gca, 'FontSize', 8);
        end
        
        
        function h = viewQcCvPlot( this, varargin )
            p = inputParser;
            p.addParameter('Title', 'Feature variability in QCs', @ischar);
            p.addParameter('NbBins', 25, @isnumeric);
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            featureMatrix = this.model;
            [ iQcFeatureSetContainer, ~ ] = featureMatrix.split();
            nbBatches = getLength(iQcFeatureSetContainer);
            %h = cell(1,nbBatches);
            h = figure;
            if nbBatches <= 4
                set(h, 'Unit', 'normalized', 'Position', [0.1807 0.2620 0.5667 0.4343]);
            else
                set(h, 'Unit', 'normalized', 'Position', [0.0187 0.0806 0.9490 0.8028]);
            end
            
            roundNbBatches = round(nbBatches/2);
            for ii=1:nbBatches
                subplot(roundNbBatches,round(nbBatches/roundNbBatches),ii);
                qcFeatureSet = iQcFeatureSetContainer.getAt(ii);
                qcStats = qcFeatureSet.varcoef();
                qcCv = qcStats.selectByRowName('^CV$');
                %  h{ii} = figure;
                histogram(qcCv.data, p.Results.NbBins, 'Normalization', 'probability');
                xlabel( ['CV, Batch ', num2str(ii)] );
                ylabel('Probability');
                title(p.Results.Title);
            end
        end
        
    end
end
