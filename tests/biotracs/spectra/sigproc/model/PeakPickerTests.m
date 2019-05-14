classdef PeakPickerTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/spectra/sigproc/PeakPickingTests');
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        
        function testPeakPicking1D(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signal = biotracs.spectra.data.model.Signal( [X(:,1), X(:,2)] );
            signal.setLabel('NMR data in profile mode');
            signal.setColumnNames({'Delta','Intensity'});
            
            % peak pick
            process = biotracs.spectra.sigproc.model.PeakPicker();
            c = process.getConfig();
            process.setInputPortData('SignalSet', signal);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/PeakPicking1D/1/']);
            process.run();
            result = process.getOutputPortData('Result');
            centroidedSignal = result.get('CentroidedSignals');
            signal.view('Plot');
            centroidedSignal.view('Plot', 'NewFigure', false, 'Color', 'r');

            %peak picks again
            process = biotracs.spectra.sigproc.model.PeakPicker();
            c = process.getConfig();
            process.setInputPortData('SignalSet', centroidedSignal);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/PeakPicking1D/2/']);
            process.run();
            result2 = process.getOutputPortData('Result');
            centroidedSignal2 = result2.get('CentroidedSignals');
            testCase.verifyEqual( centroidedSignal2, centroidedSignal );
            testCase.verifyTrue( centroidedSignal == centroidedSignal2 ); %references are equals
        end
        
        function testPeakPicking2D(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signalSet = biotracs.spectra.data.model.SignalSet();
            for i=2:size(X,2)
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)] );
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['s', num2str(i-1)]);
            end
            
            % peak pick
            process = biotracs.spectra.sigproc.model.PeakPicker();
            c = process.getConfig();
            process.setInputPortData('SignalSet', signalSet);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/PeakPicking2D']);
            process.run();
            result = process.getOutputPortData('Result');
            centroidedSignals = result.get('CentroidedSignals');
            signalSet.view('Plot');
            centroidedSignals.view('Plot', 'NewFigure', false, 'Color', 'r');
        end

    end
    
end
