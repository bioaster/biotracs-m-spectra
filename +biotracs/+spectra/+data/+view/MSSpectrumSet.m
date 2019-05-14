% BIOASTER
%> @file		MSSpectrumSet.m
%> @class		biotracs.spectra.data.view.MSSpectrumSet
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef MSSpectrumSet < biotracs.spectra.data.view.SignalSet
    
    properties(SetAccess = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        %-- D --
 
        %-- P --
        
        function h = viewPlot( this, varargin )
            h = this.viewPlot@biotracs.spectra.data.view.SignalSet( varargin{:} );
            
            p = inputParser();
            p.addParameter('PlotType','3d',@ischar);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if strcmpi(p.Results.PlotType, '3d')
                xLim = xlim();
                mzLim = xLim(2) - xLim(1);
                if mzLim < 5
                    xlim( [xLim(1)-5, xLim(2)+5] );
                end
            end
        end
        
        %-- T --

        function h = viewTicPlot( this, varargin )
            
            h = this.doPrepareFigure( varargin{:} );
            
            ti = this.model.computeTotalIonCurrent();
            plot( ti(:,1), ti(:,2), 'b', 'LineWidth', 1.5 );
            xlabel( strrep(this.model.getYAxisLabel(), '_', '-') );
            ylabel( 'TIC' );
            title( strrep(this.model.getLabel(), '_', '-') );
            grid on;
            set(gca,'TickDir','out');            
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)

    end
end
