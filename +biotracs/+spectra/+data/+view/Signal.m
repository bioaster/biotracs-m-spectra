% BIOASTER
%> @file		Signal.m
%> @class		biotracs.spectra.data.view.Signal
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef Signal < biotracs.data.view.DataMatrix
    
    properties(SetAccess = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        %-- P --
        
        % Plot a signal in a 2D graph
        function h = viewPlot( this, varargin )
            p = inputParser();
            p.addParameter('TopMostIntenses', 0, @isnumeric);
            p.addParameter('Normalize', false, @islogical);
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            if this.model.isCentroided()
                idx = biotracs.core.utils.cellfind(varargin, 'LineStyle', true);
                if isempty(idx)
                    varargin = [varargin, {'LineStyle', '|'}];
                %else
                %    varargin{idx+1} = [varargin{idx+1}, '|'];
                end
            end
            
            
            h = this.viewPlot@biotracs.data.view.DataMatrix( varargin{:} );
            
            %view most intenses (only in centroid mode)
            if this.model.isCentroided() && p.Results.TopMostIntenses > 0
                %data = this.model.data(:,2);
                [sortedData, sortedDataIndexes] = sort(this.model.data(:,2),'descend');
                n = min(p.Results.TopMostIntenses, length(sortedData));
                if n == 0
                    return;
                end
                filteredIdx = sortedDataIndexes(1:n);   %take the first 30
                d = this.model.data(filteredIdx,:);
                hold on;
                
                if p.Results.Normalize
                    maxY = max( abs(this.model.data(:,2)) );
                    d(:,2) = d(:,2)/maxY(1);
                end
                
                plot(d(:,1),d(:,2),'+r');
                for k=1:length(d(:,2))
                    text( double(d(k,1)), double(d(k,2)), num2str(d(k,1)), 'FontSize',8 );
                end
            end
        end
        
    end
    
end
