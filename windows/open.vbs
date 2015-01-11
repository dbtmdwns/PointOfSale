
sPrinter = "EPSON TM-T88V Receipt"
sPort = "ESDPRT001"



set oPrt = GetPrtPort(sPrinter, sPort)
'oPrt.write Chr(27)&Chr(112)&Chr(48)&Chr(55)&Chr(121)
oPrt.write Chr(27)&Chr(109)
oPrt.close
RemovePort nPort

Function GetPrtPort(sPrinter ,sPort)

  with CreateObject("WScript.Network")
    on error resume next
      .RemovePrinterConnection sPort
      .AddPrinterConnection sPort, sPrinter 
    on error goto 0
    set GetPrtPort = createobject("scripting.filesystemobject").opentextfile(sPort, 2)
  end with

end function

sub RemovePort(sPort)
  on error resume next
    CreateObject("WScript.Network").RemovePrinterConnection sPort
  on error goto 0

end sub
