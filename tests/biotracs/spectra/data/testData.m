%"""
%Unit tests for biotracs.spectra.data.*
%* Date: 2016
%* Author:  D. A. Ouattara
%* License: BIOASTER License
%
%Omics Hub, Bioinformatics team
%BIOASTER Technology Research Institute (http://www.bioaster.org)
%"""

function testData( cleanAll )
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

    Tests.run();
end