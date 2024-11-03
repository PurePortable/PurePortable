; Удаление сертификатов
; https://docs.microsoft.com/en-us/windows/win32/api/imagehlp/nf-imagehlp-imageremovecertificate

; need #FILE_READ_DATA|#FILE_WRITE_DATA ???

#CERT_SECTION_TYPE_ANY = $FF
Procedure.i RemoveCertificates(hFile)
	Protected CertificateCount, iCert, cCert
	If ImageEnumerateCertificates_(hFile,#CERT_SECTION_TYPE_ANY,@CertificateCount,#Null,0)
		;dbg("CertificateCount: "+Str(CertificateCount))
		For iCert=0 To CertificateCount-1
			;dbg("Cert: "+Str(iCert))
			If ImageRemoveCertificate_(hFile,iCert)
				cCert+1
			EndIf
		Next
	EndIf
	ProcedureReturn cCert
EndProcedure
