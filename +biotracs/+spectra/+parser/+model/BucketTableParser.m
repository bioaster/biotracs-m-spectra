% BIOASTER
%> @file		BucketTableParser.m
%> @class		biotracs.spectra.parser.model.BucketTableParser
%> @brief       Parse a bucket table created using the Amix software
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef BucketTableParser < biotracs.parser.model.TableParser
    
    properties(SetAccess = private)
        parsedSpectrumSet;
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        % Constructor
        function this = BucketTableParser()
            this@biotracs.parser.model.TableParser();
        end
        
    end
    
    methods(Access = protected)

        function [ result ] = doParse( this, iFilePath, varargin  )
            [ dataSet ] = this.doParse@biotracs.parser.model.TableParser( iFilePath, varargin{:} );
            dataSet = biotracs.data.model.DataSet.fromDataTable(dataSet);
            delta = this.doExtractChemicalShifts( dataSet );
            deltaRanges = this.config.getParamValue('ChemicalShiftRanges');
            
            if ~isempty(deltaRanges)
                m = size(deltaRanges, 2);
                if m ~= 2
                    error('The ChemicalShiftRanges must be a N-by-2 matrix');
                end
                
                allIndexesToSelect = false(size(delta));
                for i=1:size(deltaRanges,1)
                    allIndexesToSelect = allIndexesToSelect | (delta >= deltaRanges(i,1) & delta <= deltaRanges(i,2));
                end

                hasToSelectDeltaRange = ~all(allIndexesToSelect);
                if hasToSelectDeltaRange
                    [nrows, ncols] = getSize(dataSet);
                    extendedIndexes = find(~allIndexesToSelect);
                    extendedIndexes = unique([extendedIndexes-1, extendedIndexes+1]);
                    extendedIndexes( extendedIndexes < 1 ) = 1;
                    extendedIndexes( extendedIndexes > ncols ) = ncols;
                    
                    minVal = min(min(dataSet.data));
                    dataSet.setDataAt(1:nrows, extendedIndexes, minVal);
                    dataSet = dataSet.selectByColumnIndexes(allIndexesToSelect);
                    delta = delta(allIndexesToSelect);
                end
            end
            
            result = biotracs.spectra.data.model.NMRSpectrumSet();
            
            %trim sample names (e.g.: '"  NAME"' => 'NAME')
            rowNames = regexprep( dataSet.rowNames, '(^("|'')?\s*)|(\s*("|'')?$)', '' );            
            for i=1:dataSet.getNbRows()
                data = [delta, dataSet.data(i,:)'];
                s = biotracs.spectra.data.model.NMRSpectrum( data );
                s.setLabel( rowNames{i} );
                result.add(s, rowNames{i});
            end

            result.setLabel( dataSet.label );
        end
        
        
        
        function [ delta ] = doExtractChemicalShifts( ~, dataSet )
            [~,n] = getSize(dataSet);
            delta = zeros(n,1);
            %trim chemical shift value (e.g.: '"  9.9945"' => '9.9945')
            shifts = regexprep( dataSet.columnNames, '(^")|("$)', '' );
            for i=1:n
                delta(i) = str2double( shifts{i} );
            end
        end
        
    end
    
end
