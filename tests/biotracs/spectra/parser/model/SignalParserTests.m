classdef SignalParserTests < matlab.unittest.TestCase

    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir, '/biotracs/spectra/parser/SignalParserTests');
    end
    
    methods (Test)
     
        function testParseSignals(testCase)
            file = fullfile('../../testdata/Signal');
            process = biotracs.spectra.parser.model.SignalParser();
            c = process.getConfig();
            c.updateParamValue('WorkingDirectory',testCase.workingDir);
            c.updateParamValue('Representation', biotracs.spectra.data.model.Signal.REPRESENTATION_CENTROID);
            c.updateParamValue('ReadRowNames', false)
            process.setInputPortData( 'DataFile', biotracs.data.model.DataFile(file) );
            process.run();
            
            signalSet = process.getOutputPortData('ResourceSet');
            testCase.verifyClass(signalSet, 'biotracs.spectra.data.model.SignalSet');
            
            signalSet.view('Plot');
            signalSet.getAt(1).view('Plot');
            
            resamplingResult = signalSet.resample();
            resampledSignalSet = resamplingResult.get('ResampledSignals');
            dataSet = resampledSignalSet.toDataSet().selectByColumnIndexes(1:5);
            dataSet.summary();
        end
        
    end
    
end
