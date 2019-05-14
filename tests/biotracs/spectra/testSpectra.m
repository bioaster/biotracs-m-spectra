%"""
%Unit tests for biotracs.spectra.*
%* License: BIOASTER License
%* Create: May. 2017
%Bioinformatics team, Omics Hub, BIOASTER Technology Research Institute (http://www.bioaster.org)
%"""

function testSpectra( cleanAll )
    if nargin == 0 || cleanAll
        clc; close all force;
        restoredefaultpath();
    end
    
    addpath('../../');
    autoload( ...
        'PkgPaths', {fullfile(pwd, '../../../../')}, ...
        'Dependencies', {...
            'biotracs-m-spectra', ...
        }, ...
        'Variables',  struct(...
        ) ...
    );

    %% Tests
    import matlab.unittest.TestSuite;
    Tests = TestSuite.fromFolder('./', 'IncludingSubfolders', true);

    Tests.run();
end