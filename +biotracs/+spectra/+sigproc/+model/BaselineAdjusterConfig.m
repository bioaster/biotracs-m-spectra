% BIOASTER
%> @file		AlignerConfig.m
%> @class		biotracs.spectra.sigproc.model.BaselineAdjusterConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef BaselineAdjusterConfig < biotracs.core.mvc.model.ProcessConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end

    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaselineAdjusterConfig()
            this@biotracs.core.mvc.model.ProcessConfig();
            this.createParam( 'WindowSize', 200, 'Constraint', biotracs.core.constraint.IsPositive(), 'Description', 'Width for the shifting window. The default value is 200 (rather adapted for MS). Use about 0.1 (in ppm) for NMR' );
            this.createParam( 'StepSize', 200, 'Constraint', biotracs.core.constraint.IsPositive(), 'Description', 'The steps for the shifting window. The default value is 200 (rather adapted for MS). Use about 0.1 (in ppm) for NMR' );
            this.createParam( 'NegativeValueTransform', 'None', 'Constraint', biotracs.core.constraint.IsInSet({'Absolute','Zero','None'}), 'Description', 'Tansformation to apply to negative value after baseline transformation. ''Abs'' to use absolute value, ''Zero'' to replace by zeros. Default: ''None''' );
        end

    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end

end
