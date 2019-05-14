% BIOASTER
%> @file		MSSpectrumMap.m
%> @class		biotracs.spectra.data.view.MSSpectrumMap
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef MSSpectrumMap < biotracs.core.mvc.view.Resource
    
    properties(SetAccess = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        %-- D --
 
        %-- V --

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
        
        % Plot spectrum in a 3D graph
        function h = viewPlot( this, varargin )
            p = inputParser();
            p.addParameter('PlotType','3d',@ischar);
            p.addParameter('Normalize',false,@islogical);
            p.addParameter('Color','b',@(x)(ischar(x) || isnumeric(x)));
            p.addParameter('LineStyle','-',@ischar);
            p.addParameter('Marker','none',@ischar);
            p.addParameter('MarkerEdgeColor','auto',@(x)(ischar(x) || isnumeric(x)));
            p.addParameter('MarkerFaceColor','none',@(x)(ischar(x) || isnumeric(x)));
            p.addParameter('MarkerSize',6,@isnumeric);
            p.KeepUnmatched = true;
            p.parse(varargin{:});

            h = this.doPrepareFigure( varargin{:} );
            
            model = this.getModel();
            if model.isCentroided
                isStem = ~isempty(strfind(p.Results.LineStyle, '|'));
                if isStem
                    style = p.Results.LineStyle;
                else
                    style = [p.Results.LineStyle, '|'];
                end
            else
                style = p.Results.LineStyle;
            end

            T = model.getRetentionTimes();
            n = model.getScanCount();
            if contains(style, '|')
                %style = strrep(style, '|', '');
                for i = 1:n
                    values = model.data{i};
                    if p.Results.Normalize
                        values(:,2) = values(:,2) / max(values(:,2));
                    end
                    nbPeaks = numel( values(:,1) );
                    if strcmpi(p.Results.PlotType, '2d')
                        stem(...
                            values(:,1),...
                            values(:,2),...
                            'Marker', p.Results.Marker, ...
                            'Color', p.Results.Color, ...
                            'MarkerFaceColor', p.Results.MarkerFaceColor, ...
                            'MarkerEdgeColor', p.Results.MarkerEdgeColor, ...
                            'MarkerSize', p.Results.MarkerSize ...
                            );
                    else
                        stem3(...
                            values(:,1),...
                            T(i)*ones(1,nbPeaks),...
                            values(:,2),...
                            'Marker', p.Results.Marker, ...
                            'Color', p.Results.Color, ...
                            'MarkerFaceColor', p.Results.MarkerFaceColor, ...
                            'MarkerEdgeColor', p.Results.MarkerEdgeColor, ...
                            'MarkerSize', p.Results.MarkerSize ...
                            );
                    end
                    hold on;
                end
            else
                for i = 1:n
                    if p.Results.Normalize
                        values(:,2) = values(:,2) / max(values(:,2));
                    end
                    nbPeaks = numel( values(:,1) );
                    if strcmpi(p.Results.PlotType, '2d')
                        plot(...
                            values(:,1),...
                            values(:,2),...
                            'LineStyle', p.Results.LineStyle, ...
                            'Color', p.Results.Color, ...
                            'Marker', p.Results.Marker, ...
                            'MarkerFaceColor', p.Results.MarkerFaceColor, ...
                            'MarkerEdgeColor', p.Results.MarkerEdgeColor, ...
                            'MarkerSize', p.Results.MarkerSize ...
                            );
                    else
                        plot3(...
                            values(:,1),...
                            T(i)*ones(1,nbPeaks),...
                            values(:,2),...
                            'LineStyle', p.Results.LineStyle, ...
                            'Color', p.Results.Color, ...
                            'Marker', p.Results.Marker, ...
                            'MarkerFaceColor', p.Results.MarkerFaceColor, ...
                            'MarkerEdgeColor', p.Results.MarkerEdgeColor, ...
                            'MarkerSize', p.Results.MarkerSize ...
                            );
                    end
                    hold on;
                end
            end
            
            xlabel( model.getXAxisLabel() );
            if strcmpi(p.Results.PlotType, '1d')
                ylabel( model.getZAxisLabel() );
            else
                ylabel( model.getYAxisLabel() );
                zlabel( model.getZAxisLabel() );
            end
            
            title( strrep(model.getLabel(), '_', '-') );
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
