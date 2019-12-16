% BIOASTER
%> @file		MzxmlParser.m
%> @class		biotracs.spectra.helper.MzxmlParser
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		Sept. 2014

classdef MzxmlParser < biotracs.core.parser.model.BaseParser
    
    properties(SetAccess = private)
        hugeDataSize = 500;
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        % Constructor
        function this = MzxmlParser()
            %#function biotracs.spectra.helper.MzxmlParserConfig biotracs.spectra.data.model.MSSpectrum biotracs.spectra.data.model.MSSpectrumSet
            this@biotracs.core.parser.model.BaseParser();
        end

    end
    
    methods(Access = protected)
        
        function [ result ] = doParse( this, iFilePath )
            [~, filename, ext] = fileparts( iFilePath );
            this.logger.writeLog('Loading file %s ...', iFilePath);
            mzXMLData = biomex.xml.xml2struct(iFilePath);
            this.logger.writeLog('%s','Parsing mzXML data ...');
            switch lower(ext)
                case {'.mzxml'}
                    result = biotracs.spectra.data.model.MSSpectrumMap(mzXMLData);
                    outputClass = this.config.getParamValue('OutputClass');
                    if strcmp(outputClass, 'biotracs.spectra.data.model.MSSpectrumSet')
                        this.logger.writeLog('%s','Warning: creating SpectrumSet from SpectrumMap may be long and useless because the SpectrumMap class already provides fast raw data management.');
                        result = result.createSpectrumSet();
                    end
                otherwise
                    error('Invalid file type');
            end
            
            result.setLabel( filename );
        end
        
    end
    
    methods(Static)
    end
    
end
