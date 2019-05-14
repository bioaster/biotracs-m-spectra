% BIOASTER
%> @file 		MSFeatureTable.m
%> @class 		biotracs.spectra.data.model.MSFeatureTable
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef MSFeatureTable < biotracs.data.model.DataTable
    
    properties
        MIN_COLUMN_NAMES = { 'Id', 'Mz', 'Rt', 'Polarity', 'IsoFeatureGroup',  'Adduct' };
    end
    
    properties(SetAccess = protected)
    end
    
    methods
        
        % Constructor
        function this = MSFeatureTable( )
            this@biotracs.data.model.DataTable();
            this.setData( cell(0,length(this.MIN_COLUMN_NAMES)) );
            this.setColumnNames( this.MIN_COLUMN_NAMES );
        end
        
    end

    
end

