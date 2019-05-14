classdef ResamplerTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/spectra/sigproc/ResamplingTests');
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        
        function testResampling1dCentroided(testCase)
            file = fullfile('../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] = biotracs.spectra.data.model.MSSpectrumSet.import(file, 'WorkingDirectory', [testCase.workingDir, '/Resampling1dCentroided/1/']);
            spectrum2d = spectrum3d.getAt(1);
            process = biotracs.spectra.sigproc.model.Resampler();
            c = process.getConfig();
            process.setInputPortData('SignalSet', spectrum2d);
            %c.updateParamValue('SamplingMultiplier',1);
            c.updateParamValue('Range',[0, 500]);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Resampling1dCentroided/2/']);
            process.run();
            r = process.getOutputPortData('Result');
            r.view('Plot');
            title('Resampling 1d centroided singal');
        end
        
        function testResampling1dCentroidedWithNegativeSeparationUnit(testCase)
            file = fullfile('../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] = biotracs.spectra.data.model.MSSpectrumSet.import(file, 'WorkingDirectory', [testCase.workingDir, '/Resampling1dCentroidedWithNegativeSeparationUnit/1/']);
            spectrum2d = biotracs.spectra.data.model.Signal.fromSignal( spectrum3d.getAt(1) );
            spectrum2d.setData( [spectrum2d.data(:,1)-400, spectrum2d.data(:,2) ] );
            process = biotracs.spectra.sigproc.model.Resampler();
            c = process.getConfig();
            process.setInputPortData('SignalSet', spectrum2d);
            %c.updateParamValue('SamplingMultiplier',1);
            c.updateParamValue('Range',[-200, 200]);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Resampling1dCentroidedWithNegativeSeparationUnit/2/']);
            process.run();
            r = process.getOutputPortData('Result');
            r.view('Plot');
            title('Resampling 1d centroided singal (with negative separation units)');
        end
        
        
        function testResampling2DCentroided(testCase)
            file = fullfile('../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] = biotracs.spectra.data.model.MSSpectrumSet.import(file, 'WorkingDirectory', [testCase.workingDir, '/Resampling2dCentroided/1/']);
            process = biotracs.spectra.sigproc.model.Resampler();
            c = process.getConfig();
            process.setInputPortData('SignalSet', spectrum3d);
            c.updateParamValue('NbPoints',2e5);
            c.updateParamValue('Range',[0, 500]);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Resampling2dCentroided/2/']);
            process.run();
            r = process.getOutputPortData('Result');
            resampledSignals = r.get('ResampledSignals');
            r.view('Plot');
            title('Resampling 2d centroided singal set');
            for i=1:spectrum3d.getLength()
                testCase.verifyEqual(resampledSignals.getAt(1).data(:,1), resampledSignals.getAt(i).data(:,1))
            end
        end
        
        function testResampling1dProfile(testCase)
            file = fullfile('../testdata/mzXML/Profile_2160.mzXML');
            [ spectrum3d ] = biotracs.spectra.data.model.MSSpectrumSet.import(file, 'WorkingDirectory', [testCase.workingDir, '/Resampling1dProfile/1/']);
            spectrum2d = spectrum3d.getAt(1);
            process = biotracs.spectra.sigproc.model.Resampler();
            c = process.getConfig();
            process.setInputPortData('SignalSet', spectrum2d);
            %c.updateParamValue('SamplingMultiplier',1);
            c.updateParamValue('Range',[0, 500]);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Resampling1dProfile/2/']);
            process.run();
            r = process.getOutputPortData('Result');
            r.view('Plot');
            title('Resampling 1d profile singal');
        end
 
        function testResampling2DProfile(testCase)
            file = fullfile('../testdata/mzXML/Profile_2160.mzXML');
            [ spectrum3d ] = biotracs.spectra.data.model.MSSpectrumSet.import(file, 'WorkingDirectory', [testCase.workingDir, '/Resampling2dProfile/1/']);
            process = biotracs.spectra.sigproc.model.Resampler();
            c = process.getConfig();
            process.setInputPortData('SignalSet', spectrum3d);
            c.updateParamValue('NbPoints',2e5);
            c.updateParamValue('Range',[0, 500]);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Resampling2dProfile/2/']);
            process.run();
            r = process.getOutputPortData('Result');
            resampledSignals = r.get('ResampledSignals');
            r.view('Plot');
            title('Resampling 1d profile singal set');
            for i=1:spectrum3d.getLength()
                testCase.verifyEqual(resampledSignals.getAt(1).data(:,1), resampledSignals.getAt(i).data(:,1))
            end
        end
        
    end
    
end
