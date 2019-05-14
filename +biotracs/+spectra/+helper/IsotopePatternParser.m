% BIOASTER
%> @file		IsotopePatternParser.m
%> @class		biotracs.spectra.helper.IsotopePatternParser
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2014

classdef IsotopePatternParser < biotracs.core.parser.model.CsvParser

    properties
    end
    
    methods
        % Constructor
        function this = IsotopePatternParser( iFilePath, iWorkingDirectory )
            this@biotracs.core.parser.model.CsvParser( iFilePath, iWorkingDirectory );
            this.updateParamValue('Delimiter', '\t');
        end
        
        function oSpectrum = getAsSpectrum( this )
            [~, filename, ~] = fileparts( this.filePath );
            oSpectrum = biotracs.spectra.data.model.Signal( [ this.data.MZ, this.data.Abundance ] );
			oSpectrum.setAxisLabels('MZ', 'Relative Abundance') ...
					.setLabel(filename)...
					.setDescription( [ 'Isotopic distribution of ', filename ] )...
					.setRepresentation('Centroid');
        end
        
    end
 
    methods(Static)

        %> @param[in] A folder path  
        %@return A biotracs.spectra.data.model.SignalSet
        function [spectrum3d] = parseFolder( iFolder, iWorkingDirectory )
            filelist = dir(iFolder);
            spectrum3d = biotracs.spectra.data.model.SignalSet();
			spectrum3d.setLabel('Patterm')...
					.setDescription('List of spectrum patterns to find');
            for patternIndex = 1:length(filelist)
                if ~filelist(patternIndex).isdir
                    [~, ~, ext] = fileparts( filelist(patternIndex).name );
                    if strcmp(ext, '.csv')
                        filePath = fullfile(iFolder, filelist(patternIndex).name);
                        try
                            parser = biotracs.spectra.helper.IsotopePatternParser( filePath, iWorkingDirectory );
                            parser.run();
                            spectrum = parser.getAsSpectrum();
                        catch err
                            disp ( err.message() )
                            disp([ 'File ''', filelist(patternIndex).name, ''' is not valid' ])
                            continue;
                        end
                    end
                    spectrum3d.add( spectrum );
                end
            end
        end
        
    end
    
end

