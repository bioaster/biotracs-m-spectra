classdef IsotopePatternParserTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = [biotracs.core.env.Env.workingDir, '/biotracs/spectra/parser/IsotopePatternParserTests'];
    end
    
    methods (Test)
        
        function testParseFile(testCase)
            filePath = '../../testdata/IsotopePatterns/H.csv'; 
            process = biotracs.spectra.parser.model.IsotopePatternParser();
            c = process.getConfig();
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            c.updateParamValue('ReadRowNames', true);
            c.updateParamValue('ReadColumnNames', true);
            process.setInputPortData( 'DataFile', biotracs.data.model.DataFile(filePath) );
            process.run();
            spectrum = process.getOutputPortData('ResourceSet').get('H.csv');
            testCase.verifyEqual( spectrum.data, [2.015101, 100.000; 3.021378, 0.023] );
        end
        
        function testParseFolder(testCase)
            folder = '../../testdata/IsotopePatterns/';
            process = biotracs.spectra.parser.model.IsotopePatternParser();
            c = process.getConfig();
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            process.setInputPortData( 'DataFile', biotracs.data.model.DataFile(folder) );
            process.run();
            spectrum1 = process.getOutputPortData('ResourceSet').get('H.csv');
            spectrum2 = process.getOutputPortData('ResourceSet').get('NH2.csv');
            testCase.verifyEqual( ...
                spectrum1.data, ...
                [2.015101, 100.000; 3.021378, 0.023] ...
            );
            testCase.verifyEqual( ...
                spectrum2.data, ...
                [16.018724	100.000
                17.015759	0.365
                17.025001	0.023] ...
             );
        end
        
    end
    
end
