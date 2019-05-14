% BIOASTER
%> @file		BinnerConfig.m
%> @class		biotracs.spectra.sigproc.model.BinnerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef BinnerConfig < biotracs.core.mvc.model.ProcessConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end

    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BinnerConfig( )
            this@biotracs.core.mvc.model.ProcessConfig( );
            this.createParam(...
                'Method','uniform', ...
                'Constraint', biotracs.core.constraint.IsInSet({'uniform','gaussian'}) ...
            );
            this.createParam(...
                'BinWidth', [], ...
                'Constraint', biotracs.core.constraint.IsPositive('Strict', true), ...
                'Description', 'Unit division with that defines a bin' ...
            );
            this.createParam(...
                'Range', [], ...
                'Description', 'Range of the binning axis. A 1-by-2 vector [start, end]' ...
            );
            this.createParam(...
                'BinTicks', [], ...
                'Description', 'Custom 1-by-N vector that gives the bin separation locations. If given, ''BinWidth'' and ''Range'' are ignnored' ...
                );
            this.createParam(...
                'StandardDeviation', [], ...
                'Constraint', biotracs.core.constraint.IsPositive('Strict', true), ...
                'Description', 'The standard deviation of the gaussian curves used for gaussian binning only. By default, the half of the minimal bin width is used' ...
                );
        end
        
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end

end
