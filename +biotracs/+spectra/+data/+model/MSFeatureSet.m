% BIOASTER
%> @file 		MSFeatureSet.m
%> @class 		biotracs.spectra.data.model.MSFeatureSet
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef MSFeatureSet < biotracs.data.model.DataSet
    
    properties(SetAccess = protected)
        
    end
    
    properties(Dependent = true)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        %> @param[in] iData Array of double || biotracs.spectra.data.model.MSFeatureSet
        %> @param[in] iColumnNames [optional] Cell of string
        %> @param[in] iRowNames [optional] Cell of string
        function this = MSFeatureSet( iData, varargin )
            if nargin == 0, iData = []; end
            this@biotracs.data.model.DataSet( iData, varargin{:} );
            this.bindView( biotracs.spectra.data.view.MSFeatureSet() );
            
            this.meta.rowNameKeyValPatterns = struct(...
                'BatchPattern', 'Batch:([^_]*)', ...
                'SamplePattern', 'SampleType:Sample', ...
                'QcPattern', 'SampleType:QC', ...
                'SequenceNumberPattern', 'SequenceNumber:([^_]*)', ...
                'PolarityPattern', 'Polarity:([^_]*)' ...
                );
        end
        
        %-- C --
        
        function [ seqNum ] = getSequenceNumbers( this )
            pattern = this.meta.rowNameKeyValPatterns.SequenceNumberPattern;
            tab = regexp(this.rowNames,pattern,'tokens');
            seqNum = cellfun( @(x)(x{1}{1}), tab, 'UniformOutput', false, 'ErrorHandler', @(x,varargin)('') );
            seqNum = str2double(seqNum);
        end
        
        %-- E --
        
        %-- G --
        
        function pattern = getRowNameKeyValPatterns( this, varargin )
            pattern = this.meta.rowNameKeyValPatterns;
        end
        
        function batchIndexes = getBatchIndexes( this, varargin )
            pattern = this.meta.rowNameKeyValPatterns.BatchPattern;
            tab = regexp(this.rowNames,pattern,'tokens');
            batchIndexes = cellfun( @(x)(x{1}{1}), tab, 'UniformOutput', false, 'ErrorHandler', @(x,varargin)('') );
            batchIndexes = unique(batchIndexes);
            batchIndexes = batchIndexes( ~strcmp(batchIndexes,'') );
        end
        
        %-- S --
        
        function this = setRowNameKeyValPatterns( this, varargin )
            p = inputParser();
            p.addParameter('BatchPattern', this.meta.rowNameKeyValPatterns.BatchPattern, @ischar);
            p.addParameter('SamplePattern', this.meta.rowNameKeyValPatterns.SamplePattern, @ischar);
            p.addParameter('QcPattern', this.meta.rowNameKeyValPatterns.QcPattern, @ischar);
            p.addParameter('SequenceNumberPattern', this.meta.rowNameKeyValPatterns.SequenceNumberPattern, @ischar);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            this.meta.rowNameKeyValPatterns.BatchPattern = p.Results.BatchPattern;
            this.meta.rowNameKeyValPatterns.SamplePattern = p.Results.SamplePattern;
            this.meta.rowNameKeyValPatterns.QcPattern = p.Results.QcPattern;
            this.meta.rowNameKeyValPatterns.SequenceNumberPattern = p.Results.SequenceNumberPattern;
        end
        
        function [ qcFeatureSetContainer, sampleFeatureSetContainer, otherFeatureSetContainer ] = split( this )
            [qcFeatureSetContainer, sampleFeatureSetContainer, otherFeatureSetContainer] = biotracs.spectra.helper.SampleSplitter.split( this );
        end
        
        %-- R --
        
        function positions = getVariablePositions( this, varargin )
            names = this.getColumnNames();
            positions = str2double(names);
            if any(isnan( positions ))
                [~, positions, ~] = this.getMzRtPolarity( );
                positions = str2double(positions);
            end
        end
    
        function [mz, rt, polarity] = getMzRtPolarity( this )
            if ~this.hasResponses()
                colNames = this.columnNames;
            else
                idx = this.getInputIndexes();
                colNames = this.columnNames(idx);
            end
            
            mzTab = regexp(colNames,'M(\d+.\d*)','tokens');
            rtTab = regexp(colNames,'T(\d+.\d*)','tokens');
            polTab = regexp(colNames,'(Neg|Pos)$','tokens');
            mz = cellfun( @(x)(x{1}{1}), mzTab, 'UniformOutput', false, 'ErrorHandler', @(x,varargin)('') );
            rt = cellfun( @(x)(x{1}{1}), rtTab, 'UniformOutput', false, 'ErrorHandler', @(x,varargin)('') );
            polarity = cellfun( @(x)(x{1}{1}), polTab, 'UniformOutput', false, 'ErrorHandler', @(x,varargin)('') );
        end

        %-- T --
        
    end
    
    methods(Static)
        
        function this = fromDataObject( iDataObject )
            if ~isa( iDataObject, 'biotracs.data.model.DataObject' )
                error('A ''biotracs.data.model.DataObject'' is required');
            end
            this = biotracs.spectra.data.model.MSFeatureSet();
            this.doCopy( iDataObject );
        end
        
        function this = fromFeatureSet( iFeatureSet )
            if isa( iFeatureSet, 'biotracs.spectra.data.model.MSFeatureSet' )
                this = iFeatureSet.copy();
            else
                error('A ''biotracs.spectra.data.model.MSFeatureSet'' is required');
            end
        end
        
        function this = fromDataSet( iDataSet )
            if isa( iDataSet, 'biotracs.data.model.DataSet' )
                this = biotracs.spectra.data.model.MSFeatureSet();
                this.doCopy( iDataSet );
            else
                error('A ''biotracs.data.model.DataSet'' is required');
            end
        end
        
        function this = fromDataMatrix( iDataMatrix )
            if isa( iDataMatrix, 'biotracs.data.model.DataMatrix' )
                this = biotracs.spectra.data.model.MSFeatureSet( );
                this.doCopy(iDataMatrix);
            else
                error('A ''biotracs.data.model.DataMatrix'' is required');
            end
        end

        function this = fromDataTable( iDataTable )
            if isa( iDataTable, 'biotracs.data.model.DataTable' )
                try
                    this = biotracs.spectra.data.model.MSFeatureSet( );
                    this.doCopy( iDataTable );
                catch err
                    error('The inner data of the DataTable is not compatible. Only numeric or cell-of-numeric array are compatible\n%s', err.message);
                end
            else
                error('A ''biotracs.data.model.DataTable'' is required');
            end
        end
        
        function [ this ] = import( iFilePath, varargin )
            isTableClassDefined = any(strcmpi(varargin, 'TableClass'));
            if ~isTableClassDefined
                varargin = [varargin, {'TableClass', 'biotracs.spectra.data.model.MSFeatureSet'}];
            end
            this = biotracs.data.model.DataMatrix.import(iFilePath, varargin{:});
            this.setRowNameKeyValPatterns( varargin{:} );
        end
        
    end
    
    methods(Access = protected)

    end
    
end

