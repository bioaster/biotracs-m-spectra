% BIOASTER
%> @file		MSSpectrumMap.m
%> @class		biotracs.spectra.data.model.MSSpectrumMap
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef MSSpectrumMap < biotracs.core.mvc.model.Resource

    properties(SetAccess = private)
        levels;
        highMz;
        precursorMz;
        scanInfo;
        precursorInfo;
        retentionTimes;
        data;
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        %> @fn MSSpectrumMap( iSepctrumSet )
        %> @fn MSSpectrumMap( iLength )
        %> @param[in]
        function this = MSSpectrumMap( iMapData )
            this@biotracs.core.mvc.model.Resource();
            if nargin == 1 && isstruct( iMapData )
                this.doParseMapData( iMapData );
            else
                error('Invalid argument');
            end
            
            this.createParam('XAxisLabel', 'MZ');
            this.createParam('YAxisLabel', 'Retention Time');
            this.createParam('ZAxisLabel', 'Relative Abundance');
            this.bindView( biotracs.spectra.data.view.MSSpectrumMap() );
        end
        
        %-- A --

        %-- C --
        
        function tic = computeTotalIonCurrent( this )
            tic = cellfun( @(x)(sum(x(:,2))), this.data );
            tic = [this.retentionTimes(:), tic];
        end
        
        %-- E --
        
        %-- F --
        
        %-- G --
        
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
        
        function oScanCount = getScanCount( this )
            oScanCount = length(this.retentionTimes);
        end
        
        function spectrum = getAt( this, iIndex )
            spectrum = biotracs.spectra.data.model.MSSpectrum( this.data{iIndex}, this.retentionTimes(iIndex) );
            spectrum.setProcess(this.process);
        end
        
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
        
        function [logicalIndexes, numericIndexes] = getIndexesByRetentionTimes(this, iRetentionTimes, iAbsTolerance)
            if nargin <= 2, iAbsTolerance = 1e-9; end
            logicalIndexes = ismembertol(this.retentionTimes, iRetentionTimes, iAbsTolerance, 'DataScale', 1);
            if nargout == 2
                numericIndexes = find(logicalIndexes);
            end
        end

        function [logicalIndexes, numericIndexes] = getIndexesByLevel(this, iLevel)
            logicalIndexes = (this.levels == iLevel(1));
            if nargout == 2
                numericIndexes = find(logicalIndexes);
            end
        end
        
        function [logicalIndexes, numericIndexes] = getIndexesByHighMz(this, iHighMz, iAbsTolerance)
            if nargin <= 2, iAbsTolerance = 1e-9; end
            logicalIndexes = ismembertol(this.highMz, iHighMz, iAbsTolerance, 'DataScale', 1);
            if nargout == 2
                numericIndexes = find(logicalIndexes);
            end
        end
       
        function [logicalIndexes, numericIndexes] = getIndexesByPrecursorMz(this, iPrecursorMz, iAbsTolerance)
            if nargin <= 2, iAbsTolerance = 1e-9; end
            logicalIndexes = ismembertol(this.precursorMz, iPrecursorMz, iAbsTolerance, 'DataScale', 1);
            if nargout == 2
                numericIndexes = find(logicalIndexes);
            end
        end
        
        function rt = getRetentionTimes( this )
            rt = this.retentionTimes;
        end

        %-- H --
        
        %-- I --
        
        function tf = isCentroided( this )
            tf = strcmp(this.scanInfo{1}.centroided, "1");
        end
    
        %-- S --
        %-- P --
        %-- S --
        %-- V --
        
        function oSpectrumSet = createSpectrumSet( this, varargin )
            p = inputParser();
            p.addParameter('ScanIndexes', []);
            p.addParameter('RetentionTimes', []);
            p.addParameter('RetentionTimeAbsTol', 1);
            p.addParameter('Mz', []);
            p.addParameter('MzAbsTol', 10);
            p.addParameter('PrecursorMz', []);
            p.addParameter('PrecursorMzAbsTol', 0.1);
            p.addParameter('Level', []);
            p.parse(varargin{:});

            
            idx = true(1,this.getScanCount());
            if ~isempty(p.Results.RetentionTimes)
                idx = idx & this.getIndexesByRetentionTimes( p.Results.RetentionTimes, p.Results.RetentionTimeAbsTol );
            end
            
            if ~isempty(p.Results.PrecursorMz)
                idx = idx & this.getIndexesByPrecursorMz( p.Results.PrecursorMz, p.Results.PrecursorMzAbsTol );
            end
            
            %if ~isempty(p.Results.HighMz)
            %    idx = idx & this.getIndexesByHighMz( p.Results.HighMz, p.Results.HighMzAbsTol );
            %end
           
            if ~isempty(p.Results.Level)
                idx = idx & this.getIndexesByLevel( p.Results.Level );
            end
            
            if ~isempty(p.Results.ScanIndexes)
                iScanIndexes = p.Results.ScanIndexes;
            else
                iScanIndexes = 1:this.getScanCount();
            end

            iScanIndexes = iScanIndexes(idx);
