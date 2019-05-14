% BIOASTER
%> @file		SignalSet.m
%> @class		biotracs.spectra.data.model.SignalSet
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2014

classdef SignalSet < biotracs.core.mvc.model.ResourceSet
    
    properties(SetAccess = protected)
        signalIndexes;
        %hasUniformBins = false;
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        %> @fn SignalSet( iSepctrumSet )
        %> @fn SignalSet( iLength, iClassNameOfElements )
        %> @param[in]
        function this = SignalSet( varargin )
            this@biotracs.core.mvc.model.ResourceSet()
            if nargin == 0
                this.classNameOfElements = {'biotracs.spectra.data.model.Signal'};
                this.doCreateAllParams();
            elseif isnumeric( varargin{1} )
                this.allocate( varargin{1} );
                if nargin == 2, this.setClassNameOfElements( varargin{2} ); end
                this.doCreateAllParams();
            else
                error('Invalid argument');
            end
            this.bindView( biotracs.spectra.data.view.SignalSet() );
        end
        
        %-- A --
        
        %> @param[in] iSpectrum Spectrum to add
        %> @param[in] [optional, char] Unique name of the spectrum. If not
        %provided a unique name is created and returned
        %> @return this
        %> @return the unique name of the element
        function [this, oName] = add( this, varargin )
            [~, oName] = this.add@biotracs.core.mvc.model.ResourceSet( varargin{:} );
            this.signalIndexes( this.getLength() ) = this.getLength();
        end
        
        
        % Overload allocate()
        % Set signalIndexes
        % Clear the set and allocate memory
        function this = allocate(this, iNbElements)
            this.allocate@biotracs.core.mvc.model.ResourceSet( iNbElements );
            this.signalIndexes = (1:iNbElements)';
        end
        
        function [result] = align( this, varargin )
            process = biotracs.spectra.sigproc.model.Aligner();
            process.setInputPortData('SignalSet', this);
            c = process.getConfig();
            c.hydrateWith( varargin );
            process.run();
            result = process.getOutputPortData('Result'); 
        end
        
        %-- B --
        
        function [result] = bin( this, varargin )
            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', this);
            c = process.getConfig();
            c.hydrateWith( varargin );
            process.run();
            result = process.getOutputPortData('Result');
        end
        
        %-- C --
        
        function [ int ] = computeTotalIntensities( this, varargin )
            n = this.getLength();
            int = [ this.signalIndexes(:), zeros(n,1) ];
            for i=1:n
				s = this.getAt(i);
                int(i,2) = sum(s.data(:,2));
            end
        end 
        
        function [ int ] = computeAverageIntensities( this, varargin )
            n = this.getLength();
            int = [ this.signalIndexes(:), zeros(n,1) ];
            for i=1:n
				s = this.getAt(i);
                int(i,2) = mean(s.data(:,2));
            end
        end 
        
        function [ int ] = computeMaxIntensities( this, varargin )
            n = this.getLength();
            int = [ this.signalIndexes(:), zeros(n,1) ];
            for i=1:n
				s = this.getAt(i);
                int(i,2) = max(s.data(:,2));
            end
        end  

        function [ int ] = computeMinIntensities( this, varargin )
            n = this.getLength();
            int = [ this.signalIndexes(:), zeros(n,1) ];
            for i=1:n
				s = this.getAt(i);
                int(i,2) = min(s.data(:,2));
            end
        end  
        
        function [resampledCss] = createConsensus( this, varargin ) 
            resamplingResult = this.resample(varargin{:});
            spectrumSet = resamplingResult.get('ResampledSignals');

            process = biotracs.spectra.sigproc.model.ConsensusSignalCreator();
            c = process.getConfig();
            process.setInputPortData('ResourceSet', spectrumSet);
            c.hydrateWith( varargin );
            process.run();
            result = process.getOutputPortData('Result');
            resampledCss = result.get('ConsensusSignalSet');
        end
        
        %-- E --
        
        function export( this, iFilePath, varargin )
            [dirname,filename,ext] = fileparts(iFilePath);
            switch lower(ext)
                case {'.csv','.xlsx', '.xls'}
                    if this.isResampled()
                        dataSet = this.toDataSet();
                        dataSet.export( iFilePath );
                    else
                        if this.getLength() == 1
                            signal = this.getAt(1);
                            signal.export( fullfile(dirname, [filename,ext]) );
                        else
                            for i=1:this.getLength()
                                signal = this.getAt(i);
                                sidx = this.signalIndexes(i);
                                if isnumeric(sidx), sidx = num2str(sidx); end
                                signal.export( fullfile(dirname, [filename,'-',sidx,ext]) );
                            end
                        end
                    end
                otherwise
                    this.export@biotracs.core.mvc.model.ResourceSet( iFilePath );
            end
        end
        
        %-- F --

        %-- G --

        function label = getXAxisLabel( this )
            label = this.getParamValue('XAxisLabel');
        end
        
        function label = getYAxisLabel( this )
            label = this.getParamValue('YAxisLabel');
        end
        
        function label = getZAxisLabel( this )
            label = this.getParamValue('ZAxisLabel');
        end
        
        function si = getSignalIndexes( this, iIndexes )
            if nargin == 1
                si = this.signalIndexes;
            else
                si = this.signalIndexes(iIndexes);
            end
        end
        
        
        % Extract signals associated to each spectrum.
        % Signals are list of peaks if spectra are in centroid mode,
        % continuous signals are extracted otherwise.
        %> @return A n-by-1 cell() containing the signals, where n is the
        % number of spectra
        function [oSignalList] = getSignalList( this, iIndexes )
            if nargin == 1
                iIndexes = 1:this.getLength();
            end
            
            if isscalar(iIndexes)
                spectrumList = this.getAt(iIndexes);
                oSignalList = { spectrumList.data };
            else
                oSignalList = cell(length(iIndexes), 1);
                spectrumList = this.getAt(iIndexes);
                for i = 1:length(spectrumList)
                    oSignalList{i} = spectrumList{i}.data;
                end
            end
        end
        
        function [indexes, intensities] = getSignalMatrix( this, iIndexes )
            if ~this.isResampled( true )
                error('SPECTRA:SignalSet:ResampledSignalsRequired', 'Signals set must be resampled');
            end
            
            n = this.getLength();
            if nargin == 1
                iIndexes = 1:n;
            end
            
            m = this.getAt(1).getLength();
            intensities = zeros(m,n);
            for i = 1:n
                intensities(:,i) = this.getAt(iIndexes(i)).data(:,2);
            end
            indexes = this.getAt(1).data(:,1);
        end
        
        %%-- I --
        
        %@ToDo: test all spectra
        function tf = isCentroided( this )
            tf = strcmp(biotracs.spectra.data.model.Signal.DEFAULT_REPRESENTATION, biotracs.spectra.data.model.Signal.REPRESENTATION_CENTROID);
            n = getLength(this);
            for i=1:n
                if isa( this.getAt(i), 'biotracs.spectra.data.model.Signal' )
                    tf = this.getAt(i).isCentroided();
                    break;
                end
            end
        end
        
        function tf = isResampled( this, iCheckAll )
            tf = true;
            n = getLength(this);
            if nargin == 2 && iCheckAll
                for i=1:n-1
                    tf = isequal(this.getAt(i).data(:,1), this.getAt(i+1).data(:,1));
                    if ~tf
                        break;
                    end
                end
            else
                tf = this.getAt(1).isResampled();
            end
        end

        %-- H --
        
        %-- M --
        
        %-- S --
        
        function this = setElements( this, varargin )
            this.setElements@biotracs.core.mvc.model.ResourceSet( varargin{:} );
            this.setSignalIndexes( 1:this.getLength() );
        end
        
        function setSignalIndexes( this, iSignalIndexes )
            if length(iSignalIndexes) ~= this.getLength()
                error('The length if the indexes array exceeds the signal set dimensions');
            end
            
            if ~issorted(iSignalIndexes)
                error('Indexes must be sorted');
            end
            
            this.signalIndexes = iSignalIndexes;
        end
        
        %> @param[in] iIndexes [array] Indexes of the spectra to retreive
        %> @return a SignalSet if some spectra are found
        %> @throw Error if no spectra are found
        function spectrumSet = selectByIndexes(this, iIndexes)
            if ~isempty(iIndexes)
                spectrumSet = feval( class(this), length(iIndexes) );
                spectrumSet.setLabel( ['Subset of ', this.label] )...
                    .setDescription( this.description );
                for i=1:length(iIndexes)
                    spectrum = this.getAt( iIndexes(i) );
                    spectrumSet.setAt( i, spectrum );
                end
            else
                spectrumSet = feval([class(this),'.empty()']);
            end
        end
        
        %-- P --
        
        % Preak picking to compute the centroid of all peaks in a signal
        %> @param[in] Optional @see mspeaks() optional arguments
        %> @return The result of a biotracs.spectra.sigproc.model.PeakPickingProtocol
        function result = pickPeaks( this, varargin )
            process = biotracs.spectra.sigproc.model.PeakPicker();
            process.setInputPortData('SignalSet', this);
            c = process.getConfig();
            c.hydrateWith(varargin);
            process.run();
            result = process.getOutputPortData('Result');
        end
        
        
        %-- R --
        
        function removeAll( this )
            this.removeAll@biotracs.core.mvc.model.ResourceSet();
            this.signalIndexes = [];
        end
        
        % Reseample a the spectra signals while preserving peaks
        % The resampled signals have @a iNbPoints equally spaced points
        %> @param[in] iNbPoints [optional] the number of point need for resampling.
        % This the number of point is too low so that information is
        % lost, a warning if displayed. If not provided, it is
        % automatically computed to preserve information.
        %> @return MZ a n-by-1 matrix of common MZ after resampling. n = number of common MZ
        %> @return Y a n-by-m matrix containing the intensity of each signal at given MZ, where m = number of biotracs.spectra.
        %> @return oNbPoints The number of points used for resampling
        %> @use msppresample() Matlab function.
        %> @see msppresample()
        function [result] = resample( this, varargin ) 
            process = biotracs.spectra.sigproc.model.Resampler();
            process.setInputPortData('SignalSet', this);
            c = process.getConfig();
            c.hydrateWith( varargin );
            process.run();
            result = process.getOutputPortData('Result');
        end
        
        %-- S --
        
        function this = setAt( this, iIndex, iSpectrum  )
            this.setAt@biotracs.core.mvc.model.ResourceSet( iIndex, iSpectrum );
            this.signalIndexes(iIndex) = iSpectrum.getRetentionTime();
        end
        
        function this = set( this, iName, iSpectrum  )
            this.set@biotracs.core.mvc.model.ResourceSet( iName, iSpectrum );
            index = this.getIndexByName(iNames);
            this.signalIndexes(index) = iSpectrum.getRetentionTime();
        end
        
        function this = setRepresentation( this, iRep )
            for i=1:this.getLength()
               this.getAt(i).setRepresentation(iRep); 
            end
        end
        
        %-- T --
        
        function dataSet = toDataSet( this, varargin )
            p = inputParser();
            p.addParameter('SkipResampling', false);
            p.parse( varargin{:} );
            
            if ~p.Results.SkipResampling && ~this.isResampled
                error('The SignalSet must be resampled before being converting to DataSet.');
            end
            
            [indexes, intensities] = this.getSignalMatrix();
            dataSet = biotracs.data.model.DataSet( intensities' );
            dataSet.setColumnNames( strsplit(num2str(indexes', 12)) );
            dataSet.setRowNames(this.elementNames);
            dataSet.setLabel(this.label);
        end
        
        %-- V --
        
    end
    
    % -------------------------------------------------------
    % Static
    % -------------------------------------------------------
    
    methods(Static)
        
        function this = fromSignalSet( iSgnalSet )
            if ~isa( iSgnalSet, 'biotracs.spectra.data.model.SignalSet' )
                error('A ''biotracs.spectra.data.model.SignalSet'' is required');
            end
            this = biotracs.spectra.data.model.SignalSet();
            this.doCopy(iSgnalSet);
        end
       
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        %-- C --
        
        function doCopy( this, iSignalSet, varargin )
            this.doCopy@biotracs.core.mvc.model.ResourceSet( iSignalSet, varargin{:} );
            this.signalIndexes = iSignalSet.signalIndexes;
        end
        
        function doCreateAllParams( this )
            this.createParam('XAxisLabel', 'Separation Unit');
            this.createParam('YAxisLabel', 'Signal Index');
            this.createParam('ZAxisLabel', 'Intensity');
        end
        
        %-- P --
    end

end
