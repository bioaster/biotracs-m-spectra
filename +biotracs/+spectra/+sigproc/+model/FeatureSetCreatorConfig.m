% BIOASTER
%> @file		FeatureSetCreatorConfig.m
%> @class		biotracs.spectra.sigproc.model.FeatureSetCreatorConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef FeatureSetCreatorConfig < biotracs.core.mvc.model.ProcessConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = FeatureSetCreatorConfig( )
				this@biotracs.core.mvc.model.ProcessConfig( );
                this.createParam('IntervalsToRemove', [], 'Constraint', biotracs.core.constraint.IsNumeric('IsScalar', false));
                this.createParam('IntensityThreshold', 0, 'Constraint', biotracs.core.constraint.IsPositive());
                this.createParam('RemoveZeroVarianceVariables', true, 'Constraint', biotracs.core.constraint.IsBoolean());
                this.createParam('TableClass', 'biotracs.data.model.DataSet', 'Constraint', biotracs.core.constraint.IsText());
          end

	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
     
     methods(Access = protected)
  
   
     end

end
