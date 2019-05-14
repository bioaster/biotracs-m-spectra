classdef FilterTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs.spectra.sigproc.FilteringTests');
    end

    methods (Test)
        
        function testFilteringWithMaxTotalIntensityRatio(testCase)
            file = fullfile('../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] = biotracs.spectra.data.model.MSSpectrumSet.import(...
                file, ...
                'WorkingDirectory', [testCase.workingDir, '/Filtering/1/']...
                );
            spectrum3d.view('Plot', 'SubPlot', {2,2,1});
            spectrum3d.view('TicPlot', 'NewFigure', false, 'SubPlot', {2,2,2});
            process = biotracs.spectra.sigproc.model.Filter();
            c = process.getConfig();
            process.setInputPortData('SignalSet', spectrum3d);
            c.updateParamValue('MinTotalIntensityRatio', 0.1);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Filtering/2/']);
            process.run();
            filteredSpectrum3d = process.getOutputPortData('SignalSet');
            filteredSpectrum3d.view('Plot', 'NewFigure', false, 'SubPlot', {2,2,3});
            filteredSpectrum3d.view('TicPlot', 'NewFigure', false, 'SubPlot', {2,2,4});
        end
        
        function testFilteringWithIntensity(testCase)
            file = fullfile('../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] = biotracs.spectra.data.model.MSSpectrumSet.import(...
                file, ...
                'WorkingDirectory', [testCase.workingDir, '/Filtering/1/']...
                );
            spectrum3d.view('Plot', 'SubPlot', {2,2,1});
            spectrum3d.view('TicPlot', 'NewFigure', false, 'SubPlot', {2,2,2});
            process = biotracs.spectra.sigproc.model.Filter();
            c = process.getConfig();
            process.setInputPortData('SignalSet', spectrum3d);
            c.updateParamValue('MinIntensity', 1e6);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Filtering/2/']);
            process.run();
            filteredSpectrum3d = process.getOutputPortData('SignalSet');
            filteredSpectrum3d.view('Plot', 'NewFigure', false, 'SubPlot', {2,2,3});
            filteredSpectrum3d.view('TicPlot', 'NewFigure', false, 'SubPlot', {2,2,4});
        end
        
        function testFilteringWithIntensityAndMaxTotalIntensityRatio(testCase)
            file = fullfile('../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] = biotracs.spectra.data.model.MSSpectrumSet.import(...
                file, ...
                'WorkingDirectory', [testCase.workingDir, '/Filtering/1/']...
                );
            spectrum3d.view('Plot', 'SubPlot', {2,2,1});
            spectrum3d.view('TicPlot', 'NewFigure', false, 'SubPlot', {2,2,2});
            process = biotracs.spectra.sigproc.model.Filter();
            c = process.getConfig();
            process.setInputPortData('SignalSet', spectrum3d);
            c.updateParamValue('MinTotalIntensityRatio', 0.1);
            c.updateParamValue('MinIntensity', 1e6);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/Filtering/2/']);
            process.run();
            filteredSpectrum3d = process.getOutputPortData('SignalSet');
            filteredSpectrum3d.view('Plot', 'NewFigure', false, 'SubPlot', {2,2,3});
            filteredSpectrum3d.view('TicPlot', 'NewFigure', false, 'SubPlot', {2,2,4});
        end
        
    end
    
end
