% BIOASTER
%> @file		Filter.m
%> @class		biotracs.spectra.sigproc.model.Filter
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef Filter < biotracs.core.mvc.model.Process
    
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
        function this = Filter()
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
        
        function doRun( this )
            signalSet = this.getInputPortData('SignalSet');
            [ filteredSignaleSet ] = this.doRunSingle( signalSet );
            filteredSignaleSet.setLabel(signalSet.getLabel());
            this.setOutputPortData('SignalSet', filteredSignaleSet );
        end
        
        function [ filteredSignalSet ] = doRunSingle( this, signalSet )
            tableOutputClass = class(signalSet);
            totalIntenistyRatio = this.config.getParamValue('MinTotalIntensityRatio');
            minIntenisty = this.config.getParamValue('MinIntensity');
            
            if totalIntenistyRatio == 1
                % remove all
                filteredSignalSet = feval( tableOutputClass );
            else
                indexesToRemove = [];
                
                if totalIntenistyRatio > 0
                    ti = signalSet.computeTotalIntensities();
                    maxInt = max( ti(:,2) );
                    indexesLowIntensitySignals = find(ti(:,2) < maxInt * totalIntenistyRatio);
                    indexesToRemove = [indexesLowIntensitySignals, this.config.getParamValue('SignalIndexesToRemove')];
                end

                idx = true( 1, signalSet.getLength() );
                idx( indexesToRemove ) = false;
                filteredSignalSet = feval( tableOutputClass );
                filteredSignalSet.setElements( signalSet.getAt(idx) );
                filteredSignalSet.discardProcess();

                if minIntenisty > 0
                    for i=1:getLength(filteredSignalSet)
                        idx = filteredSignalSet.getAt(i).data(:,2) < minIntenisty;
                        if ~isempty(idx)
                            data = filteredSignalSet.getAt(i).getData();
                            data(idx,2) = 0;
                            filteredSignalSet.getAt(i).setData( data );
                        end
                    end
                end
            end
        end
        
    end
end