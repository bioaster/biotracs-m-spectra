% BIOASTER
%> @file		MSFragTable.m
%> @class		biotracs.spectra.data.model.MSFragTable
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef MSFragTable < biotracs.data.model.DataTable

    properties(Constant)
%         EXPL_PEAKS_COLUMN       = 'ExplPeaks';
%         FORMULA_COLUMN          = 'FormulasOfExplPeaks';
%         DB_ID_COLUMN            = 'Identifier';
%         MOLECULE_NAME_COLUMN    = 'Name';
%         SCORE_NAME_COLUMN       = 'Score';
        %...  
        DEFAULT_COLUMN_NAMES = {...
            'Identifier',...
            'Name',...
            'ExplPeaks',...
            'FormulasOfExplPeaks',...
            'Score',...
            'MolecularFormula',...
            'NoExplPeaks',...
            'NumberPeaksUsed',...
            'MonoisotopicMass'...
            };
    end
    
    properties(SetAccess = private)
        
    end
    
    methods
        
        function this = MSFragTable( varargin )       
            if isempty(varargin)
                n = length(biotracs.spectra.data.model.MSFragTable.DEFAULT_COLUMN_NAMES);
                varargin{1} = cell(0,n);
                varargin{2} = biotracs.spectra.data.model.MSFragTable.DEFAULT_COLUMN_NAMES;
            elseif length(varargin) == 1
                varargin{2} = biotracs.spectra.data.model.MSFragTable.DEFAULT_COLUMN_NAMES;
            end
            this@biotracs.data.model.DataTable( varargin{:} );
            %this.subTableClassName = 'biotracs.data.model.DataTable';
            
            this.bindView( biotracs.spectra.data.view.MSFragTable );
        end
        
        function out = getExplainedPeaks( this, iIndexes )
            out = this.getDataByColumnName('^ExplPeaks$');
            if nargin == 2
                if isscalar(iIndexes)
                    out = out{iIndexes};
                else
                    out = out(iIndexes);
                end
            end
        end
        
        function out = getFormulasOfExplainedPeaks( this, iIndexes )
            formulas = this.getDataByColumnName('^FormulasOfExplPeaks$');
            if nargin == 2
                formulas = formulas(iIndexes);
            end
            
            n = length(formulas);
            out = cell(1,n);
            for i=1:n
                tab = strsplit( formulas{i}, ';' );
                m = length(tab);
                out{i} = cell(m,2);
                for j=1:m
                    if strcmp(tab{j}, 'NA'), continue; end
                    mzAndFormula = strsplit(tab{j},':');
                    mzAndFormula{1,1} = str2double( mzAndFormula{1,1} );
                    out{i} = mzAndFormula;
                end
            end
        end
        
        function out = getIdentifiers( this, iIndexes )
            out = this.getDataByColumnName('^Identifier$');
            if nargin == 2
                if isscalar(iIndexes)
                    out = out{iIndexes};
                else
                    out = out(iIndexes);
                end
            end
        end
        
        function out = getMolecularNames( this, iIndexes  )
            out = this.getDataByColumnName('^Name$');
            if nargin == 2
                if isscalar(iIndexes)
                    out = out{iIndexes};
                else
                    out = out(iIndexes);
                end
            end
        end
        
        function out = getMolecularFormulas( this, iIndexes )
            out = this.getDataByColumnName('^MolecularFormula$');
            if nargin == 2
                if isscalar(iIndexes)
                    out = out{iIndexes};
                else
                    out = out(iIndexes);
                end
            end
        end
        
        function out = getScores( this, iIndexes )
            out = this.getDataByColumnName('^Score$');
            if nargin == 2
                if isscalar(iIndexes)
                    out = out{iIndexes};
                else
                    out = out(iIndexes);
                end
            end
        end
        
        function out = getNbExplainedPeaks( this, iIndexes )
            out = this.getDataByColumnName('^NoExplPeaks$');
            if nargin == 2
                if isscalar(iIndexes)
                    out = out{iIndexes};
                else
                    out = out(iIndexes);
                end
            end
        end
        
        function out = getNbPeaksUsed( this, iIndexes )
            out = this.getDataByColumnName('^NumberPeaksUsed$');
            if nargin == 2
                if isscalar(iIndexes)
                    out = out{iIndexes};
                else
                    out = out(iIndexes);
                end
            end
        end
        
        function out = getMonoisotopicMasses( this, iIndexes )
            out = this.getDataByColumnName('^MonoisotopicMass$');
            if nargin == 2
                if isscalar(iIndexes)
                    out = out{iIndexes};
                else
                    out = out(iIndexes);
                end
            end
        end
        
        % -- S --

    end
   
    methods(Access = protected)

    end
    
    methods(Static)
        
        function this = fromDataObject( iDataObject )
            if ~isa( iDataObject, 'biotracs.data.model.DataObject' )
                error('A ''biotracs.data.model.DataObject'' is required');
            end
            this = biotracs.spectra.data.model.MSFragTable();
            this.doCopy( iDataObject );
        end
        
        function this = fromDataTable( iDataTable )
            if ~isa( iDataTable, 'biotracs.data.model.DataTable' )
                error('A ''biotracs.data.model.DataTable'' is required');
            end
            this = biotracs.spectra.data.model.MSFragTable();
            this.doCopy( iDataTable );
        end
        
        function this = fromDataMatrix( iDataMatrix )
            if ~isa( iDataMatrix, 'biotracs.data.model.DataMatrix' )
                error('A ''biotracs.data.model.DataMatrix'' is required');
            end
            this = biotracs.spectra.data.model.MSFragTable();
            this.doCopy( iDataMatrix );
        end
        
        function this = fromDataSet( iDataSet )
            if ~isa( iDataSet, 'biotracs.data.model.DataSet' )
                error('A ''biotracs.data.model.DataSet'' is required');
            end
            this = biotracs.spectra.data.model.MSFragTable();
            this.doCopy( iDataSet );
        end
        
        function this = import( iFilePath, varargin )
            this = biotracs.data.model.DataTable.import( iFilePath, ...
                'ReadRowNames', false, ...
                'ReadColumnNames', true, ...
                'TableClass', 'biotracs.spectra.data.model.MSFragTable'...
                );
            this = this.selectByColumnName( strcat('^',biotracs.spectra.data.model.MSFragTable.DEFAULT_COLUMN_NAMES,'$') );
        end
        
    end
    
end

