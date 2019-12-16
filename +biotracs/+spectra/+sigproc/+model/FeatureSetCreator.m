% BIOASTER
%> @file		FeatureSetCreator.m
%> @class		biotracs.spectra.sigproc.model.FeatureSetCreator
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef FeatureSetCreator < biotracs.core.mvc.model.Process
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = FeatureSetCreator()
            %#function biotracs.spectra.sigproc.model.FeatureSetCreatorConfig biotracs.spectra.data.model.SignalSet biotracs.data.model.DataSet
            
            this@biotracs.core.mvc.model.Process();
            
            % enhance inputs specs
            this.addInputSpecs({...
                struct(...
                'name', 'SignalSet',...
                'class', 'biotracs.spectra.data.model.SignalSet' ...
                )...
                });
            
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'FeatureSet',...
                'class', 'biotracs.data.model.DataSet' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)

        function doRun( this )
            signalSet = this.getInputPortData('SignalSet');
            if ~signalSet.isResampled()
                error('The signal set is not resampled. Please, resample the signal set before.');
            end
            
            tableOutputClass = this.config.getParamValue('TableClass');
            featureSet = feval(...
                [tableOutputClass, '.fromDataObject'], ...
                signalSet.toDataSet() ...
                );
            
            % remove ranges
            t = signalSet.getAt(1).data(:,1)';
            intervalsToRemove = this.config.getParamValue('IntervalsToRemove');
            n = length(t);
            selectedIndexes = true(1,n);
            nbIntervals = size(intervalsToRemove,1);
            for i=1:nbIntervals
                int = intervalsToRemove(i,:);
                removedIdx = (t > int(1) & t < int(2));
                selectedIndexes = selectedIndexes & ~removedIdx;
                biotracs.core.env.Env.writeLog('\t > %d variables removed using interval [%g, %g]', sum(removedIdx), int(1), int(2));
            end
            
            % remove variables with all values < IntensityThreshold
            intensityThreshold = this.config.getParamValue('IntensityThreshold');
            if ~isempty(intensityThreshold)
                removedIdx = all(featureSet.data < intensityThreshold, 1);
                selectedIndexes = selectedIndexes & ~removedIdx;
                biotracs.core.env.Env.writeLog('\t > %d variables have intensity < %g and were removed', sum(removedIdx), intensityThreshold);
            end
                
            % remove zero-variance variables
            hasToRemoveZeroVarianceVariables = this.config.getParamValue('RemoveZeroVarianceVariables');
            if hasToRemoveZeroVarianceVariables
                dataStd = std(featureSet.data,0,1);
                removedIdx = (dataStd == 0);
                selectedIndexes = selectedIndexes & ~removedIdx;
                biotracs.core.env.Env.writeLog('\t > %d zero-variance variables removed', sum(removedIdx));
            end
            
            if ~all(selectedIndexes)
                nbInitialVar = getSize(featureSet,2);
                featureSet = featureSet.selectByColumnIndexes(selectedIndexes);
                nbRemainingVar = getSize(featureSet,2);
                biotracs.core.env.Env.writeLog('\t > remaining %d (i.e. %1.1f%%) variables over %d', nbRemainingVar, 100*nbRemainingVar/nbInitialVar, nbInitialVar );
            end

            this.setOutputPortData('FeatureSet', featureSet);
        end
        
    end
    
end
