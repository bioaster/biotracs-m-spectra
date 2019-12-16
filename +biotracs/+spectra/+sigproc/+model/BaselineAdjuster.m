% BIOASTER
%> @file		Aligner.m
%> @class		biotracs.spectra.sigproc.model.BaselineAdjuster
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef BaselineAdjuster < biotracs.core.mvc.model.Process
    
    properties(Constant)
    end
    
    properties(Dependent)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaselineAdjuster()
            %#function biotracs.spectra.sigproc.model.BaselineAdjusterConfig biotracs.spectra.data.model.SignalSet
            
            this@biotracs.core.mvc.model.Process();
            
            % define input and output specs
            this.addInputSpecs({...
                struct(...
                    'name', 'SignalSet',...
                    'class', 'biotracs.spectra.data.model.SignalSet' ...
                )...
            });
        
            % define input and output specs
            this.addOutputSpecs({...
                struct(...
                    'name', 'SignalSet',...
                    'class', 'biotracs.spectra.data.model.SignalSet' ...
                )...
            });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doPass( this )
            this.doPass@biotracs.core.mvc.model.Process();
            %Bind the correct view if phantom mode is activated
            adjustedSignalSet = this.getOutputPortData('SignalSet');   
            adjustedSignalSet.bindView( biotracs.spectra.sigproc.view.BaselineAdjustmentSignalSet() );
        end
        
        function doRun( this )
            signals = this.getInputPortData('SignalSet');
            tableOutputClass = class(signals);

            %try to resample signals
            if ~signals.isResampled
                error('SPECTRA:BaselineAdjuster:ResampledSignalsRequired', 'The signals must be resampled before baseline adjustment');
            end
            [X, Intensities] = signals.getSignalMatrix();
            
            %baseline correction
            
            wsz = this.config.getParamValue('WindowSize');
            ssz = this.config.getParamValue('StepSize');
            %fprintf('Baseline correction with WindowSize = 0.1, StepSize = 0.1\n');
            Intensities = msbackadj(X,Intensities,'WindowSize', wsz, 'StepSize', ssz, 'PreserveHeights', true);
            
            transform = this.config.getParamValue('NegativeValueTransform');
            if strcmp(transform,'Absolute')
                Intensities = abs(Intensities);
            elseif strcmp(transform,'Zero')
                Intensities (Intensities < 0) = 0;
            end
            
            adjustedSignalSet = this.doBuildAdjustedSignalSet( X, Intensities, tableOutputClass );
            adjustedSignalSet.bindView( biotracs.spectra.sigproc.view.BaselineAdjustmentSignalSet() );
            this.setOutputPortData('SignalSet',adjustedSignalSet);            
        end
       
        function [ adjustedSignalSet ] = doBuildAdjustedSignalSet( this, X, Intensities, tableOutputClass )
            signals = this.getInputPortData('SignalSet');
 
            adjustedSignalSet = feval(tableOutputClass);
            classOfElements = adjustedSignalSet.getClassNameOfElements();
            
            adjustedSignalSet.setLabel( signals.getLabel() )...
                .setDescription('Adjusted signals')...
                .updateParamValue('XAxisLabel', signals.getXAxisLabel())...
                .updateParamValue('YAxisLabel', signals.getYAxisLabel())...
                .updateParamValue('ZAxisLabel', signals.getZAxisLabel());
            
            for i=1:size(Intensities,2)
                signal = feval(classOfElements{1}, [X, Intensities(:,i)] );
                signal.setLabel( signals.getAt(i).getLabel() )...
                    .setColumnNames( signals.getAt(1).getColumnNames() )...
                    .updateParamValue('IsResampled', true);
                adjustedSignalSet.add( signal, signals.getElementName(i) );
            end
            adjustedSignalSet.setSignalIndexes( signals.signalIndexes  );
        end
        
    end
end