% BIOASTER
%> @file		MSFragTable.m
%> @class		biotracs.spectra.data.view.MSFragTable
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2016

classdef MSFragTable < biotracs.data.view.DataTable

    properties        
    end
    
    methods
        
        function h = viewFragPlot( this, varargin )
            p = inputParser();
            p.addParameter('ExperimentalFragmentSpectrum', [], @(x)isa(x, 'biotracs.spectra.data.model.MSSpectrum'));
            p.addParameter('Adduct', '', @ischar);
            p.addParameter('PrecursorIonMass', [], @isnumeric);
            p.KeepUnmatched = true;
            p.parse(varargin{:})
            
            model = this.model;
            m = getSize(model,1);
            explPeakIdx = model.getColumnIndexesByName('^ExplPeaks$');
            explPeakFormulaIdx = model.getColumnIndexesByName('^FormulasOfExplPeaks$');
            nameIdx = model.getColumnIndexesByName('^Name$');
            identifierIdx = model.getColumnIndexesByName('^Identifier$');
            formulaIdx = model.getColumnIndexesByName('^MolecularFormula$');
            scoreIdx = model.getColumnIndexesByName('^Score$');
            nbExplPeaks = model.getDataByColumnName('^NoExplPeaks$');
            nbPeaksUsed = model.getDataByColumnName('^NumberPeaksUsed$');
            neutralMasses = model.getDataByColumnName('^MonoisotopicMass$');
            
            
            h = cell(1,m);
            for i = 1:m
                inSilicoPeakData = this.doParsePeaks( model.data{i,explPeakIdx} );
                d = biotracs.data.model.DataMatrix( [inSilicoPeakData(:,1), -inSilicoPeakData(:,2)] );
                h{i} = d.view( 'Plot', 'Normalize', true, 'LineStyle', '|', 'Color', 'b', 'Marker', '+' ); 
                
                %plot ProcessFragment
                if ~isempty(p.Results.ExperimentalFragmentSpectrum) && ~hasEmptyData(p.Results.ExperimentalFragmentSpectrum)
                    expFragTable = p.Results.ExperimentalFragmentSpectrum;
                    expFragTable = biotracs.data.model.DataMatrix( [expFragTable.data(:,1), expFragTable.data(:,2)] );
                    expFragTable.view( 'Plot', 'Normalize', true, 'NewFigure', false, 'LineStyle', '|', 'Color', 'r' );
                end
  
                t1 = [ model.data{i,nameIdx}, ' [', model.data{i,formulaIdx}, ']' ];
                t2 = [ 'adduct = ', p.Results.Adduct, ', precursor = ', sprintf('%1.4f',p.Results.PrecursorIonMass), ', neutral = ', neutralMasses{i} ];
                t3 = [ 'score = ', model.data{i,scoreIdx}, ', id = ', model.data{i,identifierIdx} ];
                title( { t1, t2, t3 }, 'FontSize', 9 );
            
                ylim([-1.2, 1.2]);
                
                peakFomula = model.data{i,explPeakFormulaIdx};
                tab = strsplit( peakFomula, ';' );
                normFactor = max(abs(inSilicoPeakData(:,2)));
                for j=1:length(tab)
                   if strcmp(tab{j}, 'NA'), continue; end
                   mzAndFormula = strsplit(tab{j},':');
                   %yLimits = ylim();
                   %x = str2double(mzAndFormula{1,1});
                   %y = yLimits(2);
                   x = inSilicoPeakData(j,1);
                   y = inSilicoPeakData(j,2)/normFactor;
                   text( x, y+0.1, sprintf('%1.3f', str2double(mzAndFormula{1,1})), 'FontSize', 8 );
                   text( x, -y-0.1, mzAndFormula{1,2}, 'FontSize', 8, 'Rotation', 90 );
                end
                
                xLim = xlim();
                xLength = (xLim(end)+xLim(1));
                text( xLength/2.5, 1.15, ['Processal, # used = ', nbPeaksUsed{i} ], 'FontSize', 8, 'Color', 'red' );
                text( xLength/2.25, -1.15, ['In-silico, # expl. = ', nbExplPeaks{i} ], 'FontSize', 8, 'Color', 'blue' );
                xlabel('MZ');
                ylabel('Normalized intensity')
            end
        end
        
    end
   
    
    methods(Access = protected)
        
        function peakTable = doParsePeaks( ~, iPeaks )
            tab = strsplit(iPeaks,';');
            m = length(tab);
            peakTable = zeros(m,2);
            for i=1:m
                mzrt = strsplit(tab{i}, '_');
                peakTable(i,:) = str2double(mzrt);
            end
        end
        
    end
    
end

