classdef SignalSetTests < matlab.unittest.TestCase

    methods (Test)
                
        function testDefaultConstructor(testCase)
            spectrumSet =  biotracs.spectra.data.model.SignalSet();
            testCase.verifyClass(spectrumSet, 'biotracs.spectra.data.model.SignalSet');
            testCase.verifyEqual(spectrumSet.label, 'biotracs.spectra.data.model.SignalSet');
            testCase.verifyEqual(spectrumSet.getLength(), 0);
        end
        
        function testCopyConstructor(testCase)
            spectrumSet =  biotracs.spectra.data.model.SignalSet();
            element1 = biotracs.spectra.data.model.Signal();
            element2 = biotracs.spectra.data.model.Signal();
            spectrumSet.add( element1 );
            spectrumSet.add( element2 );
            
            spectrumSetCopy =  biotracs.spectra.data.model.SignalSet.fromSignalSet(spectrumSet);
            testCase.verifyEqual(spectrumSetCopy, spectrumSet);
            testCase.verifyTrue(spectrumSetCopy ~= spectrumSet);
        end
        
        function testAddElements(testCase)
            spectrumSet =  biotracs.spectra.data.model.SignalSet();
            element1 = biotracs.spectra.data.model.Signal();
            element2 = biotracs.spectra.data.model.Signal();
            spectrumSet.add( element1 );
            spectrumSet.add( element2 );
            
            testCase.verifyEqual(spectrumSet.getLength(), 2);
            testCase.verifyEqual(spectrumSet.getAt(1), element1);
            testCase.verifyEqual(spectrumSet.getAt(2), element2);
            
            try
                r = biotracs.core.mvc.model.ResourceSet();
                spectrumSet.add( r );
                error('An error was expected')
            catch err
                testCase.verifyEqual(err.identifier, 'BIOTRACS:Set:ElementNotAllowed');
            end
            
            try
                s = biotracs.spectra.data.model.Signal();
                spectrumSet.setAt( 8, s );
                error('An error was expected')
            catch err
                testCase.verifyEqual(err.message(), 'Index out of range');
            end
            
        end
        
        function testGetSginalList( testCase )
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] =  biotracs.spectra.data.model.MSSpectrumSet.import(file);
            
            %Convert to biotracs.spectra.data.model.SignalSet
            signalSet = biotracs.spectra.data.model.SignalSet.fromSignalSet(spectrum3d);
            
            peakList = signalSet.getSignalList();
            testCase.verifyEqual( length(peakList), 10 );
            
            testCase.verifyEqual( size(peakList{1}), [1710, 2] );
            testCase.verifyEqual( peakList{1}, signalSet.getAt(1).getData() );
            testCase.verifyEqual( peakList{2}, signalSet.getAt(2).getData() );
        end
        
        
        function testGetReducedSignalList( testCase )
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] =  biotracs.spectra.data.model.MSSpectrumSet.import(file);
            
            %Convert to biotracs.spectra.data.model.SignalSet
            signalSet = biotracs.spectra.data.model.SignalSet.fromSignalSet(spectrum3d);
            
            allPeakList = signalSet.getSignalList();
            reducedPeakList = signalSet.getSignalList(4:8);
            
            testCase.verifyEqual( reducedPeakList, allPeakList(4:8) );
        end
        
        function testPlots(testCase)
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] =  biotracs.spectra.data.model.MSSpectrumSet.import(file);
            
            %Convert to biotracs.spectra.data.model.SignalSet
            signalSet = biotracs.spectra.data.model.SignalSet.fromSignalSet(spectrum3d);
            
            signalSet.getAt(1).view('Plot', 'Representation', 'Centroid');
            signalSet.view('Plot');
            signalSet.view('DotPlot', 'Quantile', 0.95 );
            signalSet.view('HeatMap', 'LogTransform', true );
        end
        
        
        function testResampling2D(testCase)
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML');
            [ spectrum3d ] =  biotracs.spectra.data.model.MSSpectrumSet.import(file);
            
            %Convert to biotracs.spectra.data.model.SignalSet
            signalSet = biotracs.spectra.data.model.SignalSet.fromSignalSet(spectrum3d);
            
            r = signalSet.resample('NbSamples', 1e5, 'Range',[0, 500]);
            resampledSignals = r.get('ResampledSignals');
            
            spectrum3d.view('Plot');
            resampledSignals.view('Plot', 'NewFigure', false, 'Color', 'r');
            
            %testCase.verifyGreaterThan(rho, 0.9);
        end
        
        function testBinning2D(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            
            signalSet = biotracs.spectra.data.model.SignalSet();
            for i=2:size(X,2)
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)] );
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['s', num2str(i-1)]);
            end
            
            r = signalSet.bin('BinWidth',0.05);
			r.view('Plot');
            stats = r.get('Statistics');
            rho = [0.855464219730476
                0.861291607138627
                0.857220365678140
                0.862163692461140
                0.845704001893219
                0.870744961985520
                0.871724843428988
                0.865997451357615];
            testCase.verifyEqual( stats.getDataByColumnName('correlation'), rho, 'AbsTol', 1e-2 );
        end
        
        function testBinning2DConvertToDataSet(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signalSet = biotracs.spectra.data.model.SignalSet();
            for i=2:size(X,2)
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)] );
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['Sample', num2str(i-1)]);
            end
            
            r = signalSet.bin('BinWidth',0.05);
            dbs = r.get('DiscreteBinnedSignals');
            
            %convert to dataSet/dataMatrix for machine learning
            dataSet = dbs.toDataSet();
            testCase.verifyEqual( dataSet.data(1,:), dbs.getAt(1).data(:,2)' );
            testCase.verifyEqual( dataSet.data(3,:), dbs.getAt(3).data(:,2)' );
            testCase.verifyEqual( dataSet.getRowNames(1:4), {'Sample1','Sample2','Sample3','Sample4'} );
        end
        
        function testAlignment(testCase)
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signalSet = biotracs.spectra.data.model.SignalSet();
            for i=2:size(X,2)
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)] );
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['Sample', num2str(i-1)]);
            end
            
            resamplingResult = signalSet.resample();
            resampledSignals = resamplingResult.get('ResampledSignals');
            alignementResult = resampledSignals.align();
            alignementResult.view('Plot');
        end
        
        function testPeakPicking( testCase )
            X = load('../../testdata/nmr/spectra.txt', '-ascii');
            signalSet = biotracs.spectra.data.model.SignalSet();
            for i=2:size(X,2)
                s = biotracs.spectra.data.model.Signal( [X(:,1), X(:,i)] );
                s.setLabel('NMR data in profile mode');
                s.setColumnNames({'Delta','Intensity'});
                signalSet.add(s, ['Sample', num2str(i-1)]);
            end
            
            result = signalSet.pickPeaks();
			result.view('Plot');
        end
  
    end
    
end
