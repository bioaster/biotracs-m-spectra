% BIOASTER
%> @file 		NMRFeatureSet.m
%> @class 		biotracs.spectra.data.model.NMRFeatureSet
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef NMRFeatureSet < biotracs.data.model.DataSet
    
    properties(SetAccess = protected)
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        %> @param[in] iData Array of double
        %> @param[in] iColumnNames [optional] Cell of string
        %> @param[in] iRowNames [optional] Cell of string
        function this = NMRFeatureSet( varargin )
            this@biotracs.data.model.DataSet( varargin{:} );
        end
        
        %-- C --

        %-- E --
        
        %-- G --
        
        function [ delta ] = getChemicalShifts( this )
            if ~this.hasResponses
                delta = str2double( this.columnNames );
            else
                idx = this.getInputIndexes();
                delta = str2double( this.columnNames(idx) );
            end
        end
        
        %-- S --
        
        function [ dataSet ] = selectChemicalShiftRange( this, iRange )
            if length(iRange) ~= 2
                error('Invalid range. The range must be a 1 by 2 array.');
            end
            delta = this.getChemicalShifs();
            idx = (delta > iRange(1) & delta <= iRange(2));
            dataSet = this.selectByColumnIndexes(idx);
        end
        
        %-- R --
    

        %-- T --
        
        
    end
    
    methods(Static)    
        
        function this = fromDataObject( iDataObject )
            if ~isa( iDataObject, 'biotracs.data.model.DataObject' )
                error('A ''biotracs.data.model.DataObject'' is required');
            end
            this = biotracs.spectra.data.model.NMRFeatureSet();
            this.doCopy( iDataObject );
        end
        
        function this = fromDataTable( iDataTable )
            if ~isa( iDataTable, 'biotracs.data.model.DataTable' )
                error('A ''biotracs.data.model.DataTable'' is required');
            end
            this = biotracs.spectra.data.model.NMRFeatureSet();
            this.doCopy( iDataTable );
        end
        
        function this = fromDataMatrix( iDataMatrix )
            if ~isa( iDataMatrix, 'biotracs.data.model.DataMatrix' )
                error('A ''biotracs.data.model.DataMatrix'' is required');
            end
            this = biotracs.spectra.data.model.NMRFeatureSet();
            this.doCopy( iDataMatrix );
        end
        
        function this = fromDataSet( iDataSet )
            if ~isa( iDataSet, 'biotracs.data.model.DataSet' )
                error('A ''biotracs.data.model.DataSet'' is required');
            end
            this = biotracs.spectra.data.model.NMRFeatureSet();
            this.doCopy( iDataSet );      
        end
        
    end
    
    
    methods(Access = protected)
    end
    
end

