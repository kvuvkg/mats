erase Mater.exe
Set Lib=c:\clip\lib
Set Include=c:\clip\include
c:\clip\bin\clipper Mater
if not errorlevel 1 c:\clip\bin\rtlink file Mater,c:\clip\lib\ftools1 LIB ftoolsx,ftools1,fproplus,DbFSix
erase Mater.obj

