% BIOASTER
%> @file		MSSpectrum.m
%> @class		biotracs.spectra.data.model.MSSpectrum
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2014

classdef MSSpectrum < biotracs.spectra.data.model.Signal
    
    properties(Constant)
        SCAN_TYPE_LIST = {'full','sim'};
        POLARITY_LIST = {'+','-'};
    end
    
    properties(Dependent = true)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        %> @param[in] iValues N-by-2 array of double
        function this = MSSpectrum( iData, iRetentionTime )
            this@biotracs.spectra.data.model.Signal();
            
            if nargin == 0
                this.setData( zeros(0,2) );
                this.setAxisLabels('MZ','Relative Abundance');
            elseif isa(iData, 'biotracs.data.model.DataMatrix')
                if isa(iData, 'biotracs.spectra.data.model.Signal')
                    this.setData( iData.data );
                    this.doCopy( iData );
                else
                    %sort indexes in ascending order
                    if ~isempty(iData.data)
                        if ~issorted(iData.data(:,1))
                            this.setData( sortrows(iData.data) );
                        else
                            this.setData( iData.data );
                        end
                        this.doCopy( iData );
                        this.setAxisLabels('MZ','Relative Abundance');
                        if nargin >= 2
                            this.updateParamValue('RetentionTime', iRetentionTime);
                        end
                    else
                        this.setData( zeros(0,2) );
                        this.setAxisLabels('MZ','Relative Abundance');
                    end
                end
            elseif isnumeric(iData)
                %sort indexes in ascending order
                if ~isempty(iData)
                    if ~issorted(iData(:,1)), iData = sortrows(iData); end
                else
                    iData = zeros(0,2);
                end
                this.setData( iData );
                this.setAxisLabels('MZ','Relative Abundance');
                if nargin >= 2
                    this.updateParamValue('RetentionTime', iRetentionTime);
                end
            else
                error('Invalid argument; a numeric array is required');
            end
            
        end
        
    end
    
    
    methods
        %-- C--
        
        %-- G --
        
        %> @return level [integer]
        function level = getLevel(this)
            level = this.getParamValue('Level');
        end
        
        %> @return polarity ['positive' or 'negative']
        function polarity = getPolarity(this)
            polarity = this.getParamValue('Polarity');
        end
        
        %> @return scan type ['full', 'sim', 'srm' or 'mrm']
        function scanType = getScanType(this)
            scanType = this.getParamValue('ScanType');
        end
        
        %> @return true | false
        function tf = getIsDeisotoped(this)
            tf = this.getParamValue('IsDeisotoped');
        end
        
        %> @return true | false
        function tf = getIsChargeDeconvoluted(this)
            tf = this.getParamValue('IsChargeDeconvoluted');
        end
        
        %> @return retention time [double]
        function rt = getRetentionTime(this)
            rt = this.getParamValue('RetentionTime');
        end
        
        %> @return ionisation energy [double]
        function ie = getIonisationEnergy(this)
            ie = this.getParamValue('IonisationEnergy');
        end
        
        %> @return collision energy [double]
        function ce = getCollisionEnergy(this)
            ce = this.getParamValue('CollisionEnergy');
        end
        
        %> @return collision gas [string]
        function cg = getCollisionGas(this)
            cg = this.getParamValue('CollisionGas');
        end
        
        %> @return collision gas pressure [double]
        function cgp = getCollisionGasPressure(this)
            cgp = this.getParamValue('CollisionGasPressure');
        end
        
        %> @return stating acquisition mz [double]
        function mz = getStartMz(this)
            mz = this.getParamValue('StartMZ');
        end
        
        %> @return ending acquisition mz [double]
        function mz = getEndMz(this)
            mz = this.getParamValue('EndMZ');
        end
        
        %> @return lowest mz mesured [double]
        function mz = getLowMz(this)
            mz = this.getParamValue('LowMZ');
        end
        
        %> @return highest mz mesured [double]
        function mz = getHighMz(this)
            mz = this.getParamValue('HighMZ');
        end
        
        %> @return base peak mz [double]
        function mz = getBasePeakMz(this)
            mz = this.getParamValue('BasePeakMZ');
        end
        
        %> @return base peak intensity [double]
        function int = getBasePeakIntensity(this)
            int = this.getParamValue('BasePeakIntensity');
        end
        
        %> @return total ion current [double]
        function tic = getTotalIonCurrent(this)
            tic = this.getParamValue('TotalIonCurrent');
        end
        
        %> @param[in] precursor Mz [double]
        function mz = getPrecursorMz(this)
            mz = this.getParamValue('PrecursorMZ');
        end
        
        %> @param[in] precursor intensity [double]
        function pi = getPrecursorIntensity(this)
            pi = this.getParamValue('PrecursorIntensity');
        end
        
        %> @param[in] precursor charge [integer]
        function pc = getPrecursorCharge(this)
            pc = this.getParamValue('PrecursorCharge');
        end
        
        %> @param[in] precursor scan number [integer]
        function sn = getPrecursorScanNumber(this)
            sn = this.getParamValue('PrecursorScanNumber');
        end
        
        %----------------------------------------------------------------
        %-- S --
        %----------------------------------------------------------------
        
        %> @param[in] level [integer]
        function this = setLevel(this, iValue)
            this.updateParamValue('Level', iValue);
        end
        
        %> @param[in] polarity ['positive' or 'negative']
        function this = setPolarity(this, iValue)
            this.updateParamValue('Polarity', iValue);
        end
        
        %> @param[in] scan type ['full', 'sim', 'srm' or 'mrm']
        function this = setScanType(this, iValue)
            this.updateParamValue('ScanType', iValue);
        end
        
        %> @param[in] true | false
        function this = setIsDeisotoped(this, iValue)
            this.updateParamValue('IsDeisotoped', iValue);
        end
        
        %> @param[in] true | false
        function this = setIsChargeDeconvoluted(this, iValue)
            this.updateParamValue('IsChargeDeconvoluted', iValue);
        end
        
        %> @param[in] retention time [double]
        function this = setRetentionTime(this, iValue)
            this.updateParamValue('RetentionTime', iValue);
        end
        
        %> @param[in] ionisation energy [double]
        function this = setIonisationEnergy(this, iValue)
            this.updateParamValue('IonisationEnergy', iValue);
        end
        
        %> @param[in] collision energy [double]
        function this = setCollisionEnergy(this, iValue)
            this.updateParamValue('CollisionEnergy', iValue);
        end
        
        %> @param[in] collision gas [string]
        function this = setCollisionGas(this, iValue)
            this.updateParamValue('CollisionGas', iValue);
        end
        
        %> @param[in] collision gas pressure [double]
        function this = setCollisionGasPressure(this, iValue)
            this.updateParamValue('CollisionGasPressure', iValue);
        end
        
        %> @param[in] stating acquisition mz [double]
        function this = setStartMz(this, iValue)
            this.updateParamValue('StartMZ', iValue);
        end
        
        %> @param[in] ending acquisition mz [double]
        function this = setEndMz(this, iValue)
            this.updateParamValue('EndMZ', iValue);
        end
        
        %> @param[in] lowest mz mesured [double]
        function this = setLowMz(this, iValue)
            this.updateParamValue('LowMZ', iValue);
        end
        
        %> @param[in] highest mz mesured [double]
        function this = setHighMz(this, iValue)
            this.updateParamValue('HighMZ', iValue);
        end
        
        %> @param[in] base peak mz [double]
        function this = setBasePeakMz(this, iValue)
            this.updateParamValue('BasePeakMZ', iValue);
        end
        
        %> @param[in] base peak intensity [double]
        function this = setBasePeakIntensity(this, iValue)
            this.updateParamValue('BasePeakIntensity', iValue);
        end
        
        %> @param[in] total ion current [double]
        function this = setTotalIonCurrent(this, iValue)
            this.updateParamValue('TotalIonCurrent', iValue);
        end
        
        %> @param[in] precursor Mz [double]
        function this = setPrecursorMz(this, iValue)
            this.updateParamValue('PrecursorMZ', iValue);
        end
        
        %> @param[in] precursor intensity [double]
        function this = setPrecursorIntensity(this, iValue)
            this.updateParamValue('PrecursorIntensity', iValue);
        end
        
        %> @param[in] precursor charge [integer]
        function this = setPrecursorCharge(this, iValue)
            this.updateParamValue('PrecursorCharge', iValue);
        end
        
        %> @param[in] precursor scan number [integer]
        function this = setPrecursorScanNumber(this, iValue)
            this.updateParamValue('PrecursorScanNumber', iValue);
        end
        
    end
    
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doCopy( this, iSpectrum, varargin )
            this.doCopy@biotracs.spectra.data.model.Signal( iSpectrum, varargin{:} );
        end
        
        function doCreateAllParams( this )
            this.doCreateAllParams@biotracs.spectra.data.model.Signal();
            this.createParam('Level',                   [],     'Constraint', biotracs.core.constraint.IsGreaterThan(1));
            this.createParam('Polarity',                [],     'Constraint', biotracs.core.constraint.IsInSet({'+','-'}));
            this.createParam('ScanType',                [],     'Constraint', biotracs.core.constraint.IsInSet({'full', 'sim', 'srm', 'mrm'}));
            this.createParam('IsDeisotoped',            false,  'Constraint', biotracs.core.constraint.IsBoolean());
            this.createParam('IsChargeDeconvoluted',    false,  'Constraint', biotracs.core.constraint.IsBoolean());
            this.createParam('RetentionTime',           [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('IonisationEnergy',        [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('CollisionEnergy',         [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('CollisionGas',            '',     'Constraint', biotracs.core.constraint.IsText());
            this.createParam('CollisionGasPressure',    [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('StartMZ',                 [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('EndMZ',                   [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('LowMZ',                   [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('HighMZ',                  [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('BasePeakMZ',              [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('BasePeakIntensity',       [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('TotalIonCurrent',         [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('PrecursorMZ',             [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('PrecursorIntensity',      [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('PrecursorCharge',         [],     'Constraint', biotracs.core.constraint.IsPositive());
            this.createParam('PrecursorScanNumber',     [],     'Constraint', biotracs.core.constraint.IsPositive( 'Type', 'integer' ));
        end
        
    end
    
    % -------------------------------------------------------
    % Static methods
    % -------------------------------------------------------
    
    methods(Static)
        
        function this = fromDataObject( iDataObject )
            if ~isa( iDataObject, 'biotracs.data.model.DataObject' )
                error('A ''biotracs.data.model.DataObject'' is required');
            end
            this = biotracs.spectra.data.model.MSSpectrum();
            this.doCopy( iDataObject );
        end
        
        function this = fromDataTable( iDataTable )
            if ~isa( iDataTable, 'biotracs.data.model.DataTable' )
                error('A ''biotracs.data.model.DataTable'' is required');
            end
            this = biotracs.spectra.data.model.MSSpectrum();
            this.doCopy( iDataTable );
        end
        
        function this = fromDataMatrix( iDataMatrix )
            if ~isa( iDataMatrix, 'biotracs.data.model.DataMatrix' )
                error('A ''biotracs.data.model.DataMatrix'' is required');
            end
            this = biotracs.spectra.data.model.MSSpectrum();
            this.doCopy( iDataMatrix );
        end
        
        function this = fromDataSet( iDataSet )
            if ~isa( iDataSet, 'biotracs.data.model.DataSet' )
                error('A ''biotracs.data.model.DataSet'' is required');
            end
            this = biotracs.spectra.data.model.MSSpectrum();
            this.doCopy( iDataSet );      
        end
        
        function this = fromSignal( iSignal )
            if ~isa( iSignal, 'biotracs.spectra.data.model.Signal' )
                error('A ''biotracs.spectra.data.model.Signal'' is required');
            end
            this = biotracs.spectra.data.model.MSSpectrum();
            this.doCopy( iSignal );      
        end
        
        %> Creation of a Spectrum using a mzXML scan parsed in a mzXML structure by mzxmlread
        
        
        function this = import( iFilePath, varargin )
            dataMatrix = biotracs.data.model.DataMatrix.import( iFilePath, varargin{:} );
            this = biotracs.spectra.data.model.MSSpectrum(dataMatrix);
        end
        
    end
    
end
