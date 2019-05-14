% BIOASTER
%> @file		NMRSpectrum.m
%> @class		biotracs.spectra.data.model.NMRSpectrum
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef NMRSpectrum < biotracs.spectra.data.model.Signal
    
    properties(Constant)
    end
    
    properties(Dependent = true)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        %> @param[in] iValues N-by-2 array of double
        function this = NMRSpectrum( iData )
            this@biotracs.spectra.data.model.Signal();
            
            if nargin == 0
                this.setData( zeros(0,2) );
                this.setAxisLabels('Delta','Relative Abundance');
            elseif isa(iData, 'biotracs.data.model.DataMatrix')
                if isa(iData, 'biotracs.spectra.data.model.Signal')
                    this.setData( iData.data );
                    this.doCopy( iData );
                else
                    %sort indexes in ascending order
                    if ~issorted(iData.data(:,1),'rows')
                        this.setData( sortrows(iData.data) );
                    else
                        this.setData( iData.data );
                    end
                    this.doCopy( iData );
                    this.setAxisLabels('Delta','Relative Abundance');
                end
            elseif isnumeric(iData)
                %sort indexes in ascending order
                if ~isempty(iData)
                    if ~issorted(iData(:,1),'rows'), iData = sortrows(iData); end
                else
                    iData = zeros(0,2);
                end
                this.setData( iData );
                this.setAxisLabels('Delta','Relative Abundance');
            else
                error('Invalid argument; a numeric array is required');
            end
            
        end
        
    end
    
    
    % -------------------------------------------------------
    % Static methods
    % -------------------------------------------------------
    
    methods(Static)

        function this = fromDataObject( iDataObject )
            if ~isa( iDataObject, 'biotracs.data.model.DataObject' )
                error('A ''biotracs.data.model.DataObject'' is required');
            end
            this = biotracs.spectra.data.model.NMRSpectrum();
            this.doCopy( iDataObject );
        end
        
        function this = fromDataTable( iDataTable )
            if ~isa( iDataTable, 'biotracs.data.model.DataTable' )
                error('A ''biotracs.data.model.DataTable'' is required');
            end
            this = biotracs.spectra.data.model.NMRSpectrum();
            this.doCopy( iDataTable );
        end
        
        function this = fromDataMatrix( iDataMatrix )
            if ~isa( iDataMatrix, 'biotracs.data.model.DataMatrix' )
                error('A ''biotracs.data.model.DataMatrix'' is required');
            end
            this = biotracs.spectra.data.model.NMRSpectrum();
            this.doCopy( iDataMatrix );
        end
        
        function this = fromDataSet( iDataSet )
            if ~isa( iDataSet, 'biotracs.data.model.DataSet' )
                error('A ''biotracs.data.model.DataSet'' is required');
            end
            this = biotracs.spectra.data.model.NMRSpectrum();
            this.doCopy( iDataSet );      
        end
        
        function this = fromSignal( iSignal )
            if ~isa( iSignal, 'biotracs.spectra.data.model.Signal' )
                error('A ''biotracs.spectra.data.model.Signal'' is required');
            end
            this = biotracs.spectra.data.model.NMRSpectrum();
            this.doCopy( iSignal );      
        end
        
    end
    
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)

    end
    
    % -------------------------------------------------------
    % Static methods
    % -------------------------------------------------------
    
    methods(Static)
        
%         function spectrum = import( iFilePath, varargin )
%             p = inputParser();
%             p.addParameter('WorkingDirectory','',@ischar);
%             p.addParameter('Format','ascii',@ischar);
%             p.KeepUnmatched = true;
%             p.parse(varargin{:});
%             
%             switch p.Results.Format
%                 case 'ascii'
%                     ic = biotracs.parser.model.TableParserConfig();
%                     e = ic.createDefaultProcess();
%                     e.setInputPortData('DataFile', iFilePath);
%                     e.run();
%                     result = e.getOutputPortData('ResourceSet');        
%                     dataTable = result.getAt(1);
%                 case 'amix'
%                     ic = biotracs.spectra.data.model.NMRBucketTableParserConfig();
%                     e = ic.createDefaultProcess();
%                     e.setInputPortData('DataFile', iFilePath);
%                     e.run();
%                     result = e.getOutputPortData('ResourceSet');
%                     dataTable = result.getAt(1);
%                 otherwise
%                     error('Format not supported');
%             end
%             spectrum = biotracs.spectra.data.model.NMRSpectrum.fromDataTable( dataTable );
%         end
        
    end
    
end
