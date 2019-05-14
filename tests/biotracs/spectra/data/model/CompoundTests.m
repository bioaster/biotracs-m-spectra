classdef CompoundTests < matlab.unittest.TestCase

    properties (TestParameter)
    end
    
    methods (Test)
        
        function testCompoundGetIsotopeDistributionAsSpectrum(testCase)
            %import biotracs.biochem.entity.model.*;
            c =  biotracs.spectra.data.model.Compound( [62 103 16 26 1] );
            testCase.verifyClass(c, 'biotracs.spectra.data.model.Compound');
            
            testCase.verifyEqual(  c.formula, [62 103 16 26 1] );
            testCase.verifyEqual(  c.label, 'C62H103N16O26S1' );
            
            spectrum = c.getIsotopicDistributionAsSpectrum();
            
            MD =[
               1519.6950132541                       100
              1520.69756459421          75.9330587185868
              1521.69888574913          38.3000166574044
              1522.70022259236          14.4550498469202
              1523.70158615925          4.45290012708241
              1524.70304591416          1.16543505807008
              1525.70458947765         0.266712445312406
              1526.70620822928        0.0544291357120498
              1527.70788852039        0.0100531002039501
              1528.70961954344       0.00169977989780045
              1529.71139207136      0.000265483234683716];
          
            testCase.verifyClass(spectrum, 'biotracs.spectra.data.model.MSSpectrum');
            testCase.verifyEqual(spectrum.data, MD, 'RelTol', 1e-9);
            testCase.verifyEqual(spectrum.label, c.label);
            testCase.verifyEqual(spectrum.getXAxisLabel(), 'MZ');
            testCase.verifyEqual(spectrum.getYAxisLabel(), 'Relative Abundance');
            spectrum.view('Plot');
        end
        
    end
    
end
