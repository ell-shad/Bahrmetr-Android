B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=11.2
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub axtar (kods As List) As String
	Dim element As String=""
	Dim count As Int=0
	For i=0 To kods.Size-1
	
		Dim tmp As String=kods.Get(i)
		Dim  tmpCount As Int=0
		For j=0 To kods.Size-1
			If kods.Get(j)=tmp Then
				tmpCount=tmpCount+1
			End If
			If tmpCount>count Then
				element=tmp
				count=tmpCount
			End If
		
		Next
	Next
	Return element
End Sub

Sub bhrName (b As String, az As Char) As String
	
	Dim c As String
	
	Select b
		Case "ramal"
			If az="a" Then
				c = "Rəməl"
			Else If az="t" Then
				c = "Remel"
			Else
				c = "Ramal"
			End If
			Exit
			
		Case "hazac"
			If az="a" Then
				c = "Həzəc"
			Else If az="t" Then
				c = "Hezec"
			Else
				c = "Hazaj"
			End If
			Exit

		Case "muzare"
			If az="a" Then
				c = "Müzare"
			Else If az="t" Then
				c = "Müzare"
			Else
				c = "Mudari"
			End If
			Exit
			
		Case "munsarih"
			If az="a" Then
				c = "Münsərih"
			Else If az="t" Then
				c = "Münserih"
			Else
				c = "Munsarih"
			End If
			Exit
          
		Case "mutedarik"
			If az="a" Then
				c = "Mütədarik"
			Else If az="t" Then
				c = "Mütedarik"
			Else
				c = "Mutadarik"
			End If
			Exit
           
		Case "muqtazab"
			If az="a" Then
				c = "Müqtəzəb"
			Else If az="t" Then
				c = "Müktezeb"
			Else
				c = "Muqtadab"
			End If
			Exit
            
		Case "kamil"
			c = "Kamil"
			Exit
           
		Case "khafif"
			If az="a" Then
				c = "Xəfif"
			Else If az="t" Then
				c = "Hafif"
			Else
				c = "Khafif"
			End If
			Exit
           

		Case "muctas"
			If az="a" Then
				c = "Müctəs"
			Else If az="t" Then
				c = "Müctes"
			Else
				c = "Mujtathth"
			End If
			Exit
          
		Case "mutaqarib"
			If az="a" Then
				c = "Mütəqarib"
			Else If az="t" Then
				c = "Mütekarib"
			Else
				c = "Mutaqarib"
			End If
			Exit
            
		Case "racaz"
			If az="a" Then
				c = "Rəcəz"
			Else If az="t" Then
				c = "Recez"
			Else
				c = "Rajaz"
			End If
			Exit
           
		Case "sari"
			If az="a" Then
				c = "Səri"
			Else If az="t" Then
				c = "Seri"
			Else
				c = "Sari"
			End If
			Exit
			
		Case Else
			c="xeta"
			Exit
				
	End Select
	
	Return c
End Sub
Sub toChar(str As String) As Char()
	Dim xar(str.Length) As Char
	For i=0 To str.Length-1
		xar(i)=str.CharAt(i)
	Next
	Return xar
End Sub
Sub isSait(a As Char) As Boolean
	If a="a" Or a="e" Or a="o" Or a="i" Or a="u" Or a="ə" Or a="ı" Or a="ü" Or a="ö" Then
		Return True
	Else
		Return False
	End If
End Sub
Sub formatMisra(misra As String) As String
	misra = misra.replace(" ", "")
	misra = misra.replace(",", "")
	misra = misra.replace("-", "")
	misra = misra.replace(".", "")
	misra = misra.replace("?", "")
	misra = misra.replace("!", "")
	misra = misra.replace("’", "")
	misra = misra.replace("'", "")
	misra = misra.replace("`", "")
	misra = misra.replace($"""$, "")
	misra = misra.replace(":", "")
	misra = misra.replace(";", "")
	misra=misra.ToLowerCase
	Return misra
End Sub
