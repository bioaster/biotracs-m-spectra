% BIOASTER
%> @file		Binner.m
%> @class		biotracs.spectra.sigproc.helper.Binner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef Binner < biotracs.core.helper.Helper
    
    properties
    end
    
    methods(Static)

        function [mzBins] = computeMzBins( iSpectrum, varargin )
            p = inputParser();
            p.addParameter('Method', 'gaussian', @ischar);	% uniform or gaussian
            p.addParameter('BinWidth', 0, @isdouble);           % default = 0
            p.parse( varargin{:} );
            
%             if strcmp(p.Results.Method, 'uniform')
%                 binValues
%                 for i=1:iSpectrum.getNbRow()
%                     
%                 end
%             elseif strcmp(p.Results.Method, 'gaussian')
%                 
%             end
            
        end
         
        function [ binIndexes, binFeatures, binFeaturesStat ] = computeRetentionTimeBins( iSpectrumSet, varargin )
            p = inputParser();
            p.addParameter('Method', 'hca', @ischar);
            p.addParameter('MaxNbBins', 10, @isnumeric);
            p.addParameter('CenterData', false, @islogical);
            p.addParameter('ScaleData', false, @islogical);
            p.addParameter('LogTransform', false, @islogical);
            p.parse( varargin{:} );
            
            % Create the correlation matrix
            %[resampledMZ, resampledSignals, ~] = iSpectrumSet.resampleSignals();
            
            alignmentResult = iSpectrumSet.resample();
            s = alignmentResult.get('ResampledSignals');
            [resampledMZ, resampledSignals] = s.getSignalMatrix();

            C = corr(resampledSignals);
            dataSet = biotracs.data.model.DataSet(C);
            dataSet.setRowNames('s');
            dataSet.setColumnNames('s');
            
            % Clustering analysis to compute clusters
            if strcmp(p.Results.Method, 'uniform')
                %binLength = p.Results.BinLength;
                error('Not yet implemented!');
            elseif strcmp(p.Results.Method, 'hca')
                clustController = biotracs.atlas.hca.controller.Controller();
                clustController.updateParamValue('Method', p.Results.Method);
                clustController.updateParamValue('LogTransform', p.Results.LogTransform);
                clustController.updateParamValue('MaxNbClusters', p.Results.MaxNbBins);
                clustController.updateParamValue('Center', p.Results.CenterData);
                scale = 'none';
                if p.Results.ScaleData
                    scale = 'uv';
                end
                clustController.updateParamValue('Scale', scale);
                clustController.addResource( dataSet );
                clustController.runAnalysis();
            end
            clustResult = clustController.getClusteringResult();
            
            binIndexes = biotracs.spectra.sigproc.helper.Binner.computeBinIndexes( clustResult );
            [ binFeatures, binFeaturesStat ] = biotracs.spectra.sigproc.helper.Binner.computeBinFeatures( ...
                binIndexes, ...
                resampledMZ, ...
                resampledSignals, ...
                iSpectrumSet.getRetentionTimes() ...
            );
        end
        
        
        function [ binIndexes ] = computeBinIndexes( iClustResult )
            classes = iClustResult.get('InstanceClasses').getData();
            nbBinSeparators = iClustResult.getNumberOfInstanceClasses() + 1;
            bins = zeros(nbBinSeparators, 1);
            currentClassIndex = classes(1);
            bins(1) = 1;
            bins(end) = length(classes);
            j = 2;
            for i=2:length(classes)
                if currentClassIndex ~= classes(i)
                    bins(j) = i-1;
                    currentClassIndex = classes(i);
                    j = j + 1;
                end
            end
            binIndexes = biotracs.data.model.DataMatrix( bins );
        end
        
        
        function [ binFeatures, binFeaturesStat ] = computeBinFeatures( iBinIndexes, iResampledMZ, iResampledSignals, iRetentionTimes )            
            n = iBinIndexes.getLength() - 1;
            binFeatures = biotracs.spectra.data.model.MSSpectrumSet();
            
            for i=1:n
                if i == 1
                    lbIndex = iBinIndexes.data(i);
                else
                    lbIndex = iBinIndexes.data(i) + 1;  %exclude last spectrum
                end
                ubIndex = iBinIndexes.data(i+1);
                
                %create the average spectrum in the bin
                meanValues = mean( iResampledSignals(:,lbIndex:ubIndex), 2 );
                stdValues = std( iResampledSignals(:,lbIndex:ubIndex), 0, 2 );
                meanRetentionTime = mean( iRetentionTimes(lbIndex:ubIndex) );
                
                meanSpectrum = biotracs.spectra.data.model.MSSpectrum( [iResampledMZ, meanValues], meanRetentionTime);
                binFeatures.add( meanSpectrum );
            end
            
            binFeaturesStat = biotracs.data.model.DataMatrix( stdValues );
        end
        
    end
    
end

