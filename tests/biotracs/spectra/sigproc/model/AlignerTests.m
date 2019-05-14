classdef AlignerTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/spectra/sigproc/AlignmentTests');
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        
        function testAlign(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signalSet = biotracs.spectra.data.model.SignalSet();
            for i=2:size(X,2)
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)] );
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['s', num2str(i-1)]);
            end
            
            % resample
            process = biotracs.spectra.sigproc.model.Resampler();
            process.setInputPortData('SignalSet', signalSet);
            c = process.getConfig();
            %c.updateParamValue('SamplingMultiplier',1.1);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Align/1']);
            process.run();
            r = process.getOutputPortData('Result');
            resampledSignals = r.get('ResampledSignals');
            
            % align (pass #1)
            disp('Alignement pass #1')
            process = biotracs.spectra.sigproc.model.Aligner();
            process.setInputPortData('SignalSet', resampledSignals);
            c = process.getConfig();
            c.updateParamValue('Target','average');
            c.updateParamValue('Intervals','whole');
            process.setInputPortData('SignalSet', resampledSignals);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Align/2']);
            process.run();
            alignmentResult = process.getOutputPortData('Result');
            alignedSignal = alignmentResult.get('AlignedSignalSet');
            alignmentResult.view('Plot');
            
            % align (pass #2)
            disp('Alignement pass #2')
            process = biotracs.spectra.sigproc.model.Aligner();
            process.setInputPortData('SignalSet', alignedSignal);
            c = process.getConfig();
            c.updateParamValue('Target','average');
            c.updateParamValue('Intervals',5);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Align/3']);
            process.run();
            alignmentResult = process.getOutputPortData('Result');
            targetSignal = alignmentResult.get('TargetSignal');
            alignmentResult.view('Plot');
            
            % align using previous signal
            process = biotracs.spectra.sigproc.model.Aligner();
            process.setInputPortData('SignalSet', alignedSignal);
            process.setInputPortData('TargetSignal', targetSignal);
            c = process.getConfig();
            c.updateParamValue('Intervals',5);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Align/4']);
            process.run();
            alignmentResult.view('Plot');
        end
    end
    
end
