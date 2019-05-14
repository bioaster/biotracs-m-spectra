% BIOASTER
%> @file		BucketTableParserConfig.m
%> @class		biotracs.spectra.parser.model.BucketTableParserConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef BucketTableParserConfig < biotracs.parser.model.TableParserConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = BucketTableParserConfig( )
				this@biotracs.parser.model.TableParserConfig( );
				this.setDescription('Configuration parameters of the mzXML parser');
                this.updateParamValue('FileExtensionFilter', '.txt,.csv');
                this.createParam(...
                    'ChemicalShiftRanges', [], ...
                    'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'IsScalar', false), ...
                    'Description', 'The ChemicalShiftRanges must be a N-by-2 matrix. Each row is range of chemical shift ([Start End]) to extract. If empty, all chemical shifts are extracted.');  
		  end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
