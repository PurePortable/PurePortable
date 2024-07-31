; https://docs.microsoft.com/en-us/windows/win32/api/imagehlp/nf-imagehlp-checksummappedfile

Procedure CorrectCheckSum(hFile)
	Protected *NTHeaders.IMAGE_NT_HEADERS, *BaseAddress
	Protected HeaderSum, CheckSum, FileSize, LargeFileSize.q
	Protected hFileMapping = CreateFileMapping_(hFile,#Null,#PAGE_READWRITE,0,0,#Null)
	GetFileSizeEx_(hFile,@LargeFileSize)
	FileSize = LargeFileSize
	If hFileMapping And FileSize
		*BaseAddress = MapViewOfFile_(hFileMapping,#FILE_MAP_ALL_ACCESS,0,0,0)
		*NTHeaders = CheckSumMappedFile_(*BaseAddress,FileSize,@HeaderSum,@CheckSum)
		;dbg("Checksum: "+Hex(*NTHeaders\OptionalHeader\CheckSum)+"/"+Hex(CheckSum))
		*NTHeaders\OptionalHeader\CheckSum = CheckSum
		UnmapViewOfFile_(hFileMapping)
	EndIf
EndProcedure