%             n = length(iScanIndexes);
%             spectrumList = cell(1,n);
%             idxOfSpectraToRemove = false(1,n);
            spectrumList = arrayfun( @(x)(this.createSpectrum(x,varargin{:})), iScanIndexes, 'UniformOutput', false ); 
            idxOfEmptySpectra = cellfun( @hasEmptyData, spectrumList );
            spectrumList( idxOfEmptySpectra ) = [];
            
%             for i=1:n
%                 spectrumList{i} = this.createSpectrum( iScanIndexes(i), varargin{:} );
%                 idxOfSpectraToRemove(i) = hasEmptyData(spectrumList{i});
%             end
%             spectrumList( idxOfSpectraToRemove ) = [];
            
            oSpectrumSet = biotracs.spectra.data.model.MSSpectrumSet();
            if ~isempty(spectrumList)
                oSpectrumSet.setElements(spectrumList);
            end
            
        end
        
        function oSpectrum = createSpectrum( this, iScanIndex, varargin )
            p = inputParser();
            p.addParameter('Mz', []);       
            p.addParameter('MzAbsTol', 0);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            selectedData = this.data{iScanIndex};
 
            if ~isempty(p.Results.Mz)
                %mzTol = p.Results.MzAbsTol * p.Results.Mz(1) / 1e6;
                mzTol = p.Results.MzAbsTol * p.Results.Mz(1);
                [ idx ] = ismembertol( selectedData(:,1), p.Results.Mz, mzTol, 'DataScale', 1 ) ;
                selectedData = selectedData( idx, :);
            end

            if isempty(selectedData)
                oSpectrum = biotracs.spectra.data.model.MSSpectrum();
                return;
            end
            
            oSpectrum = biotracs.spectra.data.model.MSSpectrum( selectedData, this.retentionTimes(iScanIndex) );
            
            oSpectrum.setAxisLabels('MZ', 'Relative Abundance') ...
                .updateParamValue( 'Level', this.levels(iScanIndex) )...
                .updateParamValue( 'Polarity', parseScanAttrValue('polarity'))...
                .updateParamValue( 'ScanType', lower(parseScanAttrValue('scanType')));
            
            if parseScanAttrValue('centroided', '%d')
                oSpectrum.setRepresentation( biotracs.spectra.data.model.Signal.REPRESENTATION_CENTROID );
            else
                oSpectrum.setRepresentation( biotracs.spectra.data.model.Signal.REPRESENTATION_PROFILE );
            end
            
            oSpectrum.updateParamValue( 'IsDeisotoped', parseScanAttrValue('deisotoped', 'logical') );
            oSpectrum.updateParamValue( 'IsChargeDeconvoluted', parseScanAttrValue('chargeDeconvoluted', 'logical') );
            oSpectrum.updateParamValue( 'IonisationEnergy', parseScanAttrValue('ionisationEnergy', '%f') );
            oSpectrum.updateParamValue( 'CollisionEnergy', parseScanAttrValue('collisionEnergy', '%f') );
            oSpectrum.updateParamValue( 'CollisionGas', parseScanAttrValue('collisionGas') );
            oSpectrum.updateParamValue( 'CollisionGasPressure', parseScanAttrValue('collisionGasPressure', '%f') );
            oSpectrum.updateParamValue( 'StartMZ', parseScanAttrValue('startMz', '%f') );
            oSpectrum.updateParamValue( 'EndMZ', parseScanAttrValue('endMz', '%f') );
            oSpectrum.updateParamValue( 'LowMZ', parseScanAttrValue('lowMz', '%f') );
            oSpectrum.updateParamValue( 'HighMZ', parseScanAttrValue('highMz', '%f') );
            oSpectrum.updateParamValue( 'BasePeakMZ', parseScanAttrValue('basePeakMz', '%f') );
            oSpectrum.updateParamValue( 'BasePeakIntensity', parseScanAttrValue('basePeakIntensity', '%f') );
            
            if this.precursorMz(iScanIndex) > 0
                oSpectrum.updateParamValue( 'PrecursorMZ', this.precursorMz(iScanIndex) );
            end
            
            oSpectrum.updateParamValue( 'PrecursorIntensity', parsePrecursorMzAttrValue('precursorIntensity', '%f') );
            oSpectrum.updateParamValue( 'PrecursorCharge', parsePrecursorMzAttrValue('precursorCharge', '%f') );
            oSpectrum.updateParamValue( 'PrecursorScanNumber', parsePrecursorMzAttrValue('precursorScanNum', '%d') );
            
            totalIonCurrent = parseScanAttrValue('totIonCurrent','%f');
            if isempty(totalIonCurrent)
                oSpectrum.updateParamValue( 'TotalIonCurrent', sum(this.data{iScanIndex}(:,2)) );
            else
                oSpectrum.updateParamValue( 'TotalIonCurrent', totalIonCurrent );
            end
            
            %set label and description
            oSpectrum.setLabel( num2str(oSpectrum.getRetentionTime()) );
            oSpectrum.setDescription( parseScanAttrValue('comment') );
            
            function oValue = parsePrecursorMzAttrValue( iFieldName, varargin )
                if isfield(this.precursorInfo{iScanIndex}, iFieldName)
                    oValue = this.precursorInfo{iScanIndex}.(iFieldName);
                else
                    oValue = '';
                end
                oValue = parseValue(oValue, varargin{:});
            end
            
            function oValue = parseScanAttrValue( iFieldName, varargin )
                if isfield(this.scanInfo{iScanIndex}, iFieldName)
                    oValue = this.scanInfo{iScanIndex}.(iFieldName);
                else
                    oValue = '';
                end
                oValue = parseValue(oValue, varargin{:});
            end
            
            function oValue = parseValue( iValue, iType )
                oValue = iValue;
                if nargin == 1
                    return;
                end

                switch iType
                    case {'integer','%d'}
                        if isempty(oValue), oValue = '0'; end
                        oValue = sscanf(oValue,'%d');
                    case {'float','%f'}
                        if isempty(oValue), oValue = '0'; end
                        oValue = sscanf(oValue,'%f');
                    case {'logical'}
                        if isempty(oValue), oValue = '0'; end
                        oValue = logical(sscanf(oValue,'%d'));
                    otherwise
                        oValue = sscanf(oValue,iType);
                end
            end
        end
        
    end
    
    % -------------------------------------------------------
    % Use of helper methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function this = doParseMapData( this, iData )
            if isfield(iData, 'msRun')
                n = length(iData.msRun.val__.scan);
                this.retentionTimes = cellfun( ...
                    @(x)(sscanf(x.attr__.retentionTime,'PT%fS')), ...
                    iData.msRun.val__.scan, ...
                    'UniformOutput', true, ...
                    'ErrorHandler', @(err,x)(-1) ...
                    );
                this.retentionTimes = reshape(this.retentionTimes,1,n);
                
                 this.highMz = cellfun( ...
                    @(x)(sscanf(x.attr__.highMz,'%f')), ...
                    iData.msRun.val__.scan, ...
                    'UniformOutput', true, ...
                    'ErrorHandler', @(err,x)(-1) ...
                    );
                this.highMz = reshape(this.highMz,1,n);
                
                this.levels = cellfun( ...
                    @(x)(sscanf(x.attr__.msLevel,'%d')), ...
                    iData.msRun.val__.scan, ...
                    'UniformOutput', true, ...
                    'ErrorHandler', @(err,x)(-1) ...
                    );
                this.levels = reshape(this.levels,1,n);
                
                this.precursorMz = cellfun( ...
                    @(x)(sscanf(x.val__.precursorMz.val__,'%f')), ...
                    iData.msRun.val__.scan, ...
                    'UniformOutput', true, ...
                    'ErrorHandler', @(err,x)(-1) ...
                    );
                this.precursorMz = reshape(this.precursorMz,1,n);
                
                this.scanInfo = cellfun( ...
                    @(x)(x.attr__), ...
                    iData.msRun.val__.scan, ...
                    'UniformOutput', false, ...
                    'ErrorHandler', @(err,x)([]) ...
                    );
                
                this.precursorInfo = cellfun( ...
                    @(x)(x.val__.precursorMz.attr__), ...
                    iData.msRun.val__.scan, ...
                    'UniformOutput', false, ...
                    'ErrorHandler', @(err,x)([]) ...
                    );
                
                this.data = this.doParseScanDataStreamMap(iData);
            else
                error('Invalid stream map');
            end
        end

        function data = doParseScanDataStreamMap( ~, mzXMLData )
            b64 = org.apache.commons.codec.binary.Base64();
            [~,~,endian] = computer();
            precision = mzXMLData.msRun.val__.scan{1}.val__.peaks.attr__.precision;     
            data = cellfun( ...
                @(x)(b64decode(x.val__.peaks.val__)), ...
                mzXMLData.msRun.val__.scan, ...
                'UniformOutput', false, ...
                'ErrorHandler', @(err,x)([]) ...
                );
            function mzpeaks = b64decode( data )
                switch endian
                    case 'L'
                        if precision == '32'
                            mzpeaks = swapbytes(typecast(b64.decode(unicode2native(data)),'single'));
                        else
                            mzpeaks = swapbytes(typecast(b64.decode(unicode2native(data)),'double'));
                        end
                    otherwise
                        if precision == '32'
                            mzpeaks = typecast(b64.decode(unicode2native(data)),'single');
                        else
                            mzpeaks = typecast(b64.decode(unicode2native(data)),'double');
                        end
                end
                n = length(mzpeaks)/2;
                mzpeaks = reshape(mzpeaks,2,n)';
            end
        end
        
    end
    
    % -------------------------------------------------------
    % Static
    % -------------------------------------------------------
    
    methods(Static)
        
        %-- C --
        
        %-- F --

        %-- I --
        
        %> @param[in] iFilePath a file or folder path
        %> @param[in] Options used to configure biotracs.spectra.parser.model.MzxmlParsingProtocol
        %> @return a biotracs.spectra.data.model.MSSpectrumMap if only one raw data file is imported
        %> @return a biotracs.core.mvc.ResourceSet containing a set of
        %> biotracs.spectra.data.model.MSSpectrumMap if a list a raw data file is imported
        function [ result ] = import( iFilePath, varargin )
            process = biotracs.spectra.parser.model.MzxmlParser();
            c = process.getConfig();
            c.hydrateWith(varargin);
            process.setInputPortData( 'DataFile', biotracs.data.model.DataFile(iFilePath) );
            process.run();
            result = process.getOutputPortData('ResourceSet');
            if result.getLength() == 1
                result = result.getAt(1);
            end
        end

    end
end
