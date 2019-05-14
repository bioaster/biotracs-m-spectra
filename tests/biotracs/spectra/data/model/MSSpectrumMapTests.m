classdef MSSpectrumMapTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        
        function testGetSpectrumByRetentionTimeandMz(testCase)
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML');
            spectrumMap = biotracs.spectra.data.model.MSSpectrumMap.import(file);

            t = spectrumMap.createSpectrumSet(...
                'RetentionTimes', 1, 'RetentionTimeAbsTol', 0.5, ...
                'Mz', [300, 600], 'MzAbsTol', 100, ...
                'Level', 1);
            
            t.summary();
            t.view('Plot');
            t.view('TicPlot');
        end
       
    end
    
end
