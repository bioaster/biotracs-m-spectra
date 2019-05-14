% BIOASTER
%> @file		PeakPicker.m
%> @class		biotracs.spectra.sigproc.model.PeakPicker
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef PeakPicker < biotracs.core.mvc.model.Process
    
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
        function this = PeakPicker()
            this@biotracs.core.mvc.model.Process();
            
            % define input and output specs
            this.addInputSpecs({...
                struct(...
                'name', 'SignalSet',...
                'class', {{'biotracs.spectra.data.model.Signal','biotracs.spectra.data.model.SignalSet'}} ...
                )...
                });
            
            % define input and output specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.spectra.sigproc.model.PeakPickingResult' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doBeforeRun( this )
            this.doBeforeRun@biotracs.core.mvc.model.Process();
            signals = this.getInputPortData('SignalSet');
            this.setIsPhantom( signals.isCentroided() );
        end
        
        function doRun( this )
            signals = this.getInputPortData('SignalSet');
            result = this.getOutputPortData('Result');
            % peak picking ...
            if isa( signals, 'biotracs.spectra.data.model.Signal' )
                tableOutputClass = class(signals);
                peaksData = mspeaks( signals.data(:,1), signals.data(:,2) );
                centroidedSignal = feval(tableOutputClass, peaksData);
                centroidedSignal.setLabel(signals.label)...
                    .setColumnNames( signals.getColumnNames() )...
                    .setDescription('Signal centroided using peak picking')...
                    .updateParamValue('Representation', biotracs.spectra.data.model.Signal.REPRESENTATION_CENTROID );
                result.set('CentroidedSignals', centroidedSignal);
            elseif isa( signals, 'biotracs.spectra.data.model.SignalSet' )
                n = signals.getLength();
                tableOutputClass = class(signals);
                centroidedSignalSet = feval(tableOutputClass);
                for i=1:n
                    peaksData = mspeaks( signals.getAt(i).data(:,1), signals.getAt(i).data(:,2) );
                    classOfElements = class(signals.getAt(i));
                    centroidedSignal = feval( classOfElements, peaksData );
                    centroidedSignal.setLabel(signals.getAt(i).label)...
                        .setColumnNames( signals.getAt(i).getColumnNames() )...
                        .setDescription('Signal centroided using peak picking')...
                        .updateParamValue('Representation', biotracs.spectra.data.model.Signal.REPRESENTATION_CENTROID );
                    centroidedSignalSet.add( centroidedSignal, signals.getElementName(i) );
                end
                centroidedSignalSet.setLabel(signals.getLabel())...
                    .setSignalIndexes( signals.signalIndexes  );
                result.set('CentroidedSignals', centroidedSignalSet);
            end
			
			this.setOutputPortData('Result', result);
        end
        
        %-- P --
        
        function doPass( this )
           disp('The signals are already centroided. Pass the the data to the output');
           signals = this.getInputPortData('SignalSet');
           result = this.getOutputPortData('Result');
           result.set('CentroidedSignals', signals);
		   
		   this.setInputPortData('SignalSet', signals);
        end
        
    end
end