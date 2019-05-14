classdef MSSpectrumTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        function testDefaultConstructor(testCase)
            data = biotracs.spectra.data.model.MSSpectrum();
            testCase.verifyClass(data, 'biotracs.spectra.data.model.MSSpectrum');
            testCase.verifyEqual(data.description, '');
            testCase.verifyEqual(data.getClassName(), 'biotracs.spectra.data.model.MSSpectrum');
            
            process = biotracs.core.mvc.model.Process();
            data.setProcess( process );
            testCase.verifyEqual(data.process, process);
        end
        
        function testCopyConstructor(testCase)
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] = biotracs.spectra.data.model.MSSpectrumSet.import(file);
            s = spectrum3d.getAt(1);
            data = s.data;
            
            s2 = biotracs.spectra.data.model.MSSpectrum(s);
            
            testCase.verifyEqual(s2.data, s.data);
            testCase.verifyTrue(s2 ~= s);
            
            [m,~] = getSize(s);
            t = [1:m; rand([1,m])]';
            s.setData( t );
            testCase.verifyEqual(s.data, t);
            testCase.verifyEqual(s2.data, data);
        end
        
    end
    
end
