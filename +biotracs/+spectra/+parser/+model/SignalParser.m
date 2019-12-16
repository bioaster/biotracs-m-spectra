% BIOASTER
%> @file		SignalParser.m
%> @class		biotracs.spectra.parser.model.SignalParser
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015


classdef SignalParser < biotracs.parser.model.TableParser
    
    properties(Constant)
    end
    
    properties(SetAccess = protected)
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        % Constructor
        function this = SignalParser( )
            %#function biotracs.spectra.parser.model.SignalParserConfig biotracs.spectra.data.model.SignalSet
            
            this@biotracs.parser.model.TableParser();
            this.updateOutputSpecs({...
                struct(...
                'name', 'ResourceSet',...
                'class', 'biotracs.spectra.data.model.SignalSet' ...
                )...
                });
        end
        
        %-- G --
    end
    
    methods(Access = protected)
        
        %TODo error if parsing gives NaN
        function [ result ] = doRun( this )
            this.doRun@biotracs.parser.model.TableParser();
            result = this.getOutputPortData('ResourceSet');
            rep = this.config.getParamValue('Representation');
            if ~isempty( rep )
                result.setRepresentation(rep);
            end
        end
        
        
    end
    
end


