classdef SignalTests < matlab.unittest.TestCase

    methods (Test)
        function testDefaultConstructor(testCase)
            spectrum = biotracs.spectra.data.model.Signal();
            testCase.verifyClass(spectrum, 'biotracs.spectra.data.model.Signal');
            testCase.verifyEqual(spectrum.label, 'biotracs.spectra.data.model.Signal');
            testCase.verifyEqual(spectrum.data, zeros(0,2));
            testCase.verifyEqual(spectrum.getXAxisLabel(), 'Intentity Index');
            testCase.verifyEqual(spectrum.getYAxisLabel(), 'Intensity');
        end
        
        function testConstructorWithLabels(testCase)
            process = biotracs.core.mvc.model.Process();
            spectrum = biotracs.spectra.data.model.Signal();
			spectrum.setAxisLabels('mz', 'intensity') ...
					.setLabel('spectrum 1')...
					.setDescription( 'spectrum description' )...
					.setProcess(process);
					
            testCase.verifyClass(spectrum, 'biotracs.spectra.data.model.Signal');
            testCase.verifyEqual(spectrum.label, 'spectrum 1');
            testCase.verifyEqual(spectrum.description, 'spectrum description');
            testCase.verifyEqual(spectrum.data, zeros(0,2));
            testCase.verifyEqual(spectrum.getXAxisLabel, 'mz');
            testCase.verifyEqual(spectrum.getYAxisLabel, 'intensity');
            testCase.verifyEqual(spectrum.process, process);
        end
        
        function testConstructorWithDataAndLabels(testCase)
            process = biotracs.core.mvc.model.Process();
            values = [1,2.3; 3.3, 1.004];
            spectrum = biotracs.spectra.data.model.Signal(values);
			spectrum.setAxisLabels('mz', 'intensity') ...
					.setProcess(process);
					
            testCase.verifyClass(spectrum, 'biotracs.spectra.data.model.Signal');
            testCase.verifyEqual(spectrum.data, [1,2.3; 3.3, 1.004]);
            testCase.verifyEqual(spectrum.getXAxisLabel, 'mz');
            testCase.verifyEqual(spectrum.getYAxisLabel, 'intensity');
            testCase.verifyEqual(spectrum.process, process);
        end
        
        function testCopyConstructor(testCase)
            process = biotracs.core.mvc.model.Process();
            s = biotracs.spectra.data.model.Signal();
            s.setAxisLabels('mz', 'intensity') ...
                .setLabel('spectrum 1')...
                .setDescription( 'spectrum description' )...
                .setProcess(process);
            
            s2 = biotracs.spectra.data.model.Signal.fromSignal(s);
            
            testCase.verifyEqual(s2.data, s.data);
            testCase.verifyTrue(s2 ~= s);
        end
        
        function testCopyConstructor2(testCase)
            process = biotracs.core.mvc.model.Process();
            dm = biotracs.data.model.DataMatrix([1,5,3; 3,4,5]');
            dm.setLabel('spectrum 1')...
                .setDescription( 'spectrum description' )...
                .setProcess(process);
            
            s = biotracs.spectra.data.model.Signal.fromDataMatrix(dm);
            
            testCase.verifyClass(s, 'biotracs.spectra.data.model.Signal');
            testCase.verifyEqual(s.data, [1,5,3; 3,4,5]'); 
            testCase.verifyEqual(s.getXAxisLabel(), '');
            testCase.verifyEqual(s.getYAxisLabel(), '');
            testCase.verifyEqual(s.process, biotracs.core.mvc.model.Process.empty());
        end
       
        
        function testPeakPicking( testCase )
            signal = biotracs.spectra.data.model.Signal.import( '../../testdata/signal/Profile_1854.csv', 'ReadRowNames', false );
            signal.setRepresentation('centroid');
            
            result = signal.resample();
            resampeldSignal = result.get('ResampledSignals');
            result.view('Plot');
            
            result = resampeldSignal.pickPeaks();
            centroidedSignal = result.get('CentroidedSignals');
            centroidedSignal.view('Plot');
        end

        function testBinning(testCase)
            signal = biotracs.spectra.data.model.Signal.import( '../../testdata/signal/Profile_1900.csv', 'ReadRowNames', false );
            signal.setRepresentation('centroid');
            
            result = signal.resample();
            resampeldSignal = result.get('ResampledSignals');
            
            result = resampeldSignal.bin('BinWidth',0.01);            
            result.view('Plot');

            stats = result.get('Statistics');

            testCase.verifyGreaterThan(stats.getDataByColumnName('correlation'), 0.9);
        end
        
    end
    
end
