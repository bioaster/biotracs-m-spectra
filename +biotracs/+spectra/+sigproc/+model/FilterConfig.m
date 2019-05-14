% BIOASTER
%> @file		FilterConfig.m
%> @class		biotracs.spectra.sigproc.model.FilterConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017


classdef FilterConfig < biotracs.core.mvc.model.ProcessConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = FilterConfig( )
            this@biotracs.core.mvc.model.ProcessConfig( );
            this.createParam( ...
                'MinIntensity', 0, ...
                'Constraint', ...
                biotracs.core.constraint.IsPositive(), ...
                'Description', 'Signals of which the intensities are lower than MinIntensity are removed' ...
                );
            this.createParam( ...
                'MinTotalIntensityRatio', 0, ...
                'Constraint', ...
                biotracs.core.constraint.IsBetween( [0,1] ), ...
                'Description', 'Signals of which the total intensities are lower than (maximal-total-intensity * TotalIntensityRatio) are removed' ...
                );
            this.createParam( ...
                'SignalIndexesToRemove', [], ...
                'Constraint', biotracs.core.constraint.IsNumeric('IsScalar', false), ...
                'Description', 'Indexes of singals to remove' ...
                );
        end
        
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
end
