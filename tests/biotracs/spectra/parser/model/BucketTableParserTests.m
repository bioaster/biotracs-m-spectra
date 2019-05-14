classdef BucketTableParserTests < matlab.unittest.TestCase
    
    properties
    end
    
    methods (Test)
        
        function testAmixTableParser(testCase)
            dataFile = biotracs.data.model.DataFile('../../testdata/amix/small_amix_data.csv');
            process = biotracs.spectra.parser.model.BucketTableParser();
            process.setInputPortData('DataFile', dataFile);
            process.run();
            result = process.getOutputPortData('ResourceSet');
            testCase.verifyClass( result, 'biotracs.core.mvc.model.ResourceSet' );
            spectrumSet = result.getAt(1);
            testCase.verifyClass( spectrumSet, 'biotracs.spectra.data.model.NMRSpectrumSet' );
            testCase.verifyEqual( getLength(spectrumSet), 3 );
            spectrumSet.view('Plot');
        end
        
        function testAmixTableParserWithRange(testCase)
            dataFile = biotracs.data.model.DataFile('../../testdata/amix/small_amix_data.csv');
            process = biotracs.spectra.parser.model.BucketTableParser();
            process.setInputPortData('DataFile', dataFile);
            c = process.getConfig();
            c.updateParamValue('ChemicalShiftRanges', [4, 4.5; 5, 6]);
            process.run();
            result = process.getOutputPortData('ResourceSet');
            testCase.verifyClass( result, 'biotracs.core.mvc.model.ResourceSet' );
            spectrumSet = result.getAt(1);
            testCase.verifyClass( spectrumSet, 'biotracs.spectra.data.model.NMRSpectrumSet' );
            testCase.verifyEqual( getLength(spectrumSet), 3 );
            spectrumSet.view('Plot');
        end
        
    end
    
end
