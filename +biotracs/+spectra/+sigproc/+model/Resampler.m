% BIOASTER
%> @file		Resampler.m
%> @class		biotracs.spectra.sigproc.model.Resampler
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef Resampler < biotracs.core.mvc.model.Process
    
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
        function this = Resampler()
            this@biotracs.core.mvc.model.Process();
            
            % define input and output specs
            this.addInputSpecs({...
                struct(...
                'name', 'SignalSet',...
                'class', {{'biotracs.spectra.data.model.Signal','biotracs.spectra.data.model.SignalSet'}} ...
                )...
                });
            
            % define input and output specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.spectra.sigproc.model.ResamplingResult' ...
                )...
                });
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        %-- B --
        
        function doBuildResamplingResult1( this, MZ, Intensities )
            signals = this.getInputPortData('SignalSet');
            result = this.getOutputPortData('Result');
            
            tableOutputClass = class(signals);
            resampledSignal = feval(tableOutputClass, [MZ, Intensities] );
            resampledSignal.setColumnNames( signals.getColumnNames() )...
                .updateParamValue('IsResampled', true)...
                .setLabel( ['Resampled (', signals.getLabel() ,')'] )...
                .setDescription('Resampled peak list. Contains Indexes (or MZ) equally spaced and corresponding itensities');
            result.set('ResampledSignals', resampledSignal);
            
            this.setOutputPortData('Result', result);
        end
        
        function doBuildResamplingResult2( this, MZ, Intensities )
            signals = this.getInputPortData('SignalSet');
            result = this.getOutputPortData('Result');
            
            tableOutputClass = class(signals);
            resampledSignalSet = feval( tableOutputClass );
            resampledSignalSet.setLabel(signals.getLabel())...
                .setDescription('Resampled peak lists. Contains commom Indexes (or MZ) equally spaced and corresponding itensities')...
                .updateParamValue('XAxisLabel', signals.getXAxisLabel())...
                .updateParamValue('YAxisLabel', signals.getYAxisLabel())...
                .updateParamValue('ZAxisLabel', signals.getZAxisLabel());
            
            for i=1:length(Intensities(1,:))
                classOfElements = class(signals.getAt(i));
                signal = feval( classOfElements, [MZ, Intensities(:,i)] );
                signal.setLabel(signals.getAt(i).getLabel())...
                    .setColumnNames( signals.getAt(1).getColumnNames() )...
                    .updateParamValue('IsResampled', true);
                resampledSignalSet.add( signal, signals.getElementName(i) );
            end
            resampledSignalSet.setSignalIndexes( signals.signalIndexes  );
            result.set('ResampledSignals', resampledSignalSet);
            
            this.setOutputPortData('Result', result);
        end
        
        function doBeforeRun( this )
            this.doBeforeRun@biotracs.core.mvc.model.Process();
            signals = this.getInputPortData('SignalSet');
            this.setIsPhantom( signals.isResampled() );
        end
        
        %-- C --
        
        % Continuous signal resampling (1D signal)
        function doCresample1( this, nbpoints, range, varargin )
            this.logger.writeLog('%s', 'Resampling of a continuous signal ...');
            signals = this.getInputPortData('SignalSet');
            [MZ, Intensities] = biotracs.spectra.sigproc.helper.msresample(signals.data(:,1), signals.data(:,2), nbpoints, varargin{:}, 'Range', range, 'Uniform', true);
            this.doBuildResamplingResult1(MZ, Intensities);
        end
        
        % Continuous signal set resampling (2D signal)
        function doCresample2( this, nbpoints, range, varargin )
            this.logger.writeLog('%s', 'Resampling of a set of a continuous signals ...');
            signals = this.getInputPortData('SignalSet');
            n = signals.getLength();
            MZ = zeros(nbpoints, 1);
            Intensities = zeros(nbpoints, n);
            for i=1:n
                [tempMZ, tempIntensities] = biotracs.spectra.sigproc.helper.msresample(signals.getAt(i).data(:,1), signals.getAt(i).data(:,2), nbpoints, varargin{:}, 'Range', range, 'Uniform', true);
                if i == 1
                    MZ = tempMZ;
                end
                Intensities(:,i) = tempIntensities;
            end
            this.doBuildResamplingResult2(MZ, Intensities);
        end
        
        function [range] = doComputeRange( this )
            range = this.config.getParamValue('Range');
            if ~isempty(range)
                return;
            end
            signals = this.getInputPortData('SignalSet');
            if isa( signals, 'biotracs.spectra.data.model.Signal' )
                t = signals.data(:,1);
                range = [min(t), max(t)];
            else
                %compute common [min, max] range
                n = signals.getLength();
                lbs = zeros(1,n);
                ubs = zeros(1,n);
                for i=1:signals.getLength()
                    lbs(i) = signals.getAt(i).data(1,1);
                    ubs(i) = signals.getAt(i).data(end,1);
                end
                if this.config.getParamValue('ExtendRange')
                    range = [min(lbs), max(ubs)];  %default common range
                else
                    range = [max(lbs), min(ubs)];  %default common range
                end
            end
        end
        
        function [nbpoints, range] = doComputeNbPoints( this )
            [range] = doComputeRange( this );
            nbpoints = this.config.getParamValue('NbPoints');
            %lambda = this.config.getParamValue('SamplingMultiplier');
            fwhm = this.config.getParamValue('FWHM');
            %if isempty(lambda), lambda = 1; end
            if ~isempty(nbpoints)
                if ~isempty(fwhm)
                    % 6 sigma = 1 peak = (nbPointsPerPeak-1)*binWidth
                    % binWidth = 6*sigma/(nbPointsPerPeak-1)
                    % As sigma = fwhm/2, then
                    % binWidth = 3*fwhm/(nbPointsPerPeak-1)
                    % We will use binwidth = 3*fwhm/(nbPointsPerPeak)
                    nbPointPerPeak = this.config.getParamValue('NbPointsPerPeak');
                    binwidth = 3*fwhm/nbPointPerPeak;
                    minNbPoints = ceil((range(2) - range(1))/binwidth);
                    if nbpoints < minNbPoints
                        this.logger.writeLog('Warning: %d resampling points (instead of %d) are used to insure %d points per peak since the FWHM = %g.', minNbPoints, nbpoints, nbPointPerPeak, fhwm);
                        nbpoints = minNbPoints;
                    end
                end
            else
                if ~isempty(fwhm)
                    % 6 sigma = 1 peak = (nbPointsPerPeak-1)*binWidth
                    % binWidth = 6*sigma/(nbPointsPerPeak-1)
                    % As sigma = fwhm/2, then
                    % binWidth = 3*fwhm/(nbPointsPerPeak-1)
                    % We will use binwidth = 3*fwhm/(nbPointsPerPeak)
                    nbPointPerPeak = this.config.getParamValue('NbPointsPerPeak');
                    binwidth = 3*fwhm/nbPointPerPeak;
                    nbpoints = ceil((range(2) - range(1))/binwidth);
                    this.logger.writeLog('%d resampling points are used to insure %d points per peak since the FWHM = %g.', nbpoints, nbPointPerPeak, fwhm);
                else
                    %compute nbpoints ...
                    signals = this.getInputPortData('SignalSet');
                    if isa( signals, 'biotracs.spectra.data.model.Signal' )
                        idx = signals.data(:,1) >= range(1) & signals.data(:,1) <= range(end);
                        t = signals.data(idx,1);
                        %compute nbsamples...
                        %if signals.isCentroided
                            nbpoints = fix((range(end) - range(1)) / min(diff(t)));
                        %else
                        %    nbpoints = numel(t);
                        %end
                        this.logger.writeLog('%d resampling points are used.', nbpoints);
                    else
                        %compute nbsamples...
                        nbpoints = 0;
                        %maxlength = 0;
                        n = getLength(signals);
                        for i=1:n
                            idx = signals.getAt(i).data(:,1) >= range(1) & signals.getAt(i).data(:,1) <= range(end);
                            t = signals.getAt(i).data(idx,1);
                            nbpoints = max(nbpoints,  fix((range(end) - range(1)) / min(diff(t))));
                        %    maxlength = max(maxlength, numel(t));
                        end
                            
                        %if ~signals.isCentroided 
                        %    nbpoints = maxlength;
                        %end
                        this.logger.writeLog('%d resampling points are used.', nbpoints);
                    end

                end
            end
        end
        
        % Resample a 1D centroided signal while preserving peaks.
        % The resampled signal has N equally spaced samples
        % If the requested number of points is too low so that information
        % is lost, a warning if displayed. If the number of points is not
        % provided, it is automatically computed to preserve information.
        % The resampled signal is a DataMatrix containing [X, Y] data
        % X is a N-by-1 matrix of common X after resampling.
        % Y a N-by-1 matrix containing the intensity of the signal at given X
        %> @use msppresample() Matlab function.
        function doPresample1( this, nbpoints, range, varargin )
            this.logger.writeLog('%s', 'Run resampling for a peak list while preserving peak positions ...');
            signals = this.getInputPortData('SignalSet');
            [MZ, Intensities] = biotracs.spectra.sigproc.helper.msppresample(signals.data, nbpoints, varargin{:}, 'Range', range);
            this.doBuildResamplingResult1(MZ, Intensities);
        end
        
        % Resample a 2D centroided signals while preserving peaks.
        %> @see doPresample1
        function doPresample2( this, nbpoints, range, varargin )
            this.logger.writeLog('%s', 'Run resampling for a set of peak lists while preserving peak positions ...');
            signals = this.getInputPortData('SignalSet');
            peakList = signals.getSignalList();
            [MZ, Intensities] = biotracs.spectra.sigproc.helper.msppresample(peakList, nbpoints, varargin{:}, 'Range', range);
            this.doBuildResamplingResult2(MZ, Intensities);
        end
        
        %-- R --
        
        function doRun( this )
            
            %compute effective nbpoints and common range
            [nbpoints, range] = this.doComputeNbPoints();
            
            signals = this.getInputPortData('SignalSet');
            if signals.isCentroided
                % resample the centroided signals...
                opt = {};
                fwhh = this.config.getParamValue('FWHM');
                if ~isempty(fwhh) && fwhh > 0, opt = {'FWHH', fwhh}; end
                if isa( signals, 'biotracs.spectra.data.model.Signal' )
                    this.doPresample1( nbpoints, range, opt{:} );
                elseif isa( signals, 'biotracs.spectra.data.model.SignalSet' )
                    this.doPresample2( nbpoints, range, opt{:} );
                else
                    error('Invalid input Signals. Must be biotracs.spectra.data.model.Signal or biotracs.data.SignalSet');
                end
            else
                % resample the profile signals...
                opt = {};
                if isa( signals, 'biotracs.spectra.data.model.Signal' )
                    this.doCresample1( nbpoints, range, opt{:} );
                elseif isa( signals, 'biotracs.spectra.data.model.SignalSet' )
                    this.doCresample2( nbpoints, range, opt{:} );
                else
                    error('Invalid input Signals. Must be biotracs.spectra.data.model.Signal or biotracs.data.SignalSet');
                end
            end
        end
        
        %-- P --
        
        function doPass( this )
            this.logger.writeLog('%s', 'The signals are already resampled. Pass the data to the output');
            signals = this.getInputPortData('SignalSet');
            result = this.getOutputPortData('Result');
            result.set('ResampledSignals', signals);
            this.setInputPortData('SignalSet', signals);
        end
    end
    
end