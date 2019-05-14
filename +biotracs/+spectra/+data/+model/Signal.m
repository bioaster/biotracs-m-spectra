% BIOASTER
%> @file		Signal.m
%> @class		biotracs.spectra.data.model.Signal
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef Signal < biotracs.data.model.DataMatrix
    
    properties(Constant)
        % ***
        % * @ToDo: Use 'Discrete/Continuous' representations
        % ***
        REPRESENTATION_PROFILE = 'profile';
        REPRESENTATION_CENTROID = 'centroid';
        DEFAULT_REPRESENTATION = biotracs.spectra.data.model.Signal.REPRESENTATION_PROFILE;
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = Signal( iData )
            this@biotracs.data.model.DataMatrix(); 
            
            if nargin == 0
                this.setData( zeros(0,2) ); 
            else
                this.setData( iData );
            end
            this.setXAxisLabel('Intentity Index');
            this.setYAxisLabel('Intensity');
            this.doCreateAllParams();
            
            this.bindView( biotracs.spectra.data.view.Signal() );
        end
        
        %-- C --
        
        function [ int ] = computeTotalIntensity( this, varargin )
            int = sum( this.data(:,2) );
        end 
        
        function [ int ] = computeAverageIntensity( this, varargin )
            int = mean( this.data(:,2) );
        end 

        function [ int ] = computeMaxIntensity( this, varargin )
            int = max( this.data(:,2) );
        end 
        
        function [ int ] = computeMinIntensity( this, varargin )
            int = min( this.data(:,2) );
        end 
        
        %-- B --
        
        %> @return The result of a biotracs.spectra.sigproc.model.BinningProtocol
        function [result] = bin( this, varargin )
            p = inputParser();
            p.addParameter('BinWidth',0,@isscalar);
            p.addParameter('Range',[],@isnumeric);
            p.addParameter('BinVector',[],@isnumeric);
            p.KeepUnmatched = true;
            p.parse(varargin{:});

            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', this);
            c = process.getConfig();
            c.updateParamValue('BinWidth',p.Results.BinWidth);
            c.updateParamValue('BinTicks',p.Results.BinVector);
            c.updateParamValue('Range',p.Results.Range);
            process.run();
            result = process.getOutputPortData('Result');
        end
        
        %-- G --
        
        function oName = getXAxisLabel( this )
            oName = this.getColumnName(1);
            %oName = this.getParamValue('XAxisLabel');
        end
        
        function oName = getYAxisLabel( this )
            oName = this.getColumnName(2);
            %oName = this.getParamValue('YAxisLabel');
        end
        
        function oRep = getRepresentation( this )
            oRep = this.getParamValue('Representation');
        end
        
        % Overload getLength()
        function len = getLength( this )
            len = this.getNbRows();
        end
        
        %-- I --
        
        function tf = isCentroided( this )
            tf = this.isParamValueEqual( 'Representation', biotracs.spectra.data.model.Signal.REPRESENTATION_CENTROID );
        end
        
        function tf = isResampled( this )
            tf = this.getParamValue( 'IsResampled' );
        end
        
        %-- L --

        %-- S --
        
        function this = setXAxisLabel( this, iXAxisLabel )
            this.setColumnName(1, iXAxisLabel);
        end
        
        function this = setYAxisLabel( this, iYAxisLabel )
            this.setColumnName(2, iYAxisLabel);
        end
        
        function this = setAxisLabels( this, iXAxisLabel, iYAxisLabel )
            this.setColumnNames({iXAxisLabel, iYAxisLabel});
        end

        function this = setRepresentation( this, iRepresentation )
            this.updateParamValue('Representation', iRepresentation);
        end
        
        %-- P --
        
        % Preak picking to compute the centroid of all peaks in a signal
        %> @param[in] Optional @see mspeaks() optional arguments 
        %> @return The result of a biotracs.spectra.sigproc.model.PeakPickingProtocol
        function [ result ] = pickPeaks( this, varargin )
            process = biotracs.spectra.sigproc.model.PeakPicker();
            process.setInputPortData('SignalSet', this);
            process.run();
            result = process.getOutputPortData('Result');
        end
        
        %-- R --
        
        % Resample a 1D signal while preserving peaks.
        % The resampled signal has N equally spaced samples
        % If the requested number of points is too low so that information
        % is lost, a warning if displayed. If the number of points is not
        % provided, it is automatically computed to preserve information.
        % The resampled signal is a DataMatrix containing [X, Y] data
        % X is a N-by-1 matrix of common X after resampling.
        % Y a N-by-1 matrix containing the intensity of the signal at given X
        %> @use msppresample() Matlab function.
        %> @return The result of a biotracs.spectra.sigproc.model.ResamplingProtocol
        function [ result ] = resample( this, varargin )
            process = biotracs.spectra.sigproc.model.Resampler();
            process.setInputPortData('SignalSet', this);
            c = process.getConfig();
            c.hydrateWith( varargin );
            process.run();
            result = process.getOutputPortData('Result');
        end

        %-- S --
        
        % Overload
        % Check that size of iData
        function this = setData( this, iData, iResetNames )
            if nargin < 3, iResetNames = true; end
            this.setData@biotracs.data.model.DataMatrix( iData, iResetNames );
        end
        
        %-- V --
                
    end
    
    % -------------------------------------------------------
    % Static methods
    % -------------------------------------------------------
    
    methods(Static)

        function this = import( iFilePath, varargin )
            dataTable = biotracs.data.model.DataTable.import( iFilePath, varargin{:} );            
            try
                this = biotracs.spectra.data.model.Signal.fromDataTable(dataTable);
            catch err
                error('%s\nCannot convert the DataTable to Signal', err.message);
            end
        end
        
        function this = fromDataObject( iDataObject )
            if ~isa( iDataObject, 'biotracs.data.model.DataObject' )
                error('A ''biotracs.data.model.DataObject'' is required');
            end
            this = biotracs.spectra.data.model.Signal();
            this.doCopy( iDataObject );
        end
        
        function this = fromDataTable( iDataTable )
            if ~isa( iDataTable, 'biotracs.data.model.DataTable' )
                error('A ''biotracs.data.model.DataTable'' is required');
            end
            this = biotracs.spectra.data.model.Signal();
            this.doCopy( iDataTable );
        end
        
        function this = fromDataMatrix( iDataMatrix )
            if ~isa( iDataMatrix, 'biotracs.data.model.DataMatrix' )
                error('A ''biotracs.data.model.DataMatrix'' is required');
            end
            this = biotracs.spectra.data.model.Signal();
            this.doCopy( iDataMatrix );
        end
        
        function this = fromDataSet( iDataSet )
            if ~isa( iDataSet, 'biotracs.data.model.DataSet' )
                error('A ''biotracs.data.model.DataSet'' is required');
            end
            this = biotracs.spectra.data.model.Signal();
            this.doCopy( iDataSet );      
        end
        
        function this = fromSignal( iSignal )
            if ~isa( iSignal, 'biotracs.spectra.data.model.Signal' )
                error('A ''biotracs.spectra.data.model.Signal'' is required');
            end
            this = biotracs.spectra.data.model.Signal();
            this.doCopy( iSignal );      
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)

        function doCreateAllParams( this )
            this.createParam('IsResampled', false, 'Constraint', biotracs.core.constraint.IsBoolean());
            this.createParam('Representation', biotracs.spectra.data.model.Signal.DEFAULT_REPRESENTATION, 'Constraint', biotracs.core.constraint.IsInSet({this.REPRESENTATION_CENTROID, this.REPRESENTATION_PROFILE})); 
        end
        
        function doCheckDataType( this, iData )
            this.doCheckDataType@biotracs.data.model.DataMatrix( iData );
            if ~isempty(iData) && size(iData, 2) ~= 2
                error('Invalid data,  A numeric N-by-2 array is required')
            end 
        end
       
    end
    
end
