% BIOASTER
%> @file 		SampleSplitter.m
%> @class 		biotracs.spectra.helper.SampleSplitter
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef SampleSplitter < handle
    
    properties(Constant)
    end
    
    properties(Dependent)
    end
    
    properties(SetAccess = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods(Static)
        
        
        function [ qcResult, sampleResult, otherResult ] = split( iFeatureSet, varargin )
            if ~isa(iFeatureSet, 'biotracs.spectra.data.model.MSFeatureSet')
                error('Invalid argument. Can only split ''biotracs.spectra.data.model.MSFeatureSet''');
            end
            
            pattern = iFeatureSet.getRowNameKeyValPatterns();
            batchPattern = pattern.BatchPattern;
            samplePattern = pattern.SamplePattern;
            qcPattern = pattern.QcPattern;
            % retrieve batch names
            batchIndexes = iFeatureSet.getBatchIndexes();
            % select QCs
            nbBatches = length(batchIndexes);
            qcFeatureSets = cell(1,nbBatches);
            for k = 1:nbBatches
                batchIndex = batchIndexes{k};
                currentBatchPattern = regexprep( batchPattern, '\(.*\)', ['(',batchIndex,'(_|$))'] );
                qcFeatureSets{k} = iFeatureSet.selectByRowName(qcPattern)...
                                            .selectByRowName(currentBatchPattern);
            end
            
            % select samples
            sampleFeatureSets = cell(1,nbBatches);
            for k=1:nbBatches
                batchIndex = batchIndexes{k};
                currentBatchPattern = regexprep( batchPattern, '\(.*\)', ['(',batchIndex,'(_|$))'] );
                sampleFeatureSets{k} = iFeatureSet.selectByRowName(samplePattern)...
                                                .selectByRowName(currentBatchPattern);                                            
            end
            
            % others
            otherFeatureSets = cell(1,nbBatches);
            for k=1:nbBatches
                batchIndex = batchIndexes{k};
                currentBatchPattern = regexprep( batchPattern, '\(.*\)', ['(',batchIndex,'(_|$))'] );
                [~, logQcIdx] = iFeatureSet.getRowIndexesByName( regexptranslate('escape', qcFeatureSets{k}.rowNames) );
                [~, logSampleIdx] = iFeatureSet.getRowIndexesByName( regexptranslate('escape', sampleFeatureSets{k}.rowNames) );
                otherIdx = ~(logQcIdx | logSampleIdx);
                otherFeatureSets{k} = iFeatureSet.selectByRowIndexes(otherIdx)...
                                                .selectByRowName(currentBatchPattern);
            end
            
            
%             % remove empty sets
%             idx = cellfun( @hasEmptyData, qcFeatureSets );
%             qcFeatureSets(idx) = [];
%             idx = cellfun( @hasEmptyData, sampleFeatureSets );
%             sampleFeatureSets(idx) = [];
%             idx = cellfun( @hasEmptyData, otherFeatureSets );
%             otherFeatureSets(idx) = [];
            
            % gather results in ResourceSet
            qcResult = biotracs.core.container.Set();
            sampleResult = biotracs.core.container.Set();
            otherResult = biotracs.core.container.Set();
           
            for i=1:length(sampleFeatureSets)
                sampleResult.set( ['Batch',num2str(i)], sampleFeatureSets{i} );
            end
            
            for i=1:length(qcFeatureSets)
                qcResult.set( ['Batch',num2str(i)], qcFeatureSets{i} );
            end
            
            for i=1:length(otherFeatureSets)
                otherResult.set( ['Batch',num2str(i)], otherFeatureSets{i} );
            end
        end
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = public)
    end
    
    
    methods(Access = protected)
    end
end
