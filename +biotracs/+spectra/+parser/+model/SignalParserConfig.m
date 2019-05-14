% BIOASTER
%> @file		SignalParserConfig.m
%> @class		biotracs.spectra.parser.model.SignalParserConfig
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016


classdef SignalParserConfig < biotracs.parser.model.TableParserConfig
	 
	 properties(Constant)
	 end
	 
	 properties(SetAccess = protected)
	 end

	 % -------------------------------------------------------
	 % Public methods
	 % -------------------------------------------------------
	 
	 methods
		  
		  % Constructor
		  function this = SignalParserConfig( )
				this@biotracs.parser.model.TableParserConfig( );
				this.setDescription('Configuration parameters of the table parser');
                this.createParam(...
                    'Representation', [], ...
                    'Constraint', biotracs.core.constraint.IsInSet({biotracs.spectra.data.model.Signal.REPRESENTATION_CENTROID, biotracs.spectra.data.model.Signal.REPRESENTATION_PROFILE}), ...
                    'Description', 'To set the representation of the parsed data if not empty' ...
                    );
                this.updateParamValue('TableClass', 'biotracs.spectra.data.model.Signal');
		  end
		  
		  
	 end
	 
	 % -------------------------------------------------------
	 % Protected methods
	 % -------------------------------------------------------
	 
	 methods(Access = protected)
	 end

end
