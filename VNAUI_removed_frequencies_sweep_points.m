function VNAUI_June8_2(numMeasurements, fileName, numAntennas, ports, waitTime)

    % Configuration & Connection
    resourceStr = 'TCPIP0::172.17.229.244::hislip0::INSTR'; 
    
    % Create and open a VISA object
    try
        vna = visadev(resourceStr);
        disp('Successfully connected to VNA.');
    catch ME
        disp('Failed to connect. Check your connection and VISA address.');
        rethrow(ME);
    end
   
    % Instrument Identification
    instrumentID = writeread(vna, '*IDN?');
    fprintf('Connected to: %s\n', strtrim(instrumentID));
    
    % Instrument Configuration
    writeline(vna, '*CLS');                 % clear status
    
    % Define s-parameters and corresponding trace names
    ports = string(ports);
    modPort = 'S' + ports' + '_' + ports;
    traceNum = reshape(1:numAntennas^2,numAntennas,numAntennas);
    traceName = 'CH1_' + modPort + '_' + string(traceNum); 
    
    % Define reflection s-parameters
    reflectionPort = modPort(1:numAntennas+1:end)';
    reflectionName = traceName(1:numAntennas+1:end)';
    reflectionTrace = 1:numAntennas;
     
    % Initialize window
    writeline(vna,'DISP:WIND1:STATE OFF');
    writeline(vna,'DISP:WIND1:STATE ON');
    
    % Initialize reflection coefficient traces
    calcline = append('CALC:PAR:DEF:EXT "', reflectionName, '", ', reflectionPort);
    displayLine = append('DISP:WIND1:TRAC', string(reflectionTrace'), ':FEED "', reflectionName, '"');
    
    % Display reflection coefficients
    for i = 1:numAntennas
        writeline(vna, calcline(i));
        writeline(vna, displayLine(i));
    end
     
    % Take the measurements
    for x= 1:numMeasurements
    
        % Make sure VNA is not executing another command
        writeline(vna, '*OPC?');
        readline(vna);
        pause(1)
    
        % Save data to .sNp file
        paramFileName = append('"C:\Users\Administrator\Documents\SCPI_Test_May_21_2026\', ...
            string(fileName),'_', ...
            string(datetime('now','Format','MM-dd_HH-mm-ss')), '.s', string(numAntennas), 'p",');

        % example: MMEM:STOR:DATA:SNP "filename", "1,2,3", "DB", 1.1
        paramPort = append(' "',join(ports, ","),'",');
        paramFormat = append(' "DB",');
        paramTouchstoneVersion = append(' 1.1');

        scpiSave = append('MMEM:STOR:DATA:SNP ',paramFileName, paramPort, paramFormat, paramTouchstoneVersion);
        writeline(vna, scpiSave);
    
        % Wait until next measurement
        pause(waitTime-1)
    end 
    disp("Measurements completed")
end

