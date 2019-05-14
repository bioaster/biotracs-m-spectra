% BIOASTER
%> @file		ResamplingResult.m
%> @class		biotracs.spectra.sigproc.view.ResamplingResult
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date        2017

classdef ResamplingResult < biotracs.core.mvc.view.ResourceSet
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
       
        function  h = viewPlot( this, varargin )
            p = inputParser();
            p.addParameter('SignalIndexes', [], @isnumeric);
            p.KeepUnmatched = true;
            p.parse( varargin{:} );
            
            model = this.getModel();
            
            e = model.getProcess();
            originalSignalSet = e.getInputPortData('SignalSet');            
            resampledSignals = model.get('ResampledSignals');

            indexes = p.Results.SignalIndexes;
            
            if isempty( indexes )
                h = originalSignalSet.view('Plot');
                resampledSignals.view(...
                    'Plot', ...
                    'NewFigure', false, ...
                    'Color', 'r', ...
                    'Title', 'Resampled signal'...
                    );
                %if isa(originalSignalSet, 'biotracs.spectra.data.model.SignalSet')
                %    n = originalSignalSet.getLength();
                %    emptyStr = repmat({''},1,n-1);
                %    legend([{'original'},emptyStr,{'resampled'}]);
                if isa(originalSignalSet, 'biotracs.spectra.data.model.Signal')
                    legend({'original','resampled'});
                end
            else
                n = length( indexes );
                h = cell(1,n);
                for i=1:n
                    idx = indexes(i);
                    if originalSignalSet.isCentroided()
                        h{i} = originalSignalSet.getAt(idx).view('Plot');
                        resampledSignals.getAt(idx).view(...
                            'Plot', ...
                            'NewFigure', false, ...
                            'Color', 'r', ...
                            'Title', 'Resampled signal'...
                            );
                    else
                        h{i} = originalSignalSet.getAt(idx).view('Plot');
                        ax1 = gca();
                        resampledSignals.getAt(idx).view(...
                            'Plot', ...
                            'NewFigure', false, ...
                            'Color', 'r', ...
                            'Title', 'Resampled signal'...
                            );
                        ax2 = gca();
                        linkaxes([ax1,ax2],'xy');
                    end
                    if i == 1
                       legend({'original','resampled'}); 
                    end
                end
                
            end
        end
        
    end
    
end
