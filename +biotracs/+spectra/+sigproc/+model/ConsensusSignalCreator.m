% BIOASTER
%> @file		ConsensusSignalCreator.m
%> @class		biotracs.spectra.sigproc.model.ConsensusSignalCreator
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef ConsensusSignalCreator < biotracs.core.mvc.model.Process
    
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
        function this = ConsensusSignalCreator()
            %#function biotracs.spectra.sigproc.model.ConsensusSignalCreatorConfig biotracs.core.mvc.model.ResourceSet biotracs.spectra.sigproc.model.ConsensusResult
            
            this@biotracs.core.mvc.model.Process();
            
            % define input and output specs
            this.addInputSpecs({...
                struct(...
                'name', 'ResourceSet',...
                'class', 'biotracs.core.mvc.model.ResourceSet' ...
                )...
                });
            
            % define input and output specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.spectra.sigproc.model.ConsensusResult' ...
                ) ...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doRun( this )
            signalSet = this.getInputPortData('ResourceSet');
            if isa(signalSet, 'biotracs.spectra.data.model.SignalSet')
                consensusSignals = cell(1,1);
                consensusStats = cell(1,1);
                [ consensusSignals{1}, consensusStats{1} ] = this.doRunSingle( signalSet );
                names = { signalSet.getLabel() };
            elseif isa(signalSet, 'biotracs.core.mvc.model.ResourceSet')
                n = getLength(signalSet);
                consensusSignals = cell(1,n);
                consensusStats = cell(1,n);
                for i=1:n
                    [ consensusSignals{i}, consensusStats{i} ] = this.doRunSingle( signalSet.getAt(i) );
                end
                names = signalSet.getElementNames();
            else
                error('Invalid data');
            end
            consensusSignalSet = biotracs.spectra.data.model.SignalSet();
            consensusSignalSet.setElements( consensusSignals, names );
            consensusStatSet = biotracs.core.mvc.model.ResourceSet();
            consensusStatSet.setElements( consensusStats, names );
            result = this.getOutputPortData('Result');
            result.set( 'ConsensusSignalSet', consensusSignalSet );
            result.set( 'ConsensusStatistics', consensusStatSet );
	
			this.setOutputPortData('Result', result);
        end
        
        function [ consensusSignal, consensusStats ] = doRunSingle( this, signalSet )
            method = this.config.getParamValue('Method');
            if ~signalSet.isResampled()
                error('The signal set is not resampled. Please resample the signal set before creating the consensus spectrum');
            end
            [consensusIdx, intensities] = signalSet.getSignalMatrix();
            if strcmpi(method,'mean')
                consensusInt = mean(intensities, 2);
                consensusStd = std(intensities, 0, 2);
                th = this.config.getParamValue('IntensityThreshold');
               
                idx = consensusInt > th;
                consensusIdx = consensusIdx(idx);
                consensusInt = consensusInt(idx);
                consensusStd = consensusStd(idx);
                
                consensusSignal = biotracs.spectra.data.model.Signal( [ consensusIdx, consensusInt ] );
                consensusSignal.setLabel( signalSet.getLabel() )...
                            .setColumnNames( {signalSet.getAt(1).getColumnName(1), ['Mean ', signalSet.getAt(1).getColumnName(2)]} )...
                            .updateParamValue('IsResampled', true);
                
                consensusStats = biotracs.data.model.DataMatrix([ consensusIdx, consensusStd ]);
                consensusStats.setLabel( signalSet.getLabel() )...
                            .setColumnNames( {signalSet.getAt(1).getColumnName(1), ['Std ', signalSet.getAt(1).getColumnName(2)]} );
            elseif strcmpi(method,'sum')
                consensusInt = sum(intensities, 2);
                consensusStd = std(intensities, 0, 2);
                th = this.config.getParamValue('IntensityThreshold');
               
                idx = consensusInt > th;
                consensusIdx = consensusIdx(idx);
                consensusInt = consensusInt(idx);
                consensusStd = consensusStd(idx);
                
                consensusSignal = biotracs.spectra.data.model.Signal( [ consensusIdx, consensusInt ] );
                consensusSignal.setLabel( signalSet.getLabel() )...
                            .setColumnNames( {signalSet.getAt(1).getColumnName(1), ['Sum ', signalSet.getAt(1).getColumnName(2)]} )...
                            .updateParamValue('IsResampled', true);
                
                consensusStats = biotracs.data.model.DataMatrix([ consensusIdx, consensusStd ]);
                consensusStats.setLabel( signalSet.getLabel() )...
                            .setColumnNames( {signalSet.getAt(1).getColumnName(1), ['Std ', signalSet.getAt(1).getColumnName(2)]} );
            else
                error('The method %s is unknown', method);
            end
        end
        
    end
end