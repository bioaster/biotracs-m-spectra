%"""
%Unit tests for biotracs.spectra.sigproc.*
%* Date: Aug. 2014
%* Author:  D. A. Ouattara
%* License: BIOASTER License
%
%Omics Hub, Bioinformatics team
%BIOASTER Technology Research Institute (http://www.bioaster.org)
%"""

function testSigproc( cleanAll )
    if nargin == 0 || cleanAll
        clc; close all force;
        restoredefaultpath();
    end
    
    addpath('../../../');
    autoload( ...
        'PkgPaths', {fullfile(pwd, '../../../../../')}, ...
        'Dependencies', {...
            'biotracs-m-spectra', ...
        }, ...
        'Variables',  struct(...
        ) ...
    );

    %% Tests
    import matlab.unittest.TestSuite;
    Tests = TestSuite.fromFolder('./', 'IncludingSubfolders', true);
%     Tests = TestSuite.fromFile('./model/FilterTests.m');
%     Tests = TestSuite.fromFile('./model/ConsensusSignalCreatorTests.m');
%     Tests = TestSuite.fromFile('./model/AlignerTests.m');
%     Tests = TestSuite.fromFile('./model/BaselineAdjusterTests.m');
%     Tests = TestSuite.fromFile('./model/ResamplerTests.m');
%     Tests = TestSuite.fromFile('./model/PeakPickerTests.m');
%     Tests = TestSuite.fromFile('./model/BinnerTests.m');
    
    Tests.run();
end