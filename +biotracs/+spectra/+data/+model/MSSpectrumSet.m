% BIOASTER
%> @file		MSSpectrumSet.m
%> @class		biotracs.spectra.data.model.MSSpectrumSet
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2014

classdef MSSpectrumSet < biotracs.spectra.data.model.SignalSet
    
    properties(Dependent = true)
        retentionTimes;
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        %> @fn MSSpectrumSet( iSepctrumSet )
        %> @fn MSSpectrumSet( iLength )
        %> @param[in]
        function this = MSSpectrumSet( varargin )
            this@biotracs.spectra.data.model.SignalSet()
            if nargin == 0
                this.classNameOfElements = {'biotracs.spectra.data.model.MSSpectrum'};
                this.updateParamValue('XAxisLabel', 'MZ');
                this.updateParamValue('YAxisLabel', 'Retention Time');
                this.updateParamValue('ZAxisLabel', 'Relative Abundance');
            elseif isnumeric( varargin{1} )
                this.allocate( varargin{1} );
                this.classNameOfElements = {'biotracs.spectra.data.model.MSSpectrum'};
                this.updateParamValue('XAxisLabel', 'MZ');
                this.updateParamValue('YAxisLabel', 'Retention Time');
                this.updateParamValue('ZAxisLabel', 'Relative Abundance');
            else
                error('Invalid argument');
            end
            
            this.bindView( biotracs.spectra.data.view.MSSpectrumSet() );
        end
        
        %-- A --
        
        function add( this, iSpectrum, iRetentionTimeName )
            if nargin <= 2
                retentionTime = iSpectrum.getRetentionTime();
                iRetentionTimeName = num2str(retentionTime);
            elseif ischar(iRetentionTimeName)
                retentionTime = str2double( iSpectrum.getRetentionTime() );
            else
                error('The name must be a string');
            end
            this.add@biotracs.spectra.data.model.SignalSet( iSpectrum, iRetentionTimeName );
            this.signalIndexes( this.getLength() ) = retentionTime;
        end
        
        %-- C --
        
        function tic = computeTotalIonCurrent( this )
            tic = this.computeTotalIntensities();
        end
        
        %-- E --
        
        %-- F --
        
        %-- G --
        
        %> @param[in] iRetentionTime [double] The retention time scalar to look for
        %> @param[in] iAbsTolerance [double] The absolute tolerance
        %> @return a Spectrum if found
        %> @throw Error if the spectrum is not found
        function spectrum = getSpectrumByRetentionTime(this, iRetentionTimeScalar, iAbsTolerance)
            if nargin <= 2, iAbsTolerance = 1e-9; end
            [indexes, ~] = this.getIndexesByRetentionTimes( iRetentionTimeScalar(1), iAbsTolerance );
            if ~isempty(indexes)
                spectrum = this.getAt(indexes);
            else
                spectrum = feval([this.classNameOfElements{1},'.empty']);
            end
        end
        
        %> @param[in] iVectorOfRetentionTimes [double] Vector of retention times to look for
        %> @param[in] iAbsTolerance [double] The absolute tolerance
        %> @return The index of the spectrum if it is found, [] otherwise
        function [indexes, retentionTimes] = getIndexesByRetentionTimes(this, iVectorOfRetentionTimes, iAbsTolerance)
            if nargin <= 2, iAbsTolerance = 1e-9; end
            %use fast binary search...
            [indexes, retentionTimes] = biotracs.math.binsearch( ...
                this.getRetentionTimes(), ...
                iVectorOfRetentionTimes, ...
                iAbsTolerance ...
                );
        end
        
        function rt = getRetentionTimes( this, iIndexes )
            if nargin == 1
                rt = this.signalIndexes;
            else
                rt = this.signalIndexes(iIndexes);
            end
        end
        
        function rt = get.retentionTimes( this )
            if nargin == 1
                rt = this.signalIndexes;
            else
                rt = this.signalIndexes(iIndexes);
            end
        end

        %-- I --
        
        %-- S --
        
        %> @param[in] iVectorOfRetentionTimes [array] The retention times values to look for
        %> @param[in] iAbsTolerance [double] The absolute tolerance
        %> @return a Spectrum if found
        %> @throw Error if the spectrum is not found
        function spectrumSet = selectByRetentionTimes(this, iVectorOfRetentionTimes, iAbsTolerance)
            if nargin <= 2, iAbsTolerance = 1e-9; end
            [indexes, ~] = this.getIndexesByRetentionTimes( iVectorOfRetentionTimes, iAbsTolerance );
            spectrumSet = this.selectByIndexes( indexes );
        end
        
        %-- P --
        
        %-- S --
        
        function this = setElements( this, iElements, iRetentionTimeNames )
            if nargin <= 2
                iRetentionTimes = cellfun( @(x)(x.getRetentionTime()), iElements ); %return an array
                iRetentionTimeNames = arrayfun( @num2str, iRetentionTimes, 'UniformOutput', false );
            else
                if ~iscellstr(iRetentionTimeNames)
                    error('Retention time names must be a cell of string');
                end
                iRetentionTimes = str2double(iRetentionTimeNames);
            end
            this.setElements@biotracs.spectra.data.model.SignalSet( iElements, iRetentionTimeNames );
            this.setSignalIndexes( iRetentionTimes );
        end
        
        %-- V --
        
    end
    
    % -------------------------------------------------------
    % Use of helper methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
    end
    
    % -------------------------------------------------------
    % Static
    % -------------------------------------------------------
    
    methods(Static)
        
        %-- F --
        

        function this = fromSpectrumList( iSgnalList )
            if ~isa( iSgnalList, 'cell' )
                error('A cell of ''biotracs.spectra.data.model.MSSpectrum'' is required');
            end
            this = biotracs.spectra.data.model.MSSpectrumSet();
            this.setElements(iSgnalList);
        end
        

        function this = fromSignalSet( iSgnalSet )
            if ~isa( iSgnalSet, 'biotracs.spectra.data.model.SignalSet' )
                error('A ''biotracs.spectra.data.model.SignalSet'' is required');
            end
            this = biotracs.spectra.data.model.MSSpectrumSet();
            this.doCopy(iSgnalSet);
        end
        
        %-- I --
        
        %> @param[in] iFilePath a file or folder path
        %> @param[in] Options used to configure biotracs.spectra.parser.model.MzxmlParsingProtocol
        %> @return a biotracs.spectra.data.model.MSSpectrumSet if only one raw data file is imported
        %> @return a biotracs.core.mvc.ResourceSet containing a set of
        %> biotracs.spectra.data.model.MSSpectrumSet if a list a raw data file is imported
        function [ result ] = import( iFilePath, varargin )
            process = biotracs.spectra.parser.model.MzxmlParser();
            c = process.getConfig();
            c.hydrateWith(varargin);
            c.updateParamValue('OutputClass', 'biotracs.spectra.data.model.MSSpectrumSet');
            process.setInputPortData( 'DataFile', biotracs.data.model.DataFile(iFilePath) );
            process.run();
            result = process.getOutputPortData('ResourceSet');
            if result.getLength() == 1
                result = result.getAt(1);
            end
        end

    end
end
