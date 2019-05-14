function A = rbnmr(iFilePath)
    % RBNMR     Reads processed Bruker NMR-data.
    %
    % SYNTAX    A = rbnmr;			% Reads 1r/2rr in the current working dir.
    %			A = rbnmr;			% Finds 1r/2rr files (rec.) in pdata/1
    %			A = rbnmr(DS);		% Reads the files in the cell DS
    %			A = rbnmr(file);	% Reads the data specified in the text file
    %			A = rbnmr('<Datadirectory>/?0')
    %								% Finds 1r/2rr-files with expno
    %								%	10, 20, ..., 90 in pdata/1
    %			A = rbnmr('<Datadirectory>/?0/pdata/999')
    %								% Finds 1r/2rr-files with expno
    %								%	10, 20, ..., 90 in pdata/999
    %
    % OUT       A: Struct with nmrdata:

    % Nils Nyberg, SLU, 2001-05-02
    % rewritten 2007-09-19, Matlab rel. R2007a
    % partly rewritten 2008-09-18, rel. R2008a
    %		New perl-based search function
    %		New parameter checking and organization of functionsz
    % 2008-11-13, Empty 'title'-file allowed
    % 2009-08-12, New option 'search': Avoid 'search' on UNC pathnames
    % 2009-09-29, Robust regexp ('Anything'-case) to handle strange parameter files
    % 2009-09-29, ME-exception returned as 'title'.
    % 2010-08-05, Robust regexp ('EmptyPar'-case) to handle parameter files with
    % whitespaces changed(?) into line breaks.
    % 2011-05-18, 'Strange title-file:' returned as Title-field if textscan
    % fails to read the title-file.
    % 2011-06-01, Changed regexp to allow the new more relaxed data path
    %
    % Nils Nyberg, Copenhagen University, nn@sund.ku.dk
    
    % BIOASTER
    % Simplified version of rbnmr
    % iFilePath is the path of the 1r file
    % For example : 'MyDataPath/NMR/1/pdata/1/1r'

    A = parseData(iFilePath);
return;

