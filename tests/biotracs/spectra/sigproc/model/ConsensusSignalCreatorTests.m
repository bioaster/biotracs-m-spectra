classdef ConsensusSignalCreatorTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/spectra/sigproc/ConsensusSignalCreatorTests');
    end

    methods (Test)
        
        function testConsensusSignalCreatorFromCentroid(testCase)
            filePath = '../testdata/mzXML/QEX20141008-001.mzXML';
            spectrumSet = biotracs.spectra.data.model.MSSpectrumSet.import(filePath, 'WorkingDirectory', [testCase.workingDir, '/ConsensusSignalCreatorFromCentroid/1/']);
            process = biotracs.spectra.sigproc.model.ConsensusSignalCreator();
            c = process.getConfig();
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/ConsensusSignalCreatorFromCentroid/2/']);
            
            resamplingResult = spectrumSet.resample();
            spectrumSet = resamplingResult.get('ResampledSignals');
            
            process.setInputPortData('ResourceSet', spectrumSet);
            process.run();
            consensusResult = process.getOutputPortData('Result');            
            consensusResult.view('Plot');
        end
        
        function testConsensusSignalCreatorFromSeveralCentroid(testCase)
            filePath{1} = '../testdata/mzXML/QEX20141008-001.mzXML';
            spectrumSet{1} = biotracs.spectra.data.model.MSSpectrumSet.import(filePath{1}, 'WorkingDirectory', [testCase.workingDir, '/ConsensusSignalCreatorFromSeveralCentroid/1/']);
            resamplingResult = spectrumSet{1}.resample();
            spectrumSet{1} = resamplingResult.get('ResampledSignals');
            spectrumSet{2} = spectrumSet{1};
            r = biotracs.core.mvc.model.ResourceSet();
            r.setElements(spectrumSet);
            process = biotracs.spectra.sigproc.model.ConsensusSignalCreator();
            c = process.getConfig();
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/ConsensusSignalCreatorFromCentroid/2/']);
            process.setInputPortData('ResourceSet', r);
            process.run();
            consensusResult = process.getOutputPortData('Result');            
            consensusResult.view('Plot', 'SignalSetIndex', 2);
        end

    end
    
end
