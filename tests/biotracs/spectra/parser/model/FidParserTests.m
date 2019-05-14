classdef FidParserTests < matlab.unittest.TestCase
    
    properties
        workingDir = [biotracs.core.env.Env.workingDir, '/biotracs/spectra/nmr/Parser/FidParserTests'];
    end
    
    
    methods (Test)
        
        function testFidParserNoMetadata(testCase)
            dataFilePath = biotracs.data.model.DataFile(fullfile('../../testdata/FidData/CtCells/2/pdata/1/1r'));            
            process = biotracs.spectra.parser.model.FidParser();
            process.setInputPortData('DataFile', dataFilePath);
            process.getConfig()...
                .updateParamValue('FileExtensionFilter', '') ...
                .updateParamValue('FileNameFilter', '1r') ...
                .updateParamValue('Recursive', true);
            process.run();
            result = process.getOutputPortData('ResourceSet');
            result.summary();
            spectrumSet = result.getAt(1);
            spectrumSet.export([testCase.workingDir, '/test2.csv']);
            spectrumSet.view('Plot');
        end
        
        function testFidParserWithMetadata(testCase)
            metaTable = biotracs.data.model.DataTable.import(fullfile('../../testdata/FidData/samplemetadata.xlsx'));
            dataFilePath = biotracs.data.model.DataFile(fullfile('../../testdata/FidData/'));
            process = biotracs.spectra.parser.model.FidParser();
            process.getConfig()....
                .updateParamValue('DataSubPath', 'DataSubPath')
            process.setInputPortData('DataFile', dataFilePath);
            process.setInputPortData('SampleMetaData', metaTable);
            process.getConfig()...
                .updateParamValue('FileExtensionFilter', '') ...
                .updateParamValue('FileNameFilter', '1r') ...
                .updateParamValue('Recursive', true);
            process.run();
            result = process.getOutputPortData('ResourceSet');
            result.summary();
            spectrumSet = result.getAt(2);
            spectrumSet.view('Plot');
        end
        
        
    end
    
end
