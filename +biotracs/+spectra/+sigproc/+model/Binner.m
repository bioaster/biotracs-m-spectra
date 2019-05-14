% BIOASTER
%> @file		Binner.m
%> @class		biotracs.spectra.sigproc.model.Binner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef Binner < biotracs.core.mvc.model.Process
    
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
        function this = Binner()
            this@biotracs.core.mvc.model.Process();
            
            % define input and output specs
            this.addInputSpecs({...
                struct(...
                    'name', 'SignalSet',...
                    'class', 'biotracs.core.mvc.model.Resource' ...
                )...
            });
        
            % define input and output specs
            this.addOutputSpecs({...
                struct(...
                    'name', 'Result',...
                    'class', 'biotracs.spectra.sigproc.model.BinningResult' ...
                )...
            });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doRun( this )
            signals = this.getInputPortData('SignalSet');
            if signals.isCentroided()
                error('Only profile resampled signals can be binned');
            end
			
            %if ~signals.isResampled()
            %    warning('Please ensure that resampled signals are binned');
            %end
            
			result = this.getOutputPortData('Result');
            binTicks = this.doComputeCommonBinTicks();
            [discreteSignals, continuousSignals, stats, signalNames] = this.doBinning( signals, binTicks );

            if isa( signals, 'biotracs.spectra.data.model.Signal' )
                result.set( 'DiscreteBinnedSignals', discreteSignals{1} );
                result.set( 'ContinuousBinnedSignals', continuousSignals{1} );
                result.set( 'Statistics', stats );
            elseif isa( signals, 'biotracs.spectra.data.model.SignalSet' )
                discreteSignalSet = biotracs.spectra.data.model.SignalSet();
                
                discreteSignalSet.setElements(discreteSignals, signalNames);
                discreteSignalSet.setSignalIndexes( signals.signalIndexes  );
                discreteSignalSet.setLabel( signals.getLabel() );
                result.set( 'DiscreteBinnedSignals', discreteSignalSet );
                
                continuousSignalSet = biotracs.spectra.data.model.SignalSet();
                continuousSignalSet.setElements(continuousSignals, signalNames);
                continuousSignalSet.setSignalIndexes( signals.signalIndexes  );
                continuousSignalSet.setLabel( signals.getLabel() );
                result.set( 'ContinuousBinnedSignals', continuousSignalSet );
                result.set( 'Statistics', stats );
            else
                error('Invalid input data');
            end

            result.setLabel( signals.label );
            this.setOutputPortData('Result', result);
        end
        
        function [discreteSignals, continuousSignals, stats, signalNames] = doBinning( this, iSignal, iBinTicks )
            if isa( iSignal, 'biotracs.spectra.data.model.Signal' )
                indexes = iSignal.data(:,1);
                intensities = iSignal.data(:,2);
            else
                [indexes, intensities] = iSignal.getSignalMatrix(); 
            end
            
			biotracs.core.env.Env.currentLogger( this.logger );
            if strcmp(this.config.getParamValue('Method'), 'gaussian')
                sigma = this.config.getParamValue('StandardDeviation'); 
                [discreteSignalData, continuousSignalData] = biotracs.math.bingdata( intensities, indexes, iBinTicks, sigma );
            else
                [discreteSignalData, continuousSignalData] = biotracs.math.bindata( intensities, indexes, iBinTicks );
            end
            
            binCenters = (iBinTicks(1:end-1) + iBinTicks(2:end))/2;
            idx = find( indexes >= iBinTicks(1) & indexes <= iBinTicks(end) );
            n = size(intensities,2);
            stats = zeros(n,2);
            discreteSignals = cell(1,n);
            continuousSignals = cell(1,n);
            signalNames = cell(1,n);
            for i=1:n
                if isa( iSignal, 'biotracs.spectra.data.model.Signal' )
                    signalNames{i} = '';
                    signalLabel = iSignal.getLabel();
                    cnames = iSignal.getColumnNames();
                else
                    signalNames{i} = iSignal.getElementName(i);
                    signalLabel = iSignal.getAt(i).getLabel();
                    cnames = iSignal.getAt(i).getColumnNames();
                end
                [rho, pval] = corr(continuousSignalData(idx,i), intensities(idx,i));
                stats(i,:) = [rho, pval]; 
                discreteSignals{i} = biotracs.spectra.data.model.Signal( [binCenters, discreteSignalData(:,i)] );
                discreteSignals{i}.setLabel( signalLabel )...
                    .setColumnNames( cnames )...
                    .updateParamValue('IsResampled', true);
                
                continuousSignals{i} = biotracs.spectra.data.model.Signal( [indexes, continuousSignalData(:,i)] );
                continuousSignals{i}.setLabel( signalLabel )...
                    .setColumnNames( cnames )...
                    .updateParamValue('IsResampled', true);
            end
            
            stats = biotracs.data.model.DataMatrix( stats, {'correlation', 'pvalue'}, signalNames );
            stats.setLabel(iSignal.getLabel());
        end

        function  [ binTicks ] = doComputeCommonBinTicks( this )
            signals = this.getInputPortData('SignalSet');
            if isempty( this.config.getParamValue('BinTicks') )
                w = this.config.getParamValue('BinWidth');
                if isempty(w), error('Either a BinWidth or BinTicks must be given'); end
                range = this.config.getParamValue('Range');
                %compute common range and minimal allowed bin width
                if isa( signals, 'biotracs.spectra.data.model.Signal' )
                    commonRange = [signals.data(1,1), signals.data(end,1)];
                    minAllowedBinWidth = max(diff(signals.data(:,1)));
                else
                    n = signals.getLength();
                    lbs = zeros(1,n);
                    ubs = zeros(1,n);
                    minAllowedBinWidth = Inf;
                    for i=1:signals.getLength()
                        lbs(i) = signals.getAt(i).data(1,1);
                        ubs(i) = signals.getAt(i).data(end,1);
                        minAllowedBinWidth = min([minAllowedBinWidth, max(diff(signals.getAt(i).data(:,1)))]);
                    end
                    % compute minimal and maximal bound allow for
                    % common binning axe
                    commonRange = [max(lbs), min(ubs)];
                end
                
                if ~isempty(range)
                    if range(1) < commonRange(1), range(1) = commonRange(1); end
                    if range(2) > commonRange(2), range(2) = commonRange(2); end
                else
                    range = commonRange;
                end
                
                if w < minAllowedBinWidth
                    error('The minimal allowed bin width is %g while the proposed bin width is %g.\nTip: Resample the signal(s) to use smaller bin widths', minAllowedBinWidth, w);
                end
                binTicks = (range(1) : w : range(2))';
            else
                binTicks = this.config.getParamValue('BinTicks');
                binTicks = binTicks(:);
            end
        end
        
        function [ bins ] = doComputeAdaptiveBinTicks( ~, signal )
            y = -signal.data(:,2);
            y = y - min(y);
            peaks = mspeaks( signal.data(:,1), y );
            bins = peaks(:,1); 
        end
        
    end
end