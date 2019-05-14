% BIOASTER
%> @file		AlignmentResult.m
%> @class		biotracs.spectra.sigproc.model.AlignmentResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date         2015

classdef AlignmentResult < biotracs.core.mvc.model.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = AlignmentResult()
            this@biotracs.core.mvc.model.ResourceSet();
            this.bindView( biotracs.spectra.sigproc.view.AlignmentResult );
            
            this.add( biotracs.spectra.data.model.SignalSet.empty(),     'AlignedSignalSet' );
            this.add( biotracs.data.model.DataMatrix.empty(),    'AlignmentIntervalIndexes' );
            this.add( biotracs.data.model.DataMatrix.empty(),    'AlignmentShifts' );
            this.add( biotracs.spectra.data.model.Signal.empty(),        'TargetSignal' );
        end

        function this = setLabel( this, iLabel )
            this.setLabel@biotracs.core.mvc.model.ResourceSet(iLabel);
            this.setLabelsOfElements(iLabel);
        end
        
        function tf = isPassed( this )
            intervalsDataMatrix = this.get('AlignmentIntervalIndexes');
            tf = isNil(intervalsDataMatrix) || hasEmptyData(intervalsDataMatrix);
        end
        
    end
    
    % -------------------------------------------------------
    % Protected methods
    % -------------------------------------------------------
    
    methods(Access = protected)

    end
    
end
