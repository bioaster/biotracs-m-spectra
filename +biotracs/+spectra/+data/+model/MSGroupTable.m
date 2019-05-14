% BIOASTER
%> @file 		MSGroupTable.m
%> @class 		biotracs.spectra.data.model.MSGroupTable
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef MSGroupTable < biotracs.data.model.DataTable
    
    properties(Constant)
        RT_COLUMN_NAME          = 'RtSearchedPrecursor';
        MZ_COLUMN_NAME          = 'MzSearchedPrecursor';
        POLARITY_COLUMN_NAME    = 'Polarity';
        ADDUCT_COLUMN_NAME      = 'Adduct';
        GROUP_COLUMN_NAME       = 'Group';
        
        DEFAULT_COLUMN_NAMES = {...
            'MzRtPol', ...
            biotracs.spectra.data.model.MSGroupTable.MZ_COLUMN_NAME, ...
            biotracs.spectra.data.model.MSGroupTable.RT_COLUMN_NAME, ...
            biotracs.spectra.data.model.MSGroupTable.POLARITY_COLUMN_NAME, ...
            biotracs.spectra.data.model.MSGroupTable.GROUP_COLUMN_NAME, ...
            biotracs.spectra.data.model.MSGroupTable.ADDUCT_COLUMN_NAME...
            };
    end
    
    methods
        
        % Constructor
        function this = MSGroupTable( varargin )
            this@biotracs.data.model.DataTable( varargin{:} );
        end

        function oData = getMasses( this )
            oData = this.getDataByColumnName( this.MZ_COLUMN_NAME );
        end
        
        function oData = getRetentionTimes( this )
            oData = this.getDataByColumnName( this.RT_COLUMN_NAME );
        end
        
        function oData = getPolarities( this )
            oData = this.getDataByColumnName( this.POLARITY_COLUMN_NAME );
        end
        
        function oData = getAdducts( this )
            oData = this.getDataByColumnName( this.ADDUCT_COLUMN_NAME );
        end
        
        function oData = getGroups( this )
            oData = this.getDataByColumnName( this.GROUP_COLUMN_NAME );
        end
        
    end

    
    methods(Static)
        
        function this = fromDataObject( iDataObject )
            if ~isa( iDataObject, 'biotracs.data.model.DataObject' )
                error('A ''biotracs.data.model.DataObject'' is required');
            end
            this = bioapps.mspreprocessing.model.GroupTable();
            this.doCopy( iDataObject );
        end
        
        function this = fromDataTable( iDataObject )
            if ~isa( iDataObject, 'biotracs.data.model.DataTable' )
                error('A ''biotracs.data.model.DataTable'' is required');
            end
            this = bioapps.mspreprocessing.model.GroupTable();
            this.doCopy( iDataObject );
        end
        
        function this = fromDataMatrix( iDataMatrix )
            if ~isa( iDataMatrix, 'biotracs.data.model.DataMatrix' )
                error('A ''biotracs.data.model.DataMatrix'' is required');
            end
            this = bioapps.mspreprocessing.model.GroupTable();
            this.doCopy( iDataMatrix );
        end
        
        function this = fromDataSet( iDataSet )
            if ~isa( iDataSet, 'biotracs.data.model.DataSet' )
                error('A ''biotracs.data.model.DataSet'' is required');
            end
            this = bioapps.mspreprocessing.model.GroupTable();
            this.doCopy( iDataSet );
        end
        
        function this = import( iFilePath, varargin )
            this = biotracs.data.model.DataTable.import( ...
                iFilePath, ...
                varargin{:}, ...
                'TableClass', 'bioapps.mspreprocessing.model.GroupTable' ...
                );
        end
        
    end
    
end

