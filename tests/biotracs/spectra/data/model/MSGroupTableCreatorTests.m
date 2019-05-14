classdef MSGroupTableCreatorTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/spectra/data/GroupTableCreatorTests');
    end
    
    
    methods (Test)
 
        function testGroupTableCreator(testCase)
            reducedDataSet = biotracs.spectra.data.model.MSFeatureSet.import('../../testdata/IsofeatureSet/IsofeatureSet.csv');
            groupTableCreator = biotracs.spectra.data.model.MSGroupTableCreator();
            groupTableCreator.setInputPortData('IsoFeatureTable', reducedDataSet);
            groupTableCreator.run();
            groupTable = groupTableCreator.getOutputPortData('GroupTable');  
            groupTable.export([testCase.workingDir, 'test.csv'])
        end
        
    end
    
end

