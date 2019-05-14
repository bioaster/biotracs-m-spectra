
% BIOASTER
%> @file		FidParser.m
%> @class		biotracs.spectra.parser.model.FidParser
%> @brief       PArse the fid spectra
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2018

classdef FidParser < biotracs.core.parser.model.BaseParser
    
    properties(Access = private)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        % Constructor
        function this = FidParser()
            this@biotracs.core.parser.model.BaseParser();
            this.addInputSpecs({...
                struct(...
                'name', 'SampleMetaData',...
                'class', 'biotracs.data.model.DataTable', ...
                'required', false)...
                });
            
            % enhance outputs specs
            this.updateOutputSpecs({...
                struct(...
                'name', 'ResourceSet',...
                'class', 'biotracs.spectra.data.model.NMRSpectrumSet' ...
                )...
                });
        end
        
    end
    
    methods(Access = protected)
        
        
        function doRun( this)
            dataObject = this.getInputPortData('DataFile');
            metaData = this.getInputPortData('SampleMetaData');
            if ~isempty(metaData.data)
                subPath = metaData.getDataByColumnName(this.config.getParamValue('DataSubPath'));
                basePath = dataObject.getPath();
                n = length(subPath);
                listOfFilePaths = join([repelem({basePath}, n,1), subPath], '/');
                dataFileSet = biotracs.data.model.DataFileSet();
                
                for i=1:length(listOfFilePaths)
                    dataFile = biotracs.data.model.DataFile(listOfFilePaths{i});
                    dataFileSet.add(dataFile);
                end
                dataObject = dataFileSet;
            end
            
            if isa(dataObject, 'biotracs.data.model.DataFile')
                this.fileCursor = 1;
                [ results, resultNames ] =  this.doRunSingleDataFile( dataObject );
            elseif isa(dataObject, 'biotracs.data.model.DataFileSet')
                n = getLength(dataObject);
                results = cell(1,n);
                resultNames = cell(1,n);
                for i=1:n
                    this.fileCursor = i;
                    dataFile = dataObject.getAt(i);
                    [ results{i}, resultNames{i} ] = this.doRunSingleDataFile( dataFile );
                end
                results = horzcat(results{:});
                resultNames = horzcat(resultNames{:});
            else
                error('A biotracs.data.model.DataFile or biotracs.data.model.DataFileSet is required. A %s is passed instead.', class(dataObject));
            end
            
            areNamesEmpty = isempty(resultNames) || all(cellfun(@isempty, resultNames));
            if areNamesEmpty
                error('No file parsed. Please check input data files');
            end
            
            resultSet = this.getOutputPortData( 'ResourceSet' );
            n = length(results);
            resultSet.allocate(n)...
                .setElements( results, resultNames )...
                .setLabel( resultNames{1} );
            this.setOutputPortData( 'ResourceSet',  resultSet );
        end
        
        function [ results, resultNames ] = doRunSingleDataFile( this, iDataFile )
            baseFilePath = iDataFile.getPath();
            if isempty(baseFilePath)
                error('Invalid file path. The file path is an empty string');
            end

            uncompressedFilePath = this.doUncompressFile( iDataFile );
            isUncompressed = ~isempty(uncompressedFilePath) && isfile(uncompressedFilePath);
            if isUncompressed
                filePath = uncompressedFilePath;
            else
                filePath = baseFilePath;
            end
            
            if isempty(filePath)
                error('The path of the input DataFile is empty.');
            end
            
            if isfolder(iDataFile)
                dataFileSet = biotracs.core.file.helper.PathReader.read( ...
                    filePath, ...
                    'FileExtensionFilter', this.config.getParamValue('FileExtensionFilter'), ...
                    'FileNameFilter', this.config.getParamValue('FileNameFilter'), ...
                    'Recursive', this.config.getParamValue('Recursive') ...
                    );
                dataFileList = dataFileSet.getElements();
                n = length(dataFileList);
                results = cell(1,n);
                resultNames = cell(1,n);
                if n == 0
                    disp('No files found in the repository');
                else
                    for i=1:n
                        [ results{i} ] = this.doParse( dataFileList{i}.getPath() );
                        [ ~, filename, ~ ] = fileparts( dataFileList{i}.getPath() );
                        label = results{i}.getLabel();
                        results{i}.setRepository( [baseFilePath,'/',filename] );
                        resultNames{i} = label;
                    end
                end
            else
                results = cell(1,1);
                resultNames = cell(1,1);
                [ results{1} ] = this.doParse( filePath );
                label = results{1}.getLabel();
                results{1}.setRepository( iDataFile.getPath() );
                resultNames{1} = label;
            end
            
            %clean uncompressed data
            if isUncompressed
                delete(uncompressedFilePath);
            end
        end
        
        function [result] =  doParse( this, iFilePath, varargin  )        
            this.logger.writeLog('Loading file %s ...', iFilePath);
            [ fidData ] = biotracs.spectra.helper.rbnmr( iFilePath, varargin{:} );
            this.logger.writeLog('%s','Parsing fid data ...');
            xAxis = fidData.XAxis;
            yData = fidData.Data;
            label = fidData.Info.PlotLabel;
            
            data = [xAxis,yData];
            
            result = biotracs.spectra.data.model.NMRSpectrum(data);
            result.setLabel( label );
        end
    end
    
end
