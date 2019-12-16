% BIOASTER
%> @file		Aligner.m
%> @class		biotracs.spectra.sigproc.model.Aligner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef Aligner < biotracs.core.mvc.model.Process
    
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
        function this = Aligner()
            %#function biotracs.spectra.sigproc.model.AlignerConfig biotracs.spectra.data.model.SignalSet biotracs.spectra.data.model.Signal biotracs.spectra.sigproc.model.AlignmentResult
            
            this@biotracs.core.mvc.model.Process();
            
            % define input and output specs
            this.addInputSpecs({...
                struct(...
                    'name', 'SignalSet',...
                    'class', 'biotracs.spectra.data.model.SignalSet' ...
                ),...
                struct(...
                    'name', 'TargetSignal',...
                    'required', false, ...
                    'class', 'biotracs.spectra.data.model.Signal' ...
                )
            });
        
            % define input and output specs
            this.addOutputSpecs({...
                struct(...
                    'name', 'Result',...
                    'class', 'biotracs.spectra.sigproc.model.AlignmentResult' ...
                )...
            });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doPass( this, varargin )
            this.logger.writeLog('%s','Pass the data to the output');
            dataSet = this.getInputPortData('SignalSet');
            result = this.getOutputPortData('Result');
            result.set('AlignedSignalSet', dataSet);
            result.set('AlignmentIntervalIndexes', biotracs.data.model.DataMatrix());
            result.set('AlignmentShifts', biotracs.data.model.DataMatrix());
            result.set('TargetSignal', biotracs.spectra.data.model.Signal());
            
            %trigger output
            this.setOutputPortData('Result', result);
        end
        
        function doRun( this )
            signals = this.getInputPortData('SignalSet');
            tableOutputClass = class(signals);
            classOfElements = signals.getClassNameOfElements();
            
            result = this.getOutputPortData('Result');
            
            %try to resample signals
            if ~signals.isResampled
                error('SPECTRA:Aligner:ResampledSignalsRequired', 'The signals must be resampled before alignement');
            end
            [X, Intensities] = signals.getSignalMatrix();
            
            %baseline correction
            %fprintf('Baseline correction with WindowSize = 0.1, StepSize = 0.1\n');
            %Intensities = msbackadj(X,Intensities,'WindowSize', 0.1, 'StepSize', 0.1);
            %Intensities = abs(Intensities);
            
            target = this.config.getParamValue('Target');
            intervals = this.config.getParamValue('Intervals');
            
            options = [];
            if isempty(intervals)
                intervals = 'whole';
            elseif isnumeric(intervals) && length(intervals) > 1
                n = length(X);
                intervals = intervals(:)';  % convert to row vector;
                intervals =  fix( (intervals-X(1)).*(n-1)./(X(end)-X(1)) + 1 );
                intervals(end) = min(n,intervals(end));
            end
            
            targetSignal = this.getInputPortData('TargetSignal');
            Intensities = Intensities';
            
            if hasEmptyData(targetSignal)
                nbPasses = this.config.getParamValue('NbRepetitions');
                
                % choose the average on 3 top signals as reference before using the mean
                % (because the total average may be too noisy)
                if strcmp(target,'top3_and_average') || strcmp(target,'top3')
                    this.logger.writeLog('Alignment pass 0 using top 3 signals ...');
                    sd = std(Intensities,0,2);                        
                    kk = find(sd == max(sd), 1);                      % take the signal with the highest variance
                    [c] = corr(Intensities(kk,:)', Intensities');     % correlation of samples
                    [~, idx] = sort(c, 'descend');                    % take top 3 correlated  
                    n = length(idx);
                    idx = idx(1: min(3,n));

                    target = mean(Intensities(idx,:));               % average of top correlated
                    [Intensities, oIntervals, shifts, targetIntensities] = icoshift.icoshift(target, Intensities, intervals, 'f', options);
                end
                
                if strcmp(target,'top3_and_average') || strcmp(target,'average')
                    target = 'average';
                    for i=1:nbPasses
                        this.logger.writeLog('Alignment pass %d ...', i);
                        [Intensities, oIntervals, shifts, targetIntensities] = icoshift.icoshift(target, Intensities, intervals, 'f', options);
                    end
                end
            else
                this.logger.writeLog('Alignment using an existing target signal');
                target = targetSignal.data(:,2)';
                [Intensities, oIntervals, shifts, targetIntensities] = icoshift.icoshift(target, Intensities, intervals, 'f', options);
            end
            
            alignedSignalSet = this.doBuildAlignedSignalSet( X, Intensities', tableOutputClass );
            result.set('AlignedSignalSet', alignedSignalSet);
            
            intervalsDataMatrix = biotracs.data.model.DataMatrix(oIntervals);
            intervalsDataMatrix.setLabel('Alignment interval indexes')...
                .setDescription('Indexes of the intervals used for alignment')...
                .setColumnNames({'IntervalNumber', 'StartingPointIndex', 'EndingPointIndex', 'Size'});
            result.set('AlignmentIntervalIndexes', intervalsDataMatrix);
            
            shiftsDataMatrix = biotracs.data.model.DataMatrix(shifts);
            shiftsDataMatrix.setLabel('Alignment shifts in the intervals')...
                .setDescription('Indexes reporting how many points each spectrum has been shifted for each interval (+ left, - right)')...
                .setColumnNames('ShiftForInterval');
            result.set('AlignmentShifts', shiftsDataMatrix);
            
            targetSignal = feval(classOfElements{1}, [X, targetIntensities'] );
            targetSignal.setLabel('Target signal')...
                .setDescription('Target signal used for alignment')...
                .setColumnNames({signals.getAt(1).getXAxisLabel(), signals.getAt(1).getYAxisLabel()});
            result.set('TargetSignal', targetSignal);
            
            result.setLabel(signals.label);
            
			this.setOutputPortData('Result', result);
            %result.summary('Deep', true)
        end
       
        function [ alignedSignalSet ] = doBuildAlignedSignalSet( this, MZ, Intensities, tableOutputClass )
            signals = this.getInputPortData('SignalSet');
 
            alignedSignalSet = feval(tableOutputClass);
            classOfElements = alignedSignalSet.getClassNameOfElements();
            
            alignedSignalSet.setLabel( signals.getLabel() )...
                .setDescription('Aligned signals')...
                .updateParamValue('XAxisLabel', signals.getXAxisLabel())...
                .updateParamValue('YAxisLabel', signals.getYAxisLabel())...
                .updateParamValue('ZAxisLabel', signals.getZAxisLabel());
            
            for i=1:size(Intensities,2)
                signal = feval(classOfElements{1}, [MZ, Intensities(:,i)] );
                signal.setLabel( signals.getAt(i).getLabel() )...
                    .setColumnNames( signals.getAt(1).getColumnNames() )...
                    .updateParamValue('IsResampled', true);
                alignedSignalSet.add( signal, signals.getElementName(i) );
            end
            alignedSignalSet.setSignalIndexes( signals.signalIndexes  );
        end
        
    end
end