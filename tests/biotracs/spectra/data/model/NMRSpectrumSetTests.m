classdef NMRSpectrumSetTests < matlab.unittest.TestCase
    
    properties (TestParameter)
    end
    
    methods(TestMethodTeardown)

    end
    
    methods (Test)
        
        function testDefaultConstructor(testCase)
            data = biotracs.spectra.data.model.NMRSpectrumSet();
            testCase.verifyClass(data, 'biotracs.spectra.data.model.NMRSpectrumSet');
            testCase.verifyEqual(data.description, '');
            testCase.verifyEqual(data.getClassName(), 'biotracs.spectra.data.model.NMRSpectrumSet');
            
            process = biotracs.core.mvc.model.Process();
            data.setProcess( process );
            testCase.verifyEqual(data.process, process);
        end
        
        function testCopyConstructor(testCase)
            x = (-10:0.03:10)'; %caution : division by zero will fail tests
            y = sin(3*x)./(3*x);
            s1 = biotracs.spectra.data.model.NMRSpectrum([x,y]);
            
            x = (-20:0.03:10)'; %caution : division by zero will fail tests
            y = sin(3*x)./(3*x);
            s2 = biotracs.spectra.data.model.NMRSpectrum([x,y]);
            
            spectrumSet = biotracs.spectra.data.model.NMRSpectrumSet();
            spectrumSet.add(s1).add(s2);
            
            spectrumSetCopy =  biotracs.spectra.data.model.NMRSpectrumSet(spectrumSet); 
            testCase.verifyEqual(spectrumSetCopy, spectrumSet);
            testCase.verifyTrue(spectrumSetCopy ~= spectrumSet);
        end
        
        function testImportBucketTable(testCase)
            filePath = fullfile('../../testdata/amix/small_amix_data.csv');
            %dataFile = biotracs.data.model.DataFile( filePath );
            
            s = biotracs.spectra.data.model.NMRSpectrumSet.import( filePath );
            %s.getAt(1).summary
            s.getAt(1).view('Plot');
            s.view('Plot');
            
            testCase.verifyEqual( getLength(s), 3 );
            
            spectrum = s.getAt(1);
            testCase.verifyEqual( getSize(spectrum), [3001,2] );
        end
        
%         function testImportBucketTableOline(testCase)
%             filePath = fullfile('D:\Setup_BA-S7-00\BA-S7-00-WP6-PT7-01\Data\NMR600\processed\Phase2_Database\AmixDataTable\fingerprinting_bin1e-3_160322.csv');
%             dataFile = biotracs.data.model.DataFile( filePath );
%             
%             s = biotracs.spectra.data.model.NMRSpectrumSet.import( dataFile );
%             s.getAt(1).summary
%             s.getAt(1).view('Plot');
%             s.view('Plot')
%         end
        
    end
    
end