function A = parseData(iFilePath)
    [iDirPath, ~, ~] = fileparts(iFilePath);
    
    %% Read first line of title-file
    fid = fopen(fullfile(iDirPath, '../title'),'r');
    if (fid ~= -1)
        title = textscan(fid,'%s','Whitespace','\n','ReturnOnError',1);
        fclose(fid);
        if isempty(title{1})
            A.Title = '<Title file empty>';
        else
            try
                A.Title = title{1}{1};
            catch ME
                A.Title = sprintf('Strange title-file: %s',ME.message);
            end
        end
    else
        A.Title = '<Title file empty>';
    end


    %% Date and file information
    [path,name,ext] = fileparts(iDirPath);
    if isempty(path); path = pwd; end
    A.Info.ImportDate = datestr(now);
    A.Info.FileName = [name ext];
    A.Info.FilePath = path;
    A.Info.Title = A.Title;


    %% Add relative path from 'path'
    q = regexpi(...
        fullfile(A.Info.FilePath,A.Info.FileName),...
        'data[/\\].+[/\\]nmr[/\\](.+)[/\\](\d+)[/\\]pdata[/\\](\d+)[/\\](.+)','tokens');
    s = '/';	% unix-style
    try
        A.Info.RelativePath = [q{1}{1},s,q{1}{2},s,'pdata',s,q{1}{3},s,q{1}{4}];
    catch ME
        % Do nothing. Relative path does not seem to make any sense...
    end


    %% Check parameter files and read parameters
    if isfile(fullfile(iDirPath, 'proc2s'))
        A.Proc2s = readnmrpar(fullfile(iDirPath, 'proc2s'));
    end
    if isfile(fullfile(iDirPath, '../../acqu2s'))
        A.Acqu2s = readnmrpar(fullfile(iDirPath, '../../acqu2s'));
    end

    if isfile(fullfile(iDirPath, '../../acqus'))
        A.Acqus = readnmrpar(fullfile(iDirPath, '../../acqus'));
    else
        error('RBNMR: Could not find ''%s''', fullfile(iDirPath, '../../acqus'))
    end

    if isfile(fullfile(iDirPath, 'procs'))
        A.Procs = readnmrpar(fullfile(iDirPath, 'procs'));
    end


    %% Add acq-date
    % Converts time given in UTC (base 1970, seconds) as matlab serial time
    % (base 0000, days)
    TZ = str2double(regexp(A.Acqus.Stamp,'UT(.\d+)h','tokens','once'));
    if isempty(TZ); TZ = 2; end	% Assume UT+2h if not in stamp-field
    A.Info.AcqSerialDate = A.Acqus.DATE/(60*60*24)+datenum([1970 01 01])+TZ/24;
    A.Info.AcqDateTime = datestr(A.Info.AcqSerialDate);
    A.Info.AcqDate = datestr(A.Info.AcqSerialDate,'yyyy-mm-dd');
    % Convert serial date to text to keep format
    A.Info.AcqSerialDate = sprintf('%.12f',A.Info.AcqSerialDate);

    %% Add plotlabel from A.Acqus.Stamp-info
    q = regexp(A.Acqus.Stamp,'data[/\\].+[/\\]nmr[/\\](.+)[/\\](\d+)[/\\]acqus','tokens');
    if isempty(q)	% New, more relaxed, data path
        q = regexp(A.Acqus.Stamp,'#.+[/\\](.+)[/\\](\d+)[/\\]acqus','tokens');
    end
    if isempty(q)
        A.Info.PlotLabel = ['[',A.Info.FilePath,']'];
    else
        A.Info.PlotLabel = ['[',q{1}{1},':',q{1}{2},']'];
    end

    %% Open and read file
    if A.Procs.BYTORDP == 0
        endian = 'l';
    else
        endian = 'b';
    end

    if isfile(fullfile(iDirPath, '1r'))
        [FID, MESSAGE] = fopen(fullfile(iDirPath, '1r'),'r',endian);
        if FID == -1
            disp(MESSAGE);
            error('RBNMR: Error opening file ''%s''', fullfile(iDirPath, '1r'));
        end
        A.Data = fread(FID,'int32');
        fclose(FID);
    end

    %% Read imaginary data if the file 1i exists
    if isfile(fullfile(iDirPath, '1i'))
        [FID, MESSAGE] = fopen(fullfile(iDirPath, '1r'),'r',endian);
        if FID == -1
            % Do nothing
        else
            A.IData = fread(FID,'int32');
            fclose(FID);
        end
    end

    %% Correct data for NC_proc-parameter
    A.Data = A.Data/(2^-A.Procs.NC_proc);
    if (isfield(A,'IData'))
        A.IData = A.IData/(2^-A.Procs.NC_proc);
    end

    A.Procs.NC_proc = 0;

    %% Calculate x-axis
    A.XAxis = linspace( A.Procs.OFFSET,...
        A.Procs.OFFSET-A.Procs.SW_p./A.Procs.SF,...
        A.Procs.SI)';

    %% Additional axis and reordering if 2D-file
    if isfield(A,'Proc2s')
        A.YAxis = linspace( A.Proc2s.OFFSET,...
            A.Proc2s.OFFSET-A.Proc2s.SW_p./A.Proc2s.SF,...
            A.Proc2s.SI)';

        %% Reorder submatrixes (se XWinNMR-manual, chapter 17.5 (95.3))

        SI1 = A.Procs.SI; SI2 = A.Proc2s.SI;
        XDIM1 = A.Procs.XDIM; XDIM2 = A.Proc2s.XDIM;

        NoSM = SI1*SI2/(XDIM1*XDIM2);    % Total number of Submatrixes
        NoSM2 = SI2/XDIM2;		 			% No of SM along F1

        A.Data = reshape(...
            permute(...
            reshape(...
            permute(...
            reshape(A.Data,XDIM1,XDIM2,NoSM),...
            [2 1 3]),...
            XDIM2,SI1,NoSM2),...
            [2 1 3]),...
            SI1,SI2)';

        %% Read the level file if it exists
        % The old version (level) is a binary
        if(exist('level','file')==2)
            [FID, MESSAGE] = fopen('level','r',endian);
            if FID == -1
                disp('READBNMR: Error opening level file');
                disp(MESSAGE);
            end

            L=fread(FID,'int32');
            fclose(FID);

            % The first two figures is the number of pos. and neg. levels
            A.Levels = L(3:end);
            % Adjust for NC-parameter
            A.Levels = A.Levels/(2^-A.Procs.NC_proc);
        end

        %% Read the clevel file if it exists
        % The new version (clevel) is a text file
        if(exist('clevels','file')==2)
            L = readnmrpar('clevels');
            switch L.LEVSIGN
                case 0	% Positive only
                    A.Levels = L.LEVELS(L.LEVELS > 0)';
                case 1	% Negative only
                    A.Levels = L.LEVELS(L.LEVELS < 0)';
                case 2	% Both pos and neg.
                    A.Levels = L.LEVELS(1:L.MAXLEV*2);
            end
        end

        %% Check that A.Levels is not one (large) scalar. If so 'Contour' will crash.
        if (isfield(A,'Levels') && length(A.Levels) == 1)
            A.Levels = [A.Levels;A.Levels];
        end
    
    end

