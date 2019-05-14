% BIOASTER
%> @file		NMRSpectrumSet.m
%> @class		biotracs.spectra.data.model.NMRSpectrumSet
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2014

classdef NMRSpectrumSet < biotracs.spectra.data.model.SignalSet
    
    properties(Dependent = true)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = NMRSpectrumSet( varargin )
            this@biotracs.spectra.data.model.SignalSet()
            if nargin == 0
                this.classNameOfElements = {'biotracs.spectra.data.model.NMRSpectrum'};
                this.updateParamValue('XAxisLabel', 'Delta');
                this.updateParamValue('YAxisLabel', 'Spectrum #');
                this.updateParamValue('ZAxisLabel', 'Relative Abundance');
            elseif isnumeric( varargin{1} )
                this.allocate( varargin{1} );
                this.classNameOfElements = {'biotracs.spectra.data.model.NMRSpectrum'};
                this.updateParamValue('XAxisLabel', 'MZ');
                this.updateParamValue('XAxisLabel', 'Delta');
                this.updateParamValue('YAxisLabel', 'Spectrum #');
            elseif isa(varargin{1}, 'biotracs.spectra.data.model.SignalSet')
                % copy constructor
                this.doCopy( varargin{1} );
                if ~isa(varargin{1}, 'biotracs.spectra.data.model.NMRSpectrumSet')
                    this.classNameOfElements = {'biotracs.spectra.data.model.NMRSpectrum'};
                    this.updateParamValue('XAxisLabel', 'Delta');
                    this.updateParamValue('YAxisLabel', 'Spectrum #');
                    this.updateParamValue('ZAxisLabel', 'Relative Abundance');
                end
            else
                error('Invalid argument');
            end
            
            this.bindView( biotracs.spectra.data.view.NMRSpectrumSet() );
        end
        
        %-- A --

        %-- C --

        %-- E --

        %-- G --

        %-- E --

        %-- F --

        %-- S --
        
        %-- P --
        
        %-- S --

        %-- V --

    end
    
    % -------------------------------------------------------
    % Static
    % -------------------------------------------------------
    
    methods(Static)
        
                
        function this = fromSignalSet( iSgnalSet )
            if ~isa( iSgnalSet, 'biotracs.spectra.data.model.SignalSet' )
                error('A ''biotracs.spectra.data.model.SignalSet'' is required');
            end
            this = biotracs.spectra.data.model.NMRSpectrumSet();
            this.doCopy(iSgnalSet);
        end
        
        function [ spectrumSet ] = import( iFilePath, varargin )
            p = inputParser();
            p.addParameter('WorkingDirectory','',@ischar);
            p.addParameter('Format','amix',@ischar);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            switch p.Results.Format
                case 'amix'
                    process = biotracs.spectra.parser.model.BucketTableParser();
                    dataFile = biotracs.data.model.DataFile(iFilePath);
                    process.setInputPortData('DataFile', dataFile);
                    process.run();
                    result = process.getOutputPortData('ResourceSet');
                    spectrumSet = result.getAt(1);
                otherwise
                    error('Format not supported');
            end
        end
        
%         function spectrumSet = importFolder( iFilePath, varargin )
%             
%             p = inputParser();
%             p.addParameter('format','ascii',@ischar);
%             p.addParameter('FolderPattern','.*',@ischar);
%             p.KeepUnmatched = true;
%             p.parse(varargin{:});
%             
%             switch p.Results.format
%                 case 'ascii'
%                     spectrumSet = biotracs.spectra.data.model.NMRSpectrumSet();
%                     spectrumSet.updateParamValue('YAxisLabel', 'Spectrum');
%                     d = dir( iFilePath );
%                     for i=1:length(d)
%                         if d(i).isdir && ~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..')
%                             instanceName = d(i).name;
%                             for k=1:10
%                                 numDir = [ iFilePath, '/', instanceName, '/', num2str(k) ];
%                                 if ~isfolder(numDir), continue; end
%                                 if ~isempty(regexpi(instanceName, p.Results.FolderPattern, 'once'))
%                                     %url = [ numDir, '/pdata/1/ascii-spec.txt' ];
%                                     s = biotracs.spectra.data.model.NMRSpectrum.import( url, varargin{:} );
%                                     s.setLabel(instanceName);
%                                     spectrumSet.add(s,instanceName);
%                                     break;
%                                 else
%                                     disp(['Skip folder ', instanceName]);
%                                 end
%                             end
%                         end
%                     end
%                 otherwise
%                     error('Format not supported');
%             end
%             
%         end
        
    end
end
