; Конфликты имён:
; CreateToolbar -> CreateToolb__

DeclareProxyDll(comctl32)

DeclareProxyFunc(comctl32,_TrackMouseEvent) ; ??? нет в lib
DeclareProxyFunc(comctl32,AddMRUStringW)
DeclareProxyFunc(comctl32,CreateMappedBitmap)
DeclareProxyFunc(comctl32,CreateMRUListW)
DeclareProxyFunc(comctl32,CreatePropertySheetPage)
DeclareProxyFunc(comctl32,CreatePropertySheetPageA)
DeclareProxyFunc(comctl32,CreatePropertySheetPageW)
DeclareProxyFunc(comctl32,CreateStatusWindow)
DeclareProxyFunc(comctl32,CreateStatusWindowA)
DeclareProxyFunc(comctl32,CreateStatusWindowW)
DeclareProxyFunc(comctl32,CreateToolb__) ; conflict name
DeclareProxyFunc(comctl32,CreateToolbarEx)
DeclareProxyFunc(comctl32,CreateUpDownControl)
DeclareProxyFunc(comctl32,DefSubclassProc)
DeclareProxyFunc(comctl32,DestroyPropertySheetPage)
DeclareProxyFunc(comctl32,DllGetVersion) ; ??? нет в lib
DeclareProxyFunc(comctl32,DPA_Clone)
DeclareProxyFunc(comctl32,DPA_Create)
DeclareProxyFunc(comctl32,DPA_CreateEx)
DeclareProxyFunc(comctl32,DPA_DeleteAllPtrs)
DeclareProxyFunc(comctl32,DPA_DeletePtr)
DeclareProxyFunc(comctl32,DPA_Destroy)
DeclareProxyFunc(comctl32,DPA_DestroyCallback)
DeclareProxyFunc(comctl32,DPA_EnumCallback)
DeclareProxyFunc(comctl32,DPA_GetPtr)
DeclareProxyFunc(comctl32,DPA_GetPtrIndex)
DeclareProxyFunc(comctl32,DPA_GetSize) ; ??? есть в lib
DeclareProxyFunc(comctl32,DPA_Grow)
DeclareProxyFunc(comctl32,DPA_InsertPtr)
DeclareProxyFunc(comctl32,DPA_LoadStream)
DeclareProxyFunc(comctl32,DPA_Merge)
DeclareProxyFunc(comctl32,DPA_SaveStream)
DeclareProxyFunc(comctl32,DPA_Search)
DeclareProxyFunc(comctl32,DPA_SetPtr)
DeclareProxyFunc(comctl32,DPA_Sort)
DeclareProxyFunc(comctl32,DrawInsert)
DeclareProxyFunc(comctl32,DrawShadowText) ; ??? есть в lib
DeclareProxyFunc(comctl32,DrawStatusText)
DeclareProxyFunc(comctl32,DrawStatusTextA)
DeclareProxyFunc(comctl32,DrawStatusTextW)
DeclareProxyFunc(comctl32,DSA_Clone) ; ??? есть в lib
DeclareProxyFunc(comctl32,DSA_Create)
DeclareProxyFunc(comctl32,DSA_DeleteAllItems)
DeclareProxyFunc(comctl32,DSA_DeleteItem)
DeclareProxyFunc(comctl32,DSA_Destroy)
DeclareProxyFunc(comctl32,DSA_DestroyCallback)
DeclareProxyFunc(comctl32,DSA_EnumCallback)
DeclareProxyFunc(comctl32,DSA_GetItem)
DeclareProxyFunc(comctl32,DSA_GetItemPtr)
DeclareProxyFunc(comctl32,DSA_GetSize) ; ??? есть в lib
DeclareProxyFunc(comctl32,DSA_InsertItem)
DeclareProxyFunc(comctl32,DSA_SetItem)
DeclareProxyFunc(comctl32,DSA_Sort) ; ??? есть в lib
DeclareProxyFunc(comctl32,EnumMRUListW)
DeclareProxyFunc(comctl32,FlatSB_EnableScrollBar)
DeclareProxyFunc(comctl32,FlatSB_GetScrollInfo)
DeclareProxyFunc(comctl32,FlatSB_GetScrollPos)
DeclareProxyFunc(comctl32,FlatSB_GetScrollProp)
DeclareProxyFunc(comctl32,FlatSB_GetScrollRange)
DeclareProxyFunc(comctl32,FlatSB_SetScrollInfo)
DeclareProxyFunc(comctl32,FlatSB_SetScrollPos)
DeclareProxyFunc(comctl32,FlatSB_SetScrollProp)
DeclareProxyFunc(comctl32,FlatSB_SetScrollRange)
DeclareProxyFunc(comctl32,FlatSB_ShowScrollBar)
DeclareProxyFunc(comctl32,FreeMRUList)
DeclareProxyFunc(comctl32,GetEffectiveClientRect)
DeclareProxyFunc(comctl32,GetMUILanguage)
DeclareProxyFunc(comctl32,GetWindowSubclass) ; ??? есть в lib
DeclareProxyFunc(comctl32,HIMAGELIST_QueryInterface) ; ??? есть в lib
DeclareProxyFunc(comctl32,ImageList_Add)
DeclareProxyFunc(comctl32,ImageList_AddIcon)
DeclareProxyFunc(comctl32,ImageList_AddMasked)
DeclareProxyFunc(comctl32,ImageList_BeginDrag)
DeclareProxyFunc(comctl32,ImageList_CoCreateInstance) ; ??? есть в lib
DeclareProxyFunc(comctl32,ImageList_Copy)
DeclareProxyFunc(comctl32,ImageList_Create)
DeclareProxyFunc(comctl32,ImageList_Destroy)
DeclareProxyFunc(comctl32,ImageList_DragEnter)
DeclareProxyFunc(comctl32,ImageList_DragLeave)
DeclareProxyFunc(comctl32,ImageList_DragMove)
DeclareProxyFunc(comctl32,ImageList_DragShowNolock)
DeclareProxyFunc(comctl32,ImageList_Draw)
DeclareProxyFunc(comctl32,ImageList_DrawEx)
DeclareProxyFunc(comctl32,ImageList_DrawIndirect)
DeclareProxyFunc(comctl32,ImageList_Duplicate)
DeclareProxyFunc(comctl32,ImageList_EndDrag)
DeclareProxyFunc(comctl32,ImageList_GetBkColor)
DeclareProxyFunc(comctl32,ImageList_GetDragImage)
DeclareProxyFunc(comctl32,ImageList_GetFlags) ; ??? нет в lib
DeclareProxyFunc(comctl32,ImageList_GetIcon)
DeclareProxyFunc(comctl32,ImageList_GetIconSize)
DeclareProxyFunc(comctl32,ImageList_GetImageCount)
DeclareProxyFunc(comctl32,ImageList_GetImageInfo)
DeclareProxyFunc(comctl32,ImageList_GetImageRect)
DeclareProxyFunc(comctl32,ImageList_LoadImage)
DeclareProxyFunc(comctl32,ImageList_LoadImageA)
DeclareProxyFunc(comctl32,ImageList_LoadImageW)
DeclareProxyFunc(comctl32,ImageList_Merge)
DeclareProxyFunc(comctl32,ImageList_Read)
DeclareProxyFunc(comctl32,ImageList_ReadEx) ; ??? есть в lib
DeclareProxyFunc(comctl32,ImageList_Remove)
DeclareProxyFunc(comctl32,ImageList_Replace)
DeclareProxyFunc(comctl32,ImageList_ReplaceIcon)
DeclareProxyFunc(comctl32,ImageList_SetBkColor)
DeclareProxyFunc(comctl32,ImageList_SetDragCursorImage)
DeclareProxyFunc(comctl32,ImageList_SetFilter)
DeclareProxyFunc(comctl32,ImageList_SetFlags) ; ??? нет в lib
DeclareProxyFunc(comctl32,ImageList_SetIconSize)
DeclareProxyFunc(comctl32,ImageList_SetImageCount)
DeclareProxyFunc(comctl32,ImageList_SetOverlayImage)
DeclareProxyFunc(comctl32,ImageList_Write)
DeclareProxyFunc(comctl32,ImageList_WriteEx) ; ??? есть в lib
DeclareProxyFunc(comctl32,InitCommonControls)
DeclareProxyFunc(comctl32,InitCommonControlsEx)
DeclareProxyFunc(comctl32,InitializeFlatSB)
DeclareProxyFunc(comctl32,InitMUILanguage)
DeclareProxyFunc(comctl32,LBItemFromPt)
DeclareProxyFunc(comctl32,LoadIconMetric) ; ??? есть в lib
DeclareProxyFunc(comctl32,LoadIconWithScaleDown) ; ??? есть в lib
DeclareProxyFunc(comctl32,MakeDragList)
DeclareProxyFunc(comctl32,MenuHelp)
DeclareProxyFunc(comctl32,PropertySheet)
DeclareProxyFunc(comctl32,PropertySheetA)
DeclareProxyFunc(comctl32,PropertySheetW)
DeclareProxyFunc(comctl32,RegisterClassNameW) ; ??? нет в lib
DeclareProxyFunc(comctl32,RemoveWindowSubclass)
DeclareProxyFunc(comctl32,SetWindowSubclass)
DeclareProxyFunc(comctl32,ShowHideMenuCtl)
DeclareProxyFunc(comctl32,Str_SetPtrW)
DeclareProxyFunc(comctl32,TaskDialog) ; ??? есть в lib
DeclareProxyFunc(comctl32,TaskDialogIndirect) ; ??? есть в lib
DeclareProxyFunc(comctl32,UninitializeFlatSB)

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 15
; FirstLine = 12
; Markers = 16
; EnableThread
; DisableDebugger
; EnableExeConstant