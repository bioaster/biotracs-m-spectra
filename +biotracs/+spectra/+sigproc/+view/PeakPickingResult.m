% BIOASTER
%> @file		PeakPickingResult.m
%> @class		biotracs.spectra.sigproc.view.PeakPickingResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date        2017

classdef PeakPickingResult < biotracs.core.mvc.view.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        function h = viewPlot( this, varargin )
            p = inputParser();
            p.addParameter('SignalIndexes', [], @isnumeric);
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            model = this.getModel();
            e = model.getProcess();
            
            originalSignalSet = e.getInputPortData('SignalSet');
            centroidedSignalSet = model.get('CentroidedSignals');
            
            indexes = p.Results.SignalIndexes;
            
            if isempty( indexes )
                if isa(originalSignalSet, 'biotracs.spectra.data.model.SignalSet') && getLength(originalSignalSet) == 1
                    h = originalSignalSet.view('Plot', 'PlotType', '2d');
                    centroidedSignalSet.view(...
                        'Plot', ...
                        'PlotType', '2d', ...
                        'NewFigure', false, ...
						'Color', 'r', ...
                        'Title', 'Peak picking'...
                        );
                else
                    h = originalSignalSet.view('Plot', varargin{:});
                    centroidedSignalSet.view(...
                        'Plot', ...
                        'NewFigure', false, ...
                        'Color', 'r', ...
                        'Title', 'Peak picking'...
                        );
                end
            else
                n = length( indexes );
                h = cell(1,n);
                for i=1:n
                    idx = indexes(i);
                    h{i} = originalSignalSet.getAt(idx).view('Plot', varargin{:});
                    centroidedSignalSet.getAt(idx).view(...
                        'Plot', ...
                        'NewFigure', false, ...
                        'Color', 'r', ...
                        'Title', 'Peak picking'...
                        );
                end
            end
        end
        
    end
    
end
