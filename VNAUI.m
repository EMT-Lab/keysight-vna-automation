function VNAUI(startFreq, stopFreq, definePoints, numMeasurements, fileName, numAntennas, ports, waitTime)

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
    writeline(vna, '*RST');
    writeline(vna, '*CLS');
   
   
    % Sample of how the VNA receives calc and disp commands
    % writeline(vna, 'CALC:PAR:DEF:EXT "CH1_S11_11_11", S11_11');
    % writeline(vna, 'DISP:WIND1:TRAC8:FEED "CH1_S11_11_11"');
    
    
    
    scpiStartFreq = append('SENS:FREQ:START ',string(startFreq));
    scpiStopFreq = append('SENS:FREQ:STOP ', string(stopFreq));
    scpiNumPoints = append('SENS:SWE:POIN ', string(definePoints));
    
    
    writeline(vna, scpiStartFreq);          % Start frequency
    writeline(vna, scpiStopFreq);           % Stop frequency
    writeline(vna, scpiNumPoints);          % Number of points
    
    
    
    ports = string(ports);
    modPort = 'S' + ports' + '_' + ports;
    channelNum = reshape(1:numAntennas^2,numAntennas,numAntennas);
    channelName = 'CH1_' + modPort + '_' + string(channelNum); 
    
    reflectionPort = modPort(1:numAntennas+1:end)';
    mask = true(size(modPort));
    mask(1:numAntennas+1:end) = false;
    transmissionPort = modPort(mask);
    reflectionName = channelName(1:numAntennas+1:end)';
    transmissionName = channelName(mask);
    
    reflectionTrace = 1:numAntennas;
    transmissionTrace = numAntennas+1:numAntennas^2;
    
    
    writeline(vna,'DISP:WIND1:STATE OFF');
    writeline(vna,'DISP:WIND1:STATE ON');
    
    calcline = append('CALC:PAR:DEF:EXT "', reflectionName, '", ', reflectionPort);
    displayLine = append('DISP:WIND1:TRAC', string(reflectionTrace'), ':FEED "', reflectionName, '"');
    for i = 1:numAntennas
        writeline(vna, calcline(i));
        writeline(vna, displayLine(i));
    end
     
    %removed transmission coefficient s-parameters and pause 30 seconds  
    
    %initialize form of saving
    %writeline(vna, 'MMEM:STOR:TRAC:FORM:SNP DB');

    % Take the measurements
    for x= 1:numMeasurements
    
        writeline(vna, '*OPC?');
        readline(vna);
        pause(1)
    
        % Save data
        sNpFileName = append('C:\Users\Administrator\Documents\SCPI_Test_May_21_2026\', ...
            string(fileName),'_', string(startFreq/1e9), '_', string(stopFreq/1e9), '_Ghz_', ...
            string(datetime('now','Format','MM-dd_HH-mm-ss')), '.s', string(numAntennas), 'p');
        writeline(vna, ['MMEM:STOR:DATA:SNP ', sNpFileName, ports, 'DB', '1.1']);
    
        % Pause for time to adjust setup
        pause(waitTime)
    end 
end

