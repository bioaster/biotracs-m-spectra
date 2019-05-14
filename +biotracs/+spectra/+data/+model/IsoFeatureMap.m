% BIOASTER
%> @file		IsoFeatureMap.m
%> @class		biotracs.spectra.data.model.IsoFeatureMap
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef IsoFeatureMap < biotracs.data.model.DataObject
    
    properties(Constant)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = IsoFeatureMap( varargin )
            this@biotracs.data.model.DataObject();
            if nargin >= 1
                if ~iscell(varargin{1})
                    error('SPECTRA:IsoFeatureMap:InvalidArgument','The map data must be a cell')
                end
                this.setData( varargin{1} );
            end
            
            if nargin >= 2
                if ~iscellstr(varargin{2})
                    error('SPECTRA:IsoFeatureMap:InvalidArgument','The varible name must be a cell of string')
                end
                if length(this.data) ~= length(varargin{2})
                    error('SPECTRA:IsoFeatureMap:InvalidArgument','The number of variable names mus be equal to the size of the map');
                end
                this.setMeta( struct('VariableNames', {varargin{2}}) );
            end
        end
        
        function export( this, iFilePath )
            [~, ~, ext] = fileparts( iFilePath );
            switch lower(ext)
                case {'.csv', '.xlsx', '.xls', '.txt'}
                    dataTable = this.toDataTable();
                    dataTable.export(iFilePath);
                otherwise
                    this.export@biotracs.data.model.DataObject(iFilePath);
            end
        end
        
        function names = getVariableNames( this )
            names = this.getMeta('VariableNames');
        end
        
        function summary(this, varargin)
            this.toDataTable().summary( varargin{:} );
        end
        
        function dataTable = toDataTable( this )
            n = length( this.data );
            listOfLengths = cellfun( @length, this.data );
            maxLen = max(listOfLengths);
            data = repmat({''},n,maxLen);
            for i=1:n
                isofeatureIndexes = arrayfun( @num2str, this.data{i}, 'UniformOutput', false );
                q = length(isofeatureIndexes);
                data(i,1:q) = isofeatureIndexes;
            end

            dataTable = biotracs.data.model.DataTable(data,'Map', this.getVariableNames());
        end
        
    end
    
end
