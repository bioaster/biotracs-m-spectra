% BIOASTER
%> @file		ConsensusSignalCreatorConfig.m
%> @class		biotracs.spectra.sigproc.model.ConsensusSignalCreatorConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef ConsensusSignalCreatorConfig < biotracs.core.mvc.model.ProcessConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end

    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = ConsensusSignalCreatorConfig()
			this@biotracs.core.mvc.model.ProcessConfig();
            this.createParam( 'Method', 'mean', 'Constraint', biotracs.core.constraint.IsInSet({'mean', 'sum'}) );
            this.createParam( 'IntensityThreshold',100, 'Constraint', biotracs.core.constraint.IsPositive() );
            this.createParam( 'Intervals', [] );
        end
        
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end

end
