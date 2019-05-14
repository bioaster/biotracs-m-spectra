% BIOASTER
%> @file		FidParserConfig.m
%> @class		biotracs.spectra.parser.model.FidParserConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef FidParserConfig < biotracs.core.parser.model.BaseParserConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = FidParserConfig( )
				this@biotracs.core.parser.model.BaseParserConfig( );
				this.setDescription('Configuration parameters of the fid parser');
                this.createParam('SampleNames', 'UserID','Constraint', biotracs.core.constraint.IsText());
                this.createParam('DataSubPath', 'DataSubPath','Constraint', biotracs.core.constraint.IsText()); 
                this.updateParamValue('FileExtensionFilter', '.1r');
		  end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
