% BIOASTER
%> @file		SignalSet.m
%> @class		biotracs.spectra.data.view.SignalSet
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef SignalSet < biotracs.core.mvc.view.BaseObject
    
    properties(SetAccess = protected)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        %-- D --
        
        % Show a dot plot of the spectrum set
        %> @param[in] varargin [optional] List of parameters used by the
        % msdotplot() function
        % 'Quantile' = 0.95 create a plot with only the 5% most intense peaks
        %> @see msdotplot()
        function h = viewDotPlot( this, varargin )
            pk = this.model.getSignalList();
            T = this.model.getSignalIndexes();
            h = msdotplot(pk, T, varargin{:});
            xlabel( this.model.getXAxisLabel() );
            ylabel( this.model.getYAxisLabel() );
            set(gca,'TickDir','out');
        end
        
        %-- H --
        
        % Show a heat map of the spectrum set
        %> @param[in] varargin [optional] List of parameters
        % + LogTransform = true|false, true to log2 transform data. This
        %       allow to lowered the intensity of highly intense peaks while
        %       preserving the information of the heat map
        % + Range (used for data resampling if required, used by
        % msheatmap() function) 
        % + NbSamples (used for data resampling if required)
        % + SamplingMultiplier (used for data resampling if required)
        % - For the other arguments see msheatmap() function
        %> @see msheatmap()
        function h = viewHeatMap( this, varargin )
            signals = this.getModel();
            p = inputParser;
            p.addParameter('LogTransform',false,@islogical);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if signals.isResampled()
                resampledSignals = signals;
            else
                disp('Resample signal set for heatmap');
                result = signals.resample( varargin{:} );
                resampledSignals = result.get('ResampledSignals');                
            end
            
            [MZ, Y] = resampledSignals.getSignalMatrix();
            
            %remove LogTransform from varargin
            index = biotracs.core.utils.cellfind( varargin, 'LogTransform' );
            if ~isempty(index)
                varargin([index(1), index(1)+1]) = [];
            end
            
            T = signals.getSignalIndexes();
            
            %remove unnecessary parameters
            %idx = biotracs.core.utils.cellfind(varargin, 'SamplingMultiplier|NbSamples');
			idx = biotracs.core.utils.cellfind(varargin, 'NbSamples');
            if ~isempty(idx)
                varargin([idx, idx+1]) = [];
            end

            if p.Results.LogTransform
                h = msheatmap(MZ, T, log2(Y), varargin{:});
            else
                h = msheatmap(MZ, T, Y, varargin{:});
            end
            set(gca,'TickDir','out');
            xlabel( signals.getXAxisLabel() );
            ylabel( signals.getYAxisLabel() );
        end
        
        %-- S --
        
        %-- P --

        % Plot spectrum in a 3D graph
        function h = viewPlot( this, varargin )
            p = inputParser();
            p.addParameter('PlotType', '3d', @(x)( any(strcmpi(x,{'2d','3d'})) ));
            p.addParameter('Normalize',false,@islogical);
			p.addParameter('Color','b',@(x)(ischar(x) || isnumeric(x)));
            p.addParameter('LineStyle','-',@ischar);
            p.addParameter('Marker','none',@ischar);
            p.addParameter('MarkerEdgeColor','auto',@(x)(ischar(x) || isnumeric(x)));
            p.addParameter('MarkerFaceColor','none',@(x)(ischar(x) || isnumeric(x)));
            p.addParameter('MarkerSize',6,@isnumeric);
            p.addParameter('SignalIndexes',[],@isnumeric);
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

            signalIndexes = p.Results.SignalIndexes;
            T = model.getSignalIndexes();
            if contains(style, '|')
                %style = strrep(style, '|', '');
                for i = 1:model.getLength()
                    if ~isempty(signalIndexes) && isempty(find(signalIndexes == i, 1)), continue; end
                    signal = model.getAt(i);
                    values = signal.data;
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
                for i = 1:model.getLength()
                    if ~isempty(signalIndexes) && isempty(find(signalIndexes == i, 1)), continue; end
                    signal = model.getAt(i);
                    values = signal.data;
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
            if strcmpi(p.Results.PlotType, '2d')
                ylabel( model.getZAxisLabel() );
            else
                ylabel( model.getYAxisLabel() );
                zlabel( model.getZAxisLabel() );
            end
            
            title( strrep(model.getLabel(), '_', '-') );
            grid on;
            set(gca,'TickDir','out');
        end
        
        %-- T --

        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)

        
    end
end
