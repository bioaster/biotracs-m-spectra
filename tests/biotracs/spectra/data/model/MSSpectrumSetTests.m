classdef MSSpectrumSetTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        function testDefaultConstructor(testCase)
            data = biotracs.spectra.data.model.MSSpectrumSet();
            testCase.verifyClass(data, 'biotracs.spectra.data.model.MSSpectrumSet');
            testCase.verifyEqual(data.description, '');
            testCase.verifyEqual(data.getClassName(), 'biotracs.spectra.data.model.MSSpectrumSet');
            process = biotracs.core.mvc.model.Process();
            data.setProcess( process );
            testCase.verifyEqual(data.process, process);
        end

        function testGetSpectrumByRetentionTime(testCase)
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrumSet ] = biotracs.spectra.data.model.MSSpectrumSet.import(file);
            %single spectrum
            index = spectrumSet.getIndexesByRetentionTimes(1.158, 1e-3);
            testCase.verifyEqual(index, 5);

            s = spectrumSet.getSpectrumByRetentionTime(1.15869, 1e-4);
            testCase.verifyClass(s, 'biotracs.spectra.data.model.MSSpectrum');
            testCase.verifyEqual(spectrumSet.getAt(index), s);
            
            index = spectrumSet.getIndexesByRetentionTimes(1, 1e-5);
            testCase.verifyEqual(index, []);
            
            %spectrumSet
            [indexes, ~] = spectrumSet.getIndexesByRetentionTimes( [1.158, 1.552], 1e-3);
            testCase.verifyEqual(indexes, [5, 7]);
            
            s = spectrumSet.selectByRetentionTimes([1.158, 1.552], 1e-3);
            testCase.verifyClass(s, 'biotracs.spectra.data.model.MSSpectrumSet');
            testCase.verifyEqual(spectrumSet.getAt(indexes(1)), s.getAt(1));
            testCase.verifyEqual(spectrumSet.getAt(indexes(2)), s.getAt(2));
            s.view('Plot');
        end

        function testPlot(testCase)
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrumSet ] = biotracs.spectra.data.model.MSSpectrumSet.import(file);
            spectrumSet.view('Plot');
            spectrumSet.view('TicPlot');
            spectrumSet.view('DotPlot', 'Quantile', 0.95 );
            spectrumSet.view('HeatMap', 'LogTransform', true );
        end
        
    end
    
end
