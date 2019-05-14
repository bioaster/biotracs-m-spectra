% BIOASTER
%> @file		ConsensusResult.m
%> @class		biotracs.spectra.sigproc.view.ConsensusResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date        2017

classdef ConsensusResult < biotracs.core.mvc.view.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        
        function h = viewPlot( this, varargin )
            p = inputParser();
            p.addParameter('SignalSetIndex', 1, @isnumeric);
            p.addParameter('SignalIndexes', [], @isnumeric);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            model = this.model;
            
            process = model.getProcess();
            inputSignalSet = process.getInputPortData('ResourceSet');
            if isa(inputSignalSet, 'biotracs.spectra.data.model.SignalSet')
                originalSpectrumSet = inputSignalSet;
                consensusSignal = model.get('ConsensusSignalSet').getAt(1);
            elseif isa(inputSignalSet, 'biotracs.core.mvc.model.ResourceSet')
                index = p.Results.SignalSetIndex(1);
                originalSpectrumSet = inputSignalSet.getAt(index);
                consensusSignal = model.get('ConsensusSignalSet').getAt(index);
            else
                error('Invalid input data');
            end
            
            h = originalSpectrumSet.view('Plot', 'PlotType', '2d', 'SubPlot', {2,1,1}, 'SignalIndexes', p.Results.SignalIndexes);
            ax1 = gca();

            consensusSignal.view('Plot', 'NewFigure', false, 'SubPlot', {2,1,2});
            ax2 = gca();
            linkaxes([ax1,ax2],'xy');
        end
        
    end
    
end
