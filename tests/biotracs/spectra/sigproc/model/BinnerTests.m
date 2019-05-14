classdef BinnerTests < matlab.unittest.TestCase
    
    properties
        workingDir = fullfile(biotracs.core.env.Env.workingDir(), '/biotracs/spectra/sigproc/BinningTests');
    end

    methods (Test)
        
        function testUniformBinningNMR1D(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signal = biotracs.spectra.data.model.Signal( [X(:,1), X(:,2)] );
            signal.setLabel('NMR data in profile mode');
            signal.setColumnNames({'Delta','Intensity'});
            
            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', signal);
            c = process.getConfig();
            c.updateParamValue('BinWidth',0.025);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/BinningNMR1D']);
            process.run();
            r = process.getOutputPortData('Result');
            r.view('Plot');
            title('Uniform binning')
            stats = r.get('Statistics');
            testCase.verifyGreaterThan( stats.getDataByColumnName('correlation'), 0.9 );
        end
        
        function testGaussianBinningNMR1D(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signal = biotracs.spectra.data.model.Signal( [X(:,1), X(:,2)] );
            signal.setLabel('NMR data in profile mode');
            signal.setColumnNames({'Delta','Intensity'});
            
            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', signal);
            c = process.getConfig();
            c.updateParamValue('BinWidth',0.04);
            c.updateParamValue('Method','gaussian');
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/BinningNMR1D']);
            process.run();
            r = process.getOutputPortData('Result');
            r.view('Plot');
            title('Gaussian binning');
            stats = r.get('Statistics');
            testCase.verifyGreaterThan( stats.getDataByColumnName('correlation'), 0.8 );
        end
            
        function testBinningNMR1DWithResampling(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signal = biotracs.spectra.data.model.Signal( [X(:,1), X(:,2)] );
            signal.setLabel('NMR data in profile mode');
            signal.setColumnNames({'Delta','Intensity'});
            
            r = signal.resample('FWHM',0.001);
            signal = r.get('ResampledSignals');
            
            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', signal);
            c = process.getConfig();
            c.updateParamValue('BinWidth',0.04);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/BinningNMR1D']);
            process.run();
            r = process.getOutputPortData('Result');
            r.view('Plot');
            stats = r.get('Statistics');
            testCase.verifyGreaterThan( stats.getDataByColumnName('correlation'), 0.9 );
        end
  
        function testBinningNMR1DWithRange(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signal = biotracs.spectra.data.model.Signal( [X(:,1), X(:,2)] );
            signal.setLabel('NMR data in profile mode');
            signal.setColumnNames({'Delta','Intensity'});
            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', signal);
            c = process.getConfig();
            process.setInputPortData('SignalSet', signal);
            c.updateParamValue('BinWidth',0.025);
            c.updateParamValue('Range',[0,2]);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/BinningNMR1DWithRange']);
            process.run();
            r = process.getOutputPortData('Result');
            dbs = r.get('DiscreteBinnedSignals');
            cbs = r.get('ContinuousBinnedSignals');
            stats = r.get('Statistics');
            signal.view('Plot');
            dbs.view('Plot', 'NewFigure', false, 'LineStyle', 'none', 'Marker', '+', 'Color', 'g');
            cbs.view('Plot', 'NewFigure', false, 'LineStyle', '-', 'Color', 'r');
            testCase.verifyGreaterThan( stats.getDataByColumnName('correlation'), 0.86 );
        end
        
        function testBinningNMR1DWithBinVector(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signal = biotracs.spectra.data.model.Signal( [X(:,1), X(:,2)] );
            signal.setLabel('NMR data in profile mode');
            signal.setColumnNames({'Delta','Intensity'});
            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', signal);
            c = process.getConfig();
            c.updateParamValue('BinWidth',0.025);
            c.updateParamValue('BinTicks',[0:0.1:2,2.5:0.25:3]);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/BinningNMR1DWithBinVector']);
            process.run();
            r = process.getOutputPortData('Result');
            dbs = r.get('DiscreteBinnedSignals');
            cbs = r.get('ContinuousBinnedSignals');
            stats = r.get('Statistics');
            signal.view('Plot');
            dbs.view('Plot', 'NewFigure', false, 'LineStyle', 'none', 'Marker', '+', 'Color', 'g');
            cbs.view('Plot', 'NewFigure', false, 'LineStyle', '-', 'Color', 'r');
            testCase.verifyGreaterThan( stats.getDataByColumnName('correlation'), 0.26 );
        end
        
        function testBinningRMN2D(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signalSet = biotracs.spectra.data.model.SignalSet();
            for i=2:size(X,2)
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)] );
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['s', num2str(i-1)]);
            end
            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', signalSet);
            c = process.getConfig();
            c.updateParamValue('BinWidth',0.025);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/BinningRMN2D']);
            process.run();
            r = process.getOutputPortData('Result');
            dbs = r.get('DiscreteBinnedSignals');
            cbs = r.get('ContinuousBinnedSignals');
            stats = r.get('Statistics');
            signalSet.view('Plot');
            dbs.view('Plot', 'NewFigure', false, 'LineStyle', 'none', 'Marker', '+', 'Color', 'g');
            cbs.view('Plot', 'NewFigure', false, 'LineStyle', '-', 'Color', 'r');
            c = [0.947980825847241
                   0.953025789591272
                   0.948620895648743
                   0.955270360813374
                   0.962082422158482
                   0.958292199564058
                   0.958884329485080
                   0.954193165931178];
            testCase.verifyEqual( stats.getDataByColumnName('correlation'), c, 'AbsTol', 1e-2 );
        end
        
        function testBinningRMN2dAsynchronousChemicalShift(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signalSet = biotracs.spectra.data.model.SignalSet();
            shift = [0.7, -1.1, 0.5, 1.5, 0, -0.5, 1, 0];
            for i=2:size(X,2)
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)] );
                s.setData( [s.data(:,1)+shift(i-1), s.data(:,2)] );
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['s', num2str(i-1)]);
            end 
            s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,2)] );
            s.setLabel('NMR data in profile mode');
            s.setColumnNames({'Delta','Intensity'});
            
            r = signalSet.resample();
            signalSet = r.get('ResampledSignals');
                    
            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', signalSet);
            c = process.getConfig();
            c.updateParamValue('BinWidth',0.04);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/BinningRMN2dAsynchronousChemicalShift']);
            tic
            process.run();
            toc
            r = process.getOutputPortData('Result');
            dbs = r.get('DiscreteBinnedSignals');
            cbs = r.get('ContinuousBinnedSignals');
            stats = r.get('Statistics');
            signalSet.view('Plot');
            dbs.view('Plot', 'NewFigure', false, 'LineStyle', 'none', 'Marker', '+', 'Color', 'g');
            cbs.view('Plot', 'NewFigure', false, 'LineStyle', '-', 'Color', 'r');
            c = [0.96
                   0.95
                   0.95
                   0.95
                   0.89
                   0.97
                   0.95
                   0.98];
            testCase.verifyEqual( stats.getDataByColumnName('correlation'), c, 'AbsTol', 0.1 );
        end
        
        function testUniformBinningRMN2dWithRanges(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signalSet = biotracs.spectra.data.model.SignalSet();
            for i=2:size(X,2)
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)] );
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['s', num2str(i-1)]);
            end
            
            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', signalSet);
            c = process.getConfig();
            c.updateParamValue('BinWidth',0.025);
            c.updateParamValue('Range',[0,2]);
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/BinningRMN2dWithRanges']);
            tic
            process.run();
            toc
            r = process.getOutputPortData('Result');
            dbs = r.get('DiscreteBinnedSignals');
            cbs = r.get('ContinuousBinnedSignals');
            stats = r.get('Statistics');
            signalSet.view('Plot');
            dbs.view('Plot', 'NewFigure', false, 'LineStyle', 'none', 'Marker', '+', 'Color', 'g');
            cbs.view('Plot', 'NewFigure', false, 'LineStyle', '-', 'Color', 'r');
            title('Uniform 2D binning with ranges');
            c = [0.944199919396685
               0.946664472467688
               0.944624270866636
               0.948331605722347
               0.941873179341024
               0.950502482875177
               0.951231131609399
               0.947542515775358];
            testCase.verifyEqual( stats.getDataByColumnName('correlation'), c, 'AbsTol', 0.01 );
        end
        
        function testGaussianBinningRMN2dWithRanges(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signalSet = biotracs.spectra.data.model.SignalSet();
            for i=2:size(X,2)
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)] );
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['s', num2str(i-1)]);
            end
            
            process = biotracs.spectra.sigproc.model.Binner();
            process.setInputPortData('SignalSet', signalSet);
            c = process.getConfig();
            c.updateParamValue('BinWidth',0.025);
            c.updateParamValue('Range',[0,2]);
            c.updateParamValue('Method','gaussian');
            c.updateParamValue('WorkingDirectory', [testCase.workingDir, '/BinningRMN2dWithRanges']);
            process.run();
            r = process.getOutputPortData('Result');
            dbs = r.get('DiscreteBinnedSignals');
            cbs = r.get('ContinuousBinnedSignals');
            stats = r.get('Statistics');
            signalSet.view('Plot');
            dbs.view('Plot', 'NewFigure', false, 'LineStyle', 'none', 'Marker', '+', 'Color', 'g');
            cbs.view('Plot', 'NewFigure', false, 'LineStyle', '-', 'Color', 'r');
            title('Gaussian 2D binning with ranges');
            c = [0.944199919396685
               0.946664472467688
               0.944624270866636
               0.948331605722347
               0.941873179341024
               0.950502482875177
               0.951231131609399
               0.947542515775358];
            testCase.verifyEqual( stats.getDataByColumnName('correlation'), c, 'AbsTol', 0.04 );
        end
        
    end
    
end
