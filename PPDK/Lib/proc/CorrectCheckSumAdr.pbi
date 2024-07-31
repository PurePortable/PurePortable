; https://docs.microsoft.com/en-us/windows/win32/api/imagehlp/nf-imagehlp-checksummappedfile

Procedure CorrectCheckSumAdr(*BaseAddress,FileSize)
	Protected *NTHeaders.IMAGE_NT_HEADERS
	Protected HeaderSum, CheckSum
	*NTHeaders = CheckSumMappedFile_(*BaseAddress,FileSize,@HeaderSum,@CheckSum)
	;dbg("Checksum: "+Hex(*NTHeaders\OptionalHeader\CheckSum)+"/"+Hex(CheckSum))
	*NTHeaders\OptionalHeader\CheckSum = CheckSum
EndProcedure
