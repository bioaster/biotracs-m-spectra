% BIOASTER
%> @file 		MSGroupTableCreator.m
%> @class 		biotracs.spectra.data.model.MSGroupTableCreator
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2017

classdef MSGroupTableCreator < biotracs.core.mvc.model.Process
    
    properties(SetAccess = protected)
    end
    
    methods
        
        % Constructor
        function this = MSGroupTableCreator( )
            %#function biotracs.spectra.data.model.MSGroupTableCreatorConfig biotracs.spectra.data.model.MSFeatureSet biotracs.spectra.data.model.MSGroupTable
            this@biotracs.core.mvc.model.Process();
            
            this.addInputSpecs({...
                struct(...
                'name', 'IsoFeatureTable',...
                'class', 'biotracs.spectra.data.model.MSFeatureSet' ...
                ),...
                });
            
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'GroupTable',...
                'class', 'biotracs.spectra.data.model.MSGroupTable' ...
                )...
                });
        end
        
    end
    
    methods(Access = protected)
        
        function doRun( this )
            isoFeatureTable = this.getInputPortData('IsoFeatureTable');
            [ oGroupTable ] = this.doCreateIdTable( isoFeatureTable);
            this.setOutputPortData('GroupTable', oGroupTable);
        end
        
        function [ oGroupTable ] = doCreateIdTable(~, isoFeatureTable)
            groupFeatureNames = isoFeatureTable.getColumnNames();
            groupFeatureTags = isoFeatureTable.tags{2};
            
            nbGroups = length(groupFeatureNames);
            nbColumns = length(biotracs.spectra.data.model.MSGroupTable.DEFAULT_COLUMN_NAMES);
            nbFeaturePerGroupEstimation = 5;  %preallocate about 5 features per group
            groupData = cell(nbGroups*nbFeaturePerGroupEstimation, nbColumns);   
            
            cpt = 1;
            for i= 1:nbGroups
                groupIndex = groupFeatureTags{i}.IsofeatureGroupIndex;
                isIsofeature  = isfield(groupFeatureTags{i}, 'IsofeatureIndexes');
                if isIsofeature
                    if isfield(groupFeatureTags{i}, 'AdductIndexes')
                        for ii=1:length(groupFeatureTags{i}.AdductPairs)
                            adductPairList = groupFeatureTags{i}.AdductPairs{ii};
                            nbCombinations = length(adductPairList);
                            for k=1:nbCombinations
                                for kk=1:2
                                    featureNamesSplitted =  regexp(adductPairList{k}{kk}.feature,'M(?<M>\d+.\d*)_T(?<T>\d+.\d*|-\d+.\d*)_?(?<Pol>Pos|Neg)?','names');
                                    adductsInfo = adductPairList{k}{kk}.formula;
                                    features =  {groupFeatureNames{i}, ...
                                                featureNamesSplitted.M, ...
                                                featureNamesSplitted.T, ...
                                                featureNamesSplitted.Pol, ...
                                                groupIndex, ...
                                                adductsInfo};
                                    groupData(cpt,:) = features;
                                    cpt = cpt+1;
                                end
                            end
                        end
                    else
                        adductsInfo = '';
                        isoFeatureIndexes = groupFeatureTags{i}.IsofeatureIndexes;
                        nbFeatures = length(isoFeatureIndexes);
                        for j = 1:nbFeatures
                            %Commented if proteomic data have to be used
                            isofeatureName = groupFeatureTags{i}.IsofeatureNames{j};
                            featureNamesSplitted =  regexp(isofeatureName,'M(?<M>\d+.\d*)_T(?<T>\d+.\d*|-\d+.\d*)_?(?<Pol>Pos|Neg)?','names');
                            features = {groupFeatureNames{i}, ...
                                        featureNamesSplitted.M, ...
                                        featureNamesSplitted.T, ...
                                        featureNamesSplitted.Pol, ...
                                        groupIndex, ...
                                        adductsInfo};
                            groupData(cpt,:) = features;
                            cpt = cpt+1;
                        end 
                    end
                else
                    adductsInfo = '';
                    featureNamesSplitted =  regexp(groupFeatureNames{i},'M(?<M>\d+.\d*)_T(?<T>\d+.\d*|-\d+.\d*)_?(?<Pol>Pos|Neg)?','names');
                    features =  {groupFeatureNames{i}, ...
                                featureNamesSplitted.M, ...
                                featureNamesSplitted.T, ...
                                featureNamesSplitted.Pol, ...
                                groupIndex, ...
                                adductsInfo};
                    groupData(cpt,:) = features;
                    cpt = cpt+1;
                end
                
                % pre-allocate a new block
                if( cpt == nbGroups*nbFeaturePerGroupEstimation )
                    groupData = vertcat(groupData, cell(nbGroups*nbFeaturePerGroupEstimation, nbColumns)); %#ok<AGROW>
                end
                
            end
            groupData(cpt:end,:) = [];  %remove un asigned rows
            
            oGroupTable = biotracs.spectra.data.model.MSGroupTable( groupData, biotracs.spectra.data.model.MSGroupTable.DEFAULT_COLUMN_NAMES );
        end
    end
end
