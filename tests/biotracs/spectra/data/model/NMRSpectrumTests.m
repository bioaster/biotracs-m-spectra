classdef NMRSpectrumTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    methods(TestMethodTeardown)

    end
    
    methods (Test)
        function testDefaultConstructor(testCase)
            data = biotracs.spectra.data.model.NMRSpectrum();
            testCase.verifyClass(data, 'biotracs.spectra.data.model.NMRSpectrum');
            testCase.verifyEqual(data.description, '');
            testCase.verifyEqual(data.getClassName(), 'biotracs.spectra.data.model.NMRSpectrum');
            testCase.verifyEqual(data.getXAxisLabel(), 'Delta');
            testCase.verifyEqual(data.getYAxisLabel(), 'Relative Abundance');
            
            process = biotracs.core.mvc.model.Process();
            data.setProcess( process );
            testCase.verifyEqual(data.process, process);
        end
        
    end
    
end
