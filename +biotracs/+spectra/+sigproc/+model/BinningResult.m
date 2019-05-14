% BIOASTER
%> @file		BinningResult.m
%> @class		biotracs.spectra.sigproc.model.BinningResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date        2017

classdef BinningResult < biotracs.core.mvc.model.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = BinningResult()
            this@biotracs.core.mvc.model.ResourceSet();
            this.bindView( biotracs.spectra.sigproc.view.BinningResult );

            this.add( biotracs.core.mvc.model.Resource.empty(),      'DiscreteBinnedSignals' );
            this.add( biotracs.core.mvc.model.Resource.empty(),      'ContinuousBinnedSignals' );
            this.add( biotracs.data.model.DataMatrix.empty(),        'Statistics' );
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
