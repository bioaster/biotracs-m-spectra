% BIOASTER
%> @file		MzxmlParserConfig.m
%> @class		biotracs.spectra.parser.model.MzxmlParserConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016


classdef MzxmlParserConfig < biotracs.core.parser.model.BaseParserConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = MzxmlParserConfig( )
				this@biotracs.core.parser.model.BaseParserConfig( );
				this.setDescription('Configuration parameters of the mzXML parser');
                this.createParam('TimeRange', [], 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'IsScalar', false));  
                this.createParam('Level', [], 'Constraint', biotracs.core.constraint.IsGreaterThan(0, 'IsScalar', true, 'Type', 'integer'));  
                this.createParam('OutputClass', 'biotracs.spectra.data.model.MSSpectrumMap', 'Constraint', biotracs.core.constraint.IsInSet({'biotracs.spectra.data.model.MSSpectrumSet','biotracs.spectra.data.model.MSSpectrumMap'}));
                this.updateParamValue('FileExtensionFilter', '.mzxml');
		  end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
