# keysight-vna-automation
This MATLAB code written by Tristen and myself will automate the process of saving data using the Keysight VNA PXI model in the closet.

This repository contains two files.  One .mlapp file controls the user interface and passes what the user inputs to a .m script which tells the VNA how and when to take the measurements.  

[.sNp](https://helpfiles.keysight.com/csg/N1930xB/FilePrint/SnP_File_Format.htm) data file format (also known as Touchstone format) is used across different VNA manufacturers.  It contains all the s-parameters for the number of ports used on the VNA.  For example, if you had a \*.s2p file, it has 2 ports and therefore 4 s-parameters (ie. ports 1 and 2 would give S11, S12, S21, S22).  More details about SNP files below.

***
## What this project does
___________________________
- Gathers inputs from the user (number of measurements, chosen file name, number of antennas, which ports on the VNA are used, how long between each measurement)
- Based on user inputs, the code will tell the VNA to display the reflection coefficients and save the .snp file for all ports
- To tell the VNA what to do, the MATLAB script needs to send a string with the SCPI command to the VNA

## Files in this repository

| File   | Description                             |
| ------ | --------------------------------------- |
| .mlapp | Collects all the inputs                 |
| .m     | Receives inputs and sends it to the VNA |
## How to use

Open Keysight application (green one) and .mlapp.

<img width="465" height="704" alt="image" src="https://github.com/user-attachments/assets/8c0b28b7-2aa1-42a5-8e23-8b9d384f0a02" />

## SCPI Resources

SCPI (Standard Commands for Programmable Instruments) is a language

Capitalization is important in SCPI 

\* means that it is a common command (general command to VNA that doesn't require other inputs and shared across different types of instrumentation).  For more info, here is a [list of common commands](https://helpfiles.keysight.com/csg/n5106a/scpi_commands_common.htm).

? means that you are asking for a response.  For instance, let's take the command \*OPC which means operation complete.  If you send \*OPC then it sets the Standard Event Status Register (operation complete) to 0, however if you send \*OPC? then the VNA will send you back the status of the Standard Event Status Register either 0 for operation still running or 1 for operation complete.

Space is used as a delimiter.  For instance, if you want to display window 1, DISP:WIND1:STATE OFF is correct, but DISP:WIND1 :STATE OFF would not be correct because the VNA would attempt to only execute the command up to the first space.  

[Good resource for how to read SCPI documentation from Keysight](https://helpfiles.keysight.com/csg/n5106a/scpi_basics.htm)
#### Commands used in this repository

\*IDN? - asks what is the ID of the connected VNA
\*CLS - clear error queue

DISP:WIND1:STATE OFF - turns window 1 off

DISP:WIND1:STATE ON - turns window 1 on 

CALC:PAR:DEF:EXT "name of trace", S11 - calculates S11 and names it

DISP:WIND1:TRAC1:FEED "name of trace" - defines trace 1 as "name of trace" and displays it in window 1

MMEM:STOR:DATA:SNP \<filename>, \<ports>, \<format>, \<touchstoneversion>


[Documentation from Keysight - DISP](https://helpfiles.keysight.com/csg/e5055a/Programming/GP-IB_Command_Finder/Display.htm)

[Documentation from Keysight - CALC](https://helpfiles.keysight.com/csg/m9485a/programming/gp-ib_command_finder/calculate/parameter.htm)

[Documentation from Keysight for storage command](https://helpfiles.keysight.com/csg/pxivna/Programming/GP-IB_Command_Finder/Memory.htm#StoDataSnp) 

### How to establish connection with the VNA

<img width="1920" height="1040" alt="image" src="https://github.com/user-attachments/assets/80fd7a30-b7f9-4aa7-bef1-7ffc02762f5e" />

To establish connection to the VNA, open Connection Expert 2026.  When the status is green, it means that the VNA is connected.  To refresh, you can right click on M9801A.  

<img width="1920" height="533" alt="image" src="https://github.com/user-attachments/assets/9f22ee61-43af-4de8-bfa8-7ba41e92c7e9" />

Next, you can check this connection by opening up Interactive IO 2026.  By sending the SCPI command \*IDN? you can verify if the VNA is connected as shown above.  This is also a helpful tool for debugging as you can push SCPI commands directly to the VNA without using MATLAB.

For this project, we have defined the connection using LAN and more specifically a type of LAN called HiSLIP.  
#### How MATLAB connects to the VNA

To connect to the VNA, MATLAB uses the Instrument Control Toolbox function [visadev()](https://www.mathworks.com/help/instrument/visadev.html).  In the .m script we take the VNA ID (resourceStr = 'TCPIP0::172.17.229.244::hislip0::INSTR') and define it as a device in MATLAB.  This allows us to establish a VISA connection to the VNA and write commands to the VNA directly.  
### SNP files

.sNp files were first conceived as a way to save s-parameters in a text file and it remains industry standard in microwave engineering.  

It is very important to verify the .sNp files are not empty.  Regardless if the .sNp file is saved manually or through this script, **if the port is not calibrated, the .sNp file will be empty.** 

There are four formats available for SNP files:
- "AUTO" - Auto
- "RI" - Real / Imaginary
- "MA" - Magnitude / Angle
- "DB" - LogMag / Degrees - this is the one used in the .m script

A general layout of an .s2p file for a 2-port setup using ports 1 and 2 in the DB format:

| Freq | S11 log magnitude | S11 angle in degrees | S12 log magnitude | S12 angle in degrees | S21 log magnitude | S21 angle in degrees | S22 log magnitude | S22 angle in degrees |
| ---- | ----------------- | -------------------- | ----------------- | -------------------- | ----------------- | -------------------- | ----------------- | -------------------- |

<img width="806" height="34" alt="image" src="https://github.com/user-attachments/assets/fff49745-d0bc-43bf-a6f9-47107e7e3e60" />

### Debugging

Are the traces already defined?

When you run DISP:WIND1:TRAC1:FEED "name of trace", the next time the command executes you have to run DISP:WIND1:**TRAC2**:FEED since trace 1 has already been defined.

Are the .sNp files empty?

Check the header of the .sNp file:

<img width="651" height="201" alt="image" src="https://github.com/user-attachments/assets/67a0b1ad-8bc2-433b-ab57-20245770812e" />

Here ports 1, 2, 3, 4, 5, 6, 7, and 11 are have correction off.  

<img width="676" height="181" alt="image" src="https://github.com/user-attachments/assets/7f91b36c-b185-4b20-8099-41e991f604be" />

The s-parameters shown here are -200 dB and 45 $\degree C$ which is the VNA's typical way of writing "zero" because it is the default number in the dB format.
