% BIOASTER
%> @file		IsotopePatternParserConfig.m
%> @class		biotracs.spectra.parser.model.IsotopePatternParserConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016


classdef IsotopePatternParserConfig < biotracs.parser.model.TableParserConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
         
         % Constructor
		function this = IsotopePatternParserConfig()
             this@biotracs.parser.model.TableParserConfig( );
             this.setDescription('Config for isotope pattern parser');
         end
         
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