return

function P = readnmrpar(FileName)
    % RBNMRPAR      Reads BRUKER parameter files to a struct
    %
    % SYNTAX        P = readnmrpar(FileName);
    %
    % IN            FileName:	Name of parameterfile, e.g., acqus
    %
    % OUT           Structure array with parameter/value-pairs
    %

    % Read file
    A = textread(FileName,'%s','whitespace','\n');

    % Det. the kind of entry
    TypeOfRow = cell(length(A),2);

    R = {   ...
        '^##\$*(.+)=\ \(\d\.\.\d+\)(.+)', 'ParVecVal' ; ...
        '^##\$*(.+)=\ \(\d\.\.\d+\)$'   , 'ParVec'    ; ...
        '^##\$*(.+)=\ (.+)'             , 'ParVal'    ; ...
        '^([^\$#].*)'                   , 'Val'       ; ...
        '^\$\$(.*)'                     , 'Stamp'     ; ...
        '^##\$*(.+)='                   , 'EmptyPar'  ; ...
        '^(.+)'							, 'Anything'	...
        };

    for i = 1:length(A)
        for j=1:size(R,1)
            [s,t]=regexp(A{i},R{j,1},'start','tokens');
            if (~isempty(s))
                TypeOfRow{i,1}=R{j,2};
                TypeOfRow{i,2}=t{1};
                break;
            end
        end
    end

    % Set up the struct
    i=0;
    while i < length(TypeOfRow)
        i=i+1;
        switch TypeOfRow{i,1}
            case 'ParVal'
                LastParameterName = TypeOfRow{i,2}{1};
                P.(LastParameterName)=TypeOfRow{i,2}{2};
            case {'ParVec','EmptyPar'}
                LastParameterName = TypeOfRow{i,2}{1};
                P.(LastParameterName)=[];
            case 'ParVecVal'
                LastParameterName = TypeOfRow{i,2}{1};
                P.(LastParameterName)=TypeOfRow{i,2}{2};
            case 'Stamp'
                if ~isfield(P,'Stamp')
                    P.Stamp=TypeOfRow{i,2}{1};
                else
                    P.Stamp=[P.Stamp ' ## ' TypeOfRow{i,2}{1}];
                end
            case 'Val'
                if isempty(P.(LastParameterName))
                    P.(LastParameterName) = TypeOfRow{i,2}{1};
                else
                    P.(LastParameterName) = [P.(LastParameterName),' ',TypeOfRow{i,2}{1}];
                end
            case {'Empty','Anything'}
                % Do nothing
        end
    end


    % Convert strings to values
    Fields = fieldnames(P);

    for i=1:length(Fields)
        trystring = sprintf('P.%s = [%s];',Fields{i},P.(Fields{i}));
        try
            eval(trystring);
        catch %#ok<CTCH>
            % Let the string P.(Fields{i}) be unaltered
        end
    end
return



