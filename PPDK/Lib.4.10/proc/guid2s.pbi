; Преобразование GUID в строку

Procedure.s guid2s(*id)
	Protected guid.s = Space(40)
	StringFromGUID2_(*id,@guid,40)
	ProcedureReturn Trim(guid)
EndProcedure
