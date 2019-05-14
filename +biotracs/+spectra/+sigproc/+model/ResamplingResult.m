% BIOASTER
%> @file		ResamplingResult.m
%> @class		biotracs.spectra.sigproc.model.ResamplingResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date        2017

classdef ResamplingResult < biotracs.core.mvc.model.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = ResamplingResult()
            this@biotracs.core.mvc.model.ResourceSet();
            this.bindView( biotracs.spectra.sigproc.view.ResamplingResult );
            this.add( biotracs.core.mvc.model.Resource.empty(), 'ResampledSignals' );
        end

        function this = setLabel( this, iLabel )
            this.setLabel@biotracs.core.mvc.model.ResourceSet(iLabel);
            this.setLabelsOfElements(iLabel);
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)
    end
    
end
