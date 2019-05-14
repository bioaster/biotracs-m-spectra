classdef MSFeatureSetTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)

        function testFeatureSet(testCase)
            filePath = '../../testdata/FeatureSet/FeatureSet.csv';
            rowNameKeyValPatterns = {...
                'BatchPattern', 'MSBatch:([^_]*)', ...
                'SamplePattern', 'MSSampleType:Sample', ...
                'QcPattern', 'MSSampleType:QC', ...
                'SequenceNumberPattern', 'SeqNb:([^_]*)'};
            [ featureSet ] = biotracs.spectra.data.model.MSFeatureSet.import(filePath, rowNameKeyValPatterns{:});
            
            testCase.verifyClass(featureSet, 'biotracs.spectra.data.model.MSFeatureSet');
            
            idx = featureSet.getBatchIndexes();
            testCase.verifyEqual(idx,{'1','2'});
            
            seq = featureSet.getSequenceNumbers();
            testCase.verifyEqual(seq(1:8),11:18);
            testCase.verifyEqual(seq(9:13),21:25);
            
            [mz, rt, polarity] = featureSet.getMzRtPolarity();
            testCase.verifyEqual(mz(1:3),{'141.016950833487', '141.016973690419', '165.040757506031'});
            testCase.verifyEqual(rt(1:3),{'2336.1265', '55.9459352', '976.048191666667'});
            testCase.verifyEqual(polarity(1:3),{'', '', ''});
            
            [ qcFeatureSetContainer, sampleFeatureSetContainer ] = featureSet.split();
            testCase.verifyClass(qcFeatureSetContainer, 'biotracs.core.container.Set');
            testCase.verifyClass(sampleFeatureSetContainer, 'biotracs.core.container.Set');
            
            testCase.verifyEqual(qcFeatureSetContainer.getLength(), 2);
            testCase.verifyEqual(sampleFeatureSetContainer.getLength(), 2);
            
            [ qcFeatureSet1 ] = biotracs.spectra.data.model.MSFeatureSet.import('../../testdata/FeatureSet/QcFeatureSet1.csv', rowNameKeyValPatterns{:});
            [ qcFeatureSet2 ] = biotracs.spectra.data.model.MSFeatureSet.import('../../testdata/FeatureSet/QcFeatureSet2.csv', rowNameKeyValPatterns{:});
            [ sampleFeatureSet1 ] = biotracs.spectra.data.model.MSFeatureSet.import('../../testdata/FeatureSet/SampleFeatureSet1.csv', rowNameKeyValPatterns{:});
            [ sampleFeatureSet2 ] = biotracs.spectra.data.model.MSFeatureSet.import('../../testdata/FeatureSet/SampleFeatureSet2.csv', rowNameKeyValPatterns{:});
            
            testCase.verifyEqual( qcFeatureSetContainer.getAt(1).data, qcFeatureSet1.data );
            testCase.verifyEqual( qcFeatureSetContainer.getAt(1).rowNames, qcFeatureSet1.rowNames );
            testCase.verifyEqual( qcFeatureSetContainer.getAt(1).columnNames, qcFeatureSet1.columnNames );
            
            testCase.verifyEqual( qcFeatureSetContainer.getAt(2).data, qcFeatureSet2.data );
            testCase.verifyEqual( qcFeatureSetContainer.getAt(2).rowNames, qcFeatureSet2.rowNames );
            testCase.verifyEqual( qcFeatureSetContainer.getAt(2).columnNames, qcFeatureSet2.columnNames );
            
            testCase.verifyEqual( sampleFeatureSetContainer.getAt(1).data, sampleFeatureSet1.data );
            testCase.verifyEqual( sampleFeatureSetContainer.getAt(1).rowNames, sampleFeatureSet1.rowNames );
            testCase.verifyEqual( sampleFeatureSetContainer.getAt(1).columnNames, sampleFeatureSet1.columnNames );
            
            testCase.verifyEqual( sampleFeatureSetContainer.getAt(2).data, sampleFeatureSet2.data );
            testCase.verifyEqual( sampleFeatureSetContainer.getAt(2).rowNames, sampleFeatureSet2.rowNames );
            testCase.verifyEqual( sampleFeatureSetContainer.getAt(2).columnNames, sampleFeatureSet2.columnNames );
            
            qcFeatureSetContainer.summary('Deep', false);
            sampleFeatureSetContainer.summary('Deep', false);
            
            %featureSet.view('QcDriftPlot');
            featureSet.view('FeatureCountPlot', 'LabelFormat', {'pattern',{'Group:([^_]*)','SeqNb:([^_]*)'}});
            featureSet.view('QcCvPlot');
        end
        
        function testFeatureSetAltered(testCase)
            filePath = '../../testdata/FeatureSet/FeatureSet2.csv';
            rowNameKeyValPatterns = {...
                'BatchPattern', 'MSBatch:([^_]*)', ...
                'SamplePattern', 'MSSampleType:Sample', ...
                'QcPattern', 'MSSampleType:QC', ...
                'SequenceNumberPattern', 'SeqNb:([^_]*)'};
            [ featureSet ] = biotracs.spectra.data.model.MSFeatureSet.import(filePath, rowNameKeyValPatterns{:});
            
            testCase.verifyClass(featureSet, 'biotracs.spectra.data.model.MSFeatureSet');
            
            idx = featureSet.getBatchIndexes();
            testCase.verifyEqual(idx,{'1','2'});
        end
         
    end
    
end
