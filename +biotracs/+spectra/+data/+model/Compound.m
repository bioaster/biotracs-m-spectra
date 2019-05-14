% BIOASTER
%> @file		Compound.m
%> @class		biotracs.spectra.data.model.Compound
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef Compound < biotracs.biochem.data.model.Compound
    
    properties(Constant)
        POSITIVE_ADDUCT_LIST = {...
            'M;1+',                         0,          '',             '';
            'M+H;1+',                       1.007276,   '',             '';
            'M+NH4;1+',                     18.033823,  '',             '';
            'M+Na;1+',                      22.989218,  '',             '';
            'M+CH3OH+H;1+',                 33.033489,  'Methanol',     '';
            'M+K;1+',                       38.963158,  '',             '';
            'M+CH3CN+H;1+',                 42.033823,  'M+ACN+H',      'Actetonitrile';
            'M+2Na-H;1+',                   44.97116,   '',             '';
            'M+C3H8O;1+',                   61.06534,   'M+IsoProp',    'Isopropanol';
            'M+CH3CN+Na;1+',                64.015765,  'M+ACN+Na',     'Actetonitrile';
            'M+NaAc+H;1+',                  82.00307+1.007276, 'M+NaAc+H', 'Sodium-Acetate';
            'M+2NaAc+H;1+',                 2*82.00307+1.007276, 'M+2NaAc+H', 'Sodium-2Acetate';
            'M+3NaAc+H;1+',                 3*82.00307+1.007276, 'M+3NaAc+H', 'Sodium-3Acetate';
            'M+2K-H;1+',                    76.91904,   '',             '';
            'M+C2H6OS;1+',                  79.02122,   'M+DMSO',       'DMSO';
            'M+2CH3CN+H;1+',                83.06037,   'M+2ACN+H',     'Actetonitrile';
            'M+C3H8O+Na+H;1+',              84.05511,   'M+IsoProp+Na+H','Isopropanol'...
            };
        
        NEGATIVE_ADDUCT_LIST = {...
            'M;1-',                 0,          '',             '';
            'M-H;1-',               -1.007276, 	'',         '';
            'M-H2O-H;1-',           -19.01839,  '',         '';
            'M+Na-2H;1-',           20.974666, 	'',         '';
            'M+Cl;1-',              34.969402, 	'',         '';
            'M+K-2H;1-',            36.948606, 	'',         '';
            'M+CH2O2-H;1-',         44.998201,  'M+FA-H',	'Formic acid';
            'M+C2H4O2-H;1-',        59.013851,  'M+OAc',	'Acetic acid';
            'M+NaAc-H;1-',          82.00307-1.007276, 'M+NaAc-H', 'Sodium-Acetate';
            'M+2NaAc-H;1-',         2*82.00307-1.007276, 'M+2NaAc-H', 'Sodium-2Acetate';
            'M+3NaAc-H;1-',         3*82.00307-1.007276, 'M+3NaAc-H', 'Sodium-3Acetate';
            'M+Br;1-',              78.918885,  '',         '';
            'M+C2HO2F3-H;1-',       112.985586, 'M+TFA-H',	'Trifluoroacetic acid';
            };
    end
    
    methods
        
        % Constructor
        function this = Compound( varargin )
            this@biotracs.biochem.data.model.Compound(varargin{:});
        end
        
        function [oSpectrum, oInfo]  = getIsotopicDistributionAsSpectrum( this, varargin )
            [oIsotopicDist, oInfo] = this.getIsotopicDistribution( varargin{:} );
            
            if oInfo.charge > 0
                label = [ this.label, ' + ', num2str(oInfo.charge), 'H' ];
            else
                label = this.label;
            end
            
            oSpectrum = biotracs.spectra.data.model.MSSpectrum( oIsotopicDist );
            oSpectrum.setAxisLabels('MZ', 'Relative Abundance') ...
					.setLabel(label)...
					.setDescription( [ 'Isotopic distribution of ', label ] )...
					.setRepresentation('centroid');
        end
        
    end
    
    methods(Static)
        
        function oMasses = computeAdductMasses( iNeutralMass, iAdductList )
            if ~iscellstr(iAdductList)
                error('BIOAPPS:AdductMassCalculator:InvalidArgument', 'The adduct list must be a cell of string');
            end
            
            n = length(iAdductList);
            oMasses = nan(1,n);

            for i=1:n
                adduct = iAdductList{i};
                idx = ismember(biotracs.spectra.data.model.Compound.POSITIVE_ADDUCT_LIST(:,1), adduct);
                if any(idx)
                    massShift = biotracs.spectra.data.model.Compound.POSITIVE_ADDUCT_LIST(idx,2);
                    oMasses(i) = iNeutralMass + massShift{1};
                else
                    idx = ismember(biotracs.spectra.data.model.Compound.NEGATIVE_ADDUCT_LIST(:,1), adduct);
                    if any(idx)
                        massShift = biotracs.spectra.data.model.Compound.NEGATIVE_ADDUCT_LIST(idx,2);
                        oMasses(i) = iNeutralMass + massShift{1};
                    end
                end
            end
        end
        
    end
    
end
