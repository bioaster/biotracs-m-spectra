classdef MzxmlParserTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    properties
        workingDir = [biotracs.core.env.Env.workingDir, '/biotracs/spectra/parser/MzXmlParserTests'];
    end
    
    methods (Test)
        
        function testMzXMLParsing(testCase)
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML');
            process = biotracs.spectra.parser.model.MzxmlParser();
            c = process.getConfig();
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            process.setInputPortData( 'DataFile', biotracs.data.model.DataFile(file) );
            process.run();
            spectrumSet = process.getOutputPortData('ResourceSet').get('QEX20141008-001.mzXML');
            mzStruct = mzxmlread( file );
            values = [ mzStruct.scan(1).peaks.mz(1:2:end), mzStruct.scan(1).peaks.mz(2:2:end) ];
            testCase.verifyEqual(class(spectrumSet.process), 'biotracs.spectra.parser.model.MzxmlParser');
            testCase.verifyEqual(spectrumSet.getAt(1).data, values);
        end
        
        
        function testZipFileParsing(testCase)
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML.gz');
            process = biotracs.spectra.parser.model.MzxmlParser();
            c = process.getConfig();
            c.updateParamValue('WorkingDirectory', testCase.workingDir);
            process.setInputPortData( 'DataFile', biotracs.data.model.DataFile(file) );
            process.run();
            spectrumMap = process.getOutputPortData('ResourceSet').get('QEX20141008-001.mzXML');
            file = fullfile('../../testdata/mzXML/QEX20141008-001.mzXML');
            mzStruct = mzxmlread(file);
            values = [ mzStruct.scan(1).peaks.mz(1:2:end), mzStruct.scan(1).peaks.mz(2:2:end) ];
            testCase.verifyEqual(spectrumMap.getAt(1).data, values);
            spectrumMap.view('TicPlot');
            spectrumMap.view('Plot');
            
            %Convert to SpectrumSet
            spectrumSet = spectrumMap.createSpectrumSet();
            testCase.verifyEqual(spectrumSet.getAt(1).data, values);
            spectrumMap.view('TicPlot');
            spectrumMap.view('Plot');
            
            %Check filter
            rt = [0.3297
                    0.5763
                    0.7639
                    0.9708
                    1.1587
                    1.3649
                    1.5530
                    1.7601
                    1.9463
                    2.1523]';
            n = length(rt);
            spectrumSet = spectrumMap.createSpectrumSet('Level', 1);
            [~, idx] = spectrumMap.getIndexesByLevel(1);
            testCase.verifyEqual(idx, 1:2:n);
            testCase.verifyEqual(spectrumSet.retentionTimes, rt(1:2:n), 'AbsTol', 1e-3)
            
            spectrumSet = spectrumMap.createSpectrumSet('Level', 2);
            [~, idx] = spectrumMap.getIndexesByLevel(2);
            testCase.verifyEqual(idx, 2:2:n);
            testCase.verifyEqual(spectrumSet.retentionTimes, rt(2:2:n), 'AbsTol', 1e-3);
            
            spectrumSet = spectrumMap.createSpectrumSet('RetentionTimes', rt([1,3,5]), 'RetentionTimeAbsTol', 0.2);
            [~, idx] = spectrumMap.getIndexesByRetentionTimes( rt([1,3,5]), 0.2 );
            testCase.verifyEqual(idx, [1,2,3,4,5]);
            testCase.verifyEqual(spectrumSet.retentionTimes, rt([1,2,3,4,5]), 'AbsTol', 1e-3);
            
            spectrumSet = spectrumMap.createSpectrumSet('PrecursorMz', 655, 'PrecursorMzAbsTol', 5);
            [~, idx] = spectrumMap.getIndexesByPrecursorMz( 655, 5 );
            testCase.verifyEqual(idx, 2:2:n);
            testCase.verifyEqual(spectrumSet.retentionTimes, rt(2:2:n), 'AbsTol', 1e-3);
            
            spectrumSet = spectrumMap.createSpectrumSet('PrecursorMz', 655, 'PrecursorMzAbsTol', 1);
            [~, idx] = spectrumMap.getIndexesByPrecursorMz( 655, 1 );
            testCase.verifyEmpty(idx);
            testCase.verifyEmpty(spectrumSet.retentionTimes);
            
            spectrumSet = spectrumMap.createSpectrumSet('PrecursorMz', 655, 'PrecursorMzAbsTol', 5, 'Level', 1);
            testCase.verifyEmpty(spectrumSet.retentionTimes);
            
            spectrumSet = spectrumMap.createSpectrumSet(...
                'RetentionTimes', rt([1,3,5]), 'RetentionTimeAbsTol', 0.2, ...
                'PrecursorMz', 655, 'PrecursorMzAbsTol', 5);
            [idx1] = spectrumMap.getIndexesByRetentionTimes( rt([1,3,5]), 0.2 );
            [idx2] = spectrumMap.getIndexesByPrecursorMz( 655, 5 );
            idx = idx1 & idx2;
            testCase.verifyEqual(rt(idx), rt([2,4]));
            testCase.verifyEqual(spectrumSet.retentionTimes, rt([2,4]), 'AbsTol', 1e-3);
            
            testCase.verifyEqual(spectrumSet.getAt(1).getPrecursorIntensity, 4.8555475e06, 'RelTol', 1e-9);
        end
        
    end
    
end
