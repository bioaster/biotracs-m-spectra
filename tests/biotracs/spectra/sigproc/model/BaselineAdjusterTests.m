classdef BaselineAdjusterTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs.spectra.sigproc.BaselineAdjusterTests');
    end

    methods (Test)
        
        function testAlign(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signalSet = biotracs.spectra.data.model.SignalSet();
            for i=2:size(X,2)
                m = mean(X(:,i));
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)+m*2] );    %add baselines
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['s', num2str(i-1)]);
            end
            
            % resample
            process = biotracs.spectra.sigproc.model.Resampler();
            process.setInputPortData('SignalSet', signalSet);
            c = process.getConfig();
            %c.updateParamValue('SamplingMultiplier',1.1);
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            process.run();
            r = process.getOutputPortData('Result');
            resampledSignals = r.get('ResampledSignals');
            
            % baseline adjustment
            process = biotracs.spectra.sigproc.model.BaselineAdjuster();
            process.setInputPortData('SignalSet', resampledSignals);
            c = process.getConfig();
            c.updateParamValue('WorkingDirectory', testCase.workingDir)...
                .updateParamValue('WindowSize', 0.5)...
                .updateParamValue('StepSize', 0.5);
            process.run();
            r = process.getOutputPortData('SignalSet');
            
            %r.bindView(biotracs.spectra.sigproc.view.BaselineAdjustmentSignalSet());
            r.view('BaselineAdjustmentPlot');
        end

    end
    
end
