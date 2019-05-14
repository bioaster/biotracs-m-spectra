% BIOASTER
%> @file		BaselineAdjustmentSignalSet.m
%> @class		biotracs.spectra.sigproc.view.BaselineAdjustmentSignalSet
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date        2017

classdef BaselineAdjustmentSignalSet < biotracs.spectra.data.view.SignalSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        function h = viewBaselineAdjustmentPlot( this, varargin )
            p = inputParser();
            p.addParameter('SignalIndexes',[],@isnumeric);
            p.KeepUnmatched = true;
            p.parse(varargin{:});

            model = this.getModel();
            if model.getProcess().isPhantom
                biotracs.core.env.Env.writeLog('%s','Cannot view plot. No alignement was performed becasue the Process was phantom.');
                return;
            end
            
            process = model.getProcess();
            originalResampledSignalSet = process.getInputPortData('SignalSet');
            
            h = figure;
            
            % plot original (resampled) signals
            ax1 = subplot(2,1,1); hold on;
            lineNames = originalResampledSignalSet.getElementNames();
            nbSignals = length(lineNames);
            signalIndexes = 1:nbSignals;
            if ~isempty(p.Results.SignalIndexes)
                signalIndexes = p.Results.SignalIndexes;
            end
            
            for i=1:nbSignals
                s = originalResampledSignalSet.getAt(signalIndexes(i));
                plot(s.data(:,1), s.data(:,2));
                ax = gca();
                line = ax.Children(1);
                line.Tag = lineNames{signalIndexes(i)};
            end
            
            grid on;
            title('Original signal(s)');
            
            % plot aligned signals
            ax2 = subplot(2,1,2); hold on;
            for i=1:nbSignals
                s = model.getAt(signalIndexes(i));
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
            title('Baseline-Adjusted signal(s)');
            linkaxes([ax1,ax2],'xy');
        end

    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)

    end
    
end
