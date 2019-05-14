% BIOASTER
%> @file		BaselineAdjustmentSignalSet.m
%> @class		biotracs.spectra.sigproc.model.BaselineAdjustmentSignalSet
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date        2017

classdef BaselineAdjustmentSignalSet < biotracs.spectra.data.model.SignalSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BaselineAdjustmentSignalSet()
            this@biotracs.spectra.data.model.SignalSet();
            this.bindView( biotracs.spectra.sigproc.view.BaselineAdjustmentSignalSet );
        end

    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)

    end
    
end
