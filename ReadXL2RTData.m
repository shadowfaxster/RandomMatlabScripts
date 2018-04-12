function RTMatrix = ReadXL2RTData(fno_start, f1, f2, no_of_positions, verbose)
% A script that reads RT60 measured data from an NTI XL2 Audio measurement 
% device and returns a 3D matrix with all RT60 data. Each row represents a 
% frequency bin, with the collumn structure as [Freq(Hz), RTtime]. The 3rd
% dimension creates a 2D array in the form described for each position. 
% 
% For invalid values (-.--), the RT time returned it 999. 
%
% The paramaters must give it the broken down filename and the starting
% numnber for the report filenames. This is easier shown than explained:
% 
% My report files are in the folder RT60GUILD and the first file is named
% '2018-02-14_RT60_000_Report.txt'. 18 positions have been measured.
% 
% ------- EXAMPLE PARAMETERS SETUP -------
%    f1 = 'RT60GUILD/2018-02-14_RT60_'; % NO REPORT NUMBERS
%    f2 = '_Report.txt';
%    fno_start = 0; 
%    no_of_positions = 18;
%    verbose = 0; % set to 1 for successful file open acknowledgement;
%
%    myMatrix = ReadXL2RTData(fno_start, f1, f2, no_of_positions, verbose);
% ----------------------------------------
% 
% TODO: catch if 2 consecutive files have been deleted. At the moment works
% for 1 deleted file in between 2 existing ones. 
% TODO2: find a nicer data structure so the frequency bins are only stored
% once and not once per position.


    if nargin < 4
        display('Error: not enough input arguments\n');
    elseif nargin == 4
        verbose = 0;
    elseif nargin > 5
        display('Error: too many input arguments\n');
    end

    dataPoints = zeros(24,2,...
        no_of_positions); % MxNxP matrix with M - frequency bins, N - columns (Freq...RT_value)
                          % and P - number of positions
                          
    filenumber = fno_start;  % use 'filenumber' because 'pos' will be 
                             % consecutive for array attribution BUT
                             % text file names may not be consecutive 
                             % numbers

    for pos=1:no_of_position    % Changes every time a new file is loaded (a.i. new position)
        if filenumber<10
            fmid = strcat('00',num2str(filenumber));
        elseif filenumber<100
            fmid = strcat('0', num2str(filenumber));
        else
            fmid = num2str(filenumber);
        end

        filename = strcat(f1, fmid, f2);

        if exist(filename, 'file')       
            % file exists, so try to open it
            try
                fileID = fopen(filename);
            catch ME
                display('Unable to access file %s\n', filename);
                throw(ME)
            end

        else
            % file doesn't exist so 
            % maybe you've deleted that particular file but the next one is still good
            fprintf('WARNING: File %s is missing, data integrity may be compromised!\n', filename);

            % try opening the next file along
            filenumber = filenumber+1;
            
            if filenumber<10
                fmid = strcat('00',num2str(filenumber));
            elseif filenumber<100
                fmid = strcat('0', num2str(filenumber));
            else
                fmid = num2str(filenumber);
            end 
            filename = strcat(f1, fmid, f2);

            try
                fileID = fopen(filename);
            catch ME
                display('Unable to access file %s\n', filename);
                throw(ME)
            end
        end
        
        if (verbose)
            fprintf('Successfully opened file %s\n', filename);
        end
        
        filenumber = filenumber + 1;    % increment for next filename

        % Read first 24 lines which are not of interest
        for i = 1:24
            l1 = fgetl(fileID);
        end

        % Start reading the lines which interest
        for i=1:24 %changes when new line is read
            l1 = fgetl(fileID);                 %get line
            l1 = strsplit(strtrim(l1), '\t');    %split by whitespace and remove leading whitespace
            for j = 1:2
                l1{j} = strtrim(l1{j});         %remove all other whitespace in respective string cell
                if (l1{j}(1)~='-')
                    dataPoints(i,j,pos)=str2num(l1{j});
                else
                    dataPoints(i,j,pos)=999;
                end
            end
        end
    end
    
    RTMatrix = dataPoints;
end

