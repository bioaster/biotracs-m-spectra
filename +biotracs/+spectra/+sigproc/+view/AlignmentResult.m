% BIOASTER
%> @file		AlignmentResult.m
%> @class		biotracs.spectra.sigproc.view.AlignmentResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date         2015

classdef AlignmentResult < biotracs.core.mvc.view.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        function h = viewPlot( this, varargin )
            %p = inputParser();
            %p.addParameter('SignalIndexes',[],@isnumeric);
            %p.KeepUnmatched = true;
            %p.parse(varargin{:});

            model = this.getModel();
            if model.getProcess().isPhantom
                biotracs.core.env.Env.writeLog('%s','Cannot view plot. No alignement was performed becasue the Process was phantom');
                return;
            end
            
            originalResampledSignalSet = model.getProcess().getInputPortData('SignalSet'); %get('ResampledSignals');
            alignedSignalSet = model.get('AlignedSignalSet');
            intervalsDataMatrix = model.get('AlignmentIntervalIndexes');
            %shiftsDataMatrix = model.get('AlignmentShifts');
            targetSignal = model.get('TargetSignal');
            
            h = figure;
            
            % plot original (resampled) signals
            ax1 = subplot(2,1,1); hold on;
            lineNames = originalResampledSignalSet.getElementNames();
            
            %if ~isempty(p.Results.SignalIndexes)
            %    signalIndexes = p.Results.SignalIndexes;
            %    nbSignals = 1:length(signalIndexes);
            %else
                nbSignals = length(lineNames);
                signalIndexes = 1:nbSignals;
            %end
            
            for i=1:nbSignals
                s = originalResampledSignalSet.getAt(signalIndexes(i));
                plot(s.data(:,1), s.data(:,2));
                ax = gca();
                line = ax.Children(1);
                line.Tag = lineNames{signalIndexes(i)};
            end

            % plot average
            hold on
            ph = plot(targetSignal.data(:,1), targetSignal.data(:,2), 'r-', 'LineWidth', 2);
            
            yl = ylim();
            for i=1:intervalsDataMatrix.getNbRows()
                idx = intervalsDataMatrix.data(i,2:3);
                int = originalResampledSignalSet.getAt(1).data(idx,1);
                plot( int([1,1]), yl, 'm-.', 'LineWidth', 1);
                plot( int([2,2]), yl, 'm-.', 'LineWidth', 1);
            end
            
            grid on;
            title('Original (resampled) signals');
            
            % plot aligned signals
            ax2 = subplot(2,1,2); hold on;
            for i=1:nbSignals
                s = alignedSignalSet.getAt(signalIndexes(i));
                plot(s.data(:,1), s.data(:,2));
                ax = gca();
                line = ax.Children(1);
                line.Tag = lineNames{signalIndexes(i)};
            end
            
            %add labels to lines
            dcm_obj = datacursormode(h);
            set(dcm_obj,'UpdateFcn',@myupdatefcn);
            function txt = myupdatefcn(~,event)
                pos = {['X: ', num2str(event.Position(1))], ...
                        ['Y: ', num2str(event.Position(2))] };
                if length(event.Position) == 3
                    pos{3} = ['Z: ', num2str(event.Position(3))];
                end
                txt = [{ get(event.Target,'Tag') }, pos ];
            end
            
            grid on;
            title('Aligned signals');
            linkaxes([ax1,ax2],'xy');
            
            ylim( yl );
            xlim( [ min(targetSignal.data(:,1)), max(targetSignal.data(:,1)) ] );
            legend (ph, 'average');
        end
    
    end
    
end
