% BIOASTER
%> @file		PeakPickerConfig.m
%> @class		biotracs.spectra.sigproc.model.PeakPickerConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef PeakPickerConfig < biotracs.core.mvc.model.ProcessConfig
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end

    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PeakPickerConfig( )
            this@biotracs.core.mvc.model.ProcessConfig( );
        end
        
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end

end
