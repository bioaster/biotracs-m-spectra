% BIOASTER
%> @file		IsotopePatternParser.m
%> @class		biotracs.spectra.parser.model.IsotopePatternParser
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016


classdef IsotopePatternParser < biotracs.parser.model.TableParser
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = IsotopePatternParser()
				this@biotracs.parser.model.TableParser();
				this.setDescription('Instrument for isotope pattern parser');
		  end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
         
         function [ result ] = doParse( this, iFilePath )
            [ dataTable ] = this.doParse@biotracs.parser.model.TableParser( iFilePath );
            [~, filename] = fileparts(iFilePath);
            
            try
				if iscellstr( dataTable.data(:,1:2) ) 
					d = str2double(dataTable.data(:,1:2));
				else
					d = cell2mat(dataTable.data(:,1:2));
				end
            catch err
                error('The two first columns of the file cannot be converted to matrix.');
            end
            
            result = biotracs.spectra.data.model.Signal( d );
			result.setAxisLabels('MZ', 'Relative Abundance') ...
					.setLabel(filename)...
					.setDescription( [ 'Isotopic distribution of ', filename ] )...
					.setRepresentation( biotracs.spectra.data.model.Signal.REPRESENTATION_CENTROID );
         end
         
	 end

end
