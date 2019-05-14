% BIOASTER
%> @file		AlignerConfig.m
%> @class		biotracs.spectra.sigproc.model.AlignerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef AlignerConfig < biotracs.core.mvc.model.ProcessConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end

    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = AlignerConfig()
            this@biotracs.core.mvc.model.ProcessConfig();
            this.createParam( 'Target', 'average', 'Constraint', biotracs.core.constraint.IsInSet({'top3', 'top3_and_average','average'}) );
            this.createParam( 'Intervals', [] );
            this.createParam( 'NbRepetitions', 1, 'Constraint', biotracs.core.constraint.IsGreaterThan(1) );
        end
 
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end

end
