% BIOASTER
%> @file		ConsensusResult.m
%> @class		biotracs.spectra.sigproc.model.ConsensusResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date        2017

classdef ConsensusResult < biotracs.core.mvc.model.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = ConsensusResult()
            this@biotracs.core.mvc.model.ResourceSet();
            this.bindView( biotracs.spectra.sigproc.view.ConsensusResult );
            
            this.add( biotracs.spectra.data.model.SignalSet.empty(),        'ConsensusSignalSet' );
            this.add( biotracs.core.mvc.model.ResourceSet.empty(),    'ConsensusStatistics' );
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
