B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals
	Private Root As B4XView
	Public xui As XUI
	
	Private frstMsra As B4XFloatTextField
	Private scndMsra As B4XFloatTextField
	Private thrdMsra As B4XFloatTextField
	Private behrName As Label
	Private qelibName As Label
	Private unspaced As String
	Private selected, selected2,selected23, qelibler As List
	Private lengthIdentifieer As Int=1
	Private similiar, differ, counter, qelibSimilarity As Int=0
	Private qalib, tefile, sesQ As String
	Private kodlular(3) As String
	Private hecalar(3) As Int
	Private misraQelib(3)As String
	Private  qelibTapildi,chort As Boolean=False
	Private tapilmadi As Boolean =True
	Private chortl As Label
	Private okBtn As SwiftButton
	Private clrBtn As Button
	Dim abt As aboyt
	Public dialog, dild As B4XDialog
	Public dil As String = "Azərbaycanca"
	Private dil1 As B4AMenuItem
	Dim options As B4XListTemplate
	
	
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	
	Root = Root1
	Root.LoadLayout("MainPage")
	B4XPages.SetTitle(Me, "Bahrmetr")
	B4XPages.AddMenuItem(Me,"Haqqında(About)")
	B4XPages.AddMenuItem(Me,"Dil(Language)")

	dild.Initialize(Root)
	abt.Initialize
	dialog.Initialize(Root)
	options.Initialize
	options.CustomListView1.DefaultTextBackgroundColor= Colors.White
	options.CustomListView1.DefaultTextColor= Colors.Black
 
	options.Options = Array("Azərbaycanca", "Türkçe", "English")
	B4XPages.AddPage("Haqqında",abt)
	
End Sub


'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.
Public Sub b4xpage_MenuClick (Tag As String)
	If Tag="Haqqında(About)" Then
		B4XPages.ShowPage("Haqqında")
	else if  Tag="Dil(Language)" Then
		dild.BorderWidth=0
		dild.BorderCornersRadius=5dip
		dild.BodyTextColor=Colors.Black
		dild.ButtonsColor=Colors.RGB(0,89,117)
		dild.BorderWidth=0
		dild.ButtonsTextColor=Colors.White
		dild.TitleBarColor=Colors.RGB(0,89,117)
		dild.BackgroundColor=Colors.White
		dild.Title="Dil(Language)"
		If dil="Azərbaycanca" Then
			Wait For (dild.ShowTemplate(options, "", "", "Bağla")) Complete (Result As Int)
		Else if dil="Türkçe" Then
			Wait For (dild.ShowTemplate(options, "", "", "Kapat")) Complete (Result As Int)
		Else
			Wait For (dild.ShowTemplate(options, "", "", "Close")) Complete (Result As Int)
		End If
		If Result = xui.DialogResponse_Positive Then
			dil=options.SelectedItem
			abt.update
			tercume(dil)
		End If
	End If
End Sub

Private Sub tercume (lng As String)
	If lng="Azərbaycanca" Then
		qelibName.Text="Qəlib:"
		behrName.Text="Bəhr:"
		frstMsra.HintText="Birinci Misra"
		frstMsra.Update
		scndMsra.HintText="İkinci Misra"
		scndMsra.Update
		thrdMsra.HintText="Üçüncü Misra"
		thrdMsra.Update
		okBtn.xLBL.Text="Bəhri Tap"
		chortl.Text=""
	Else if lng= "Türkçe" Then
		qelibName.Text="Kalıb:"
		behrName.Text="Vezn Türü:"
		frstMsra.HintText="Mısra 1"
		frstMsra.Update
		scndMsra.HintText="Mısra 2"
		scndMsra.Update
		thrdMsra.HintText="Mısra 3"
		thrdMsra.Update
		okBtn.xLBL.Text="Vezni Bul"
		chortl.Text=""
	Else
		qelibName.Text="Meter:"
		behrName.Text="Meter name:"
		frstMsra.HintText="1st Verse"
		frstMsra.Update
		scndMsra.HintText="2nd Verse"
		scndMsra.Update
		thrdMsra.HintText="3rd Verse"
		thrdMsra.Update
		okBtn.xLBL.Text="Find"
		chortl.Text=""
	End If
End Sub
Private Sub kodla(kodlar() As String) As String

	For i=0 To 2
		Dim cnt As Int=0
		unspaced=kodlar(i)
		kodlular(i)=""
		hecalar(i)=0
		unspaced = Utils.formatMisra(unspaced)
		
		For j=0 To unspaced.Length-1
			cnt=cnt+1
			If unspaced.CharAt(j)="a" Or unspaced.CharAt(j)="e" Or unspaced.CharAt(j)="i" Or unspaced.CharAt(j)="o" Or unspaced.CharAt(j)="ə" Or unspaced.CharAt(j)="ö" Or unspaced.CharAt(j)="ü" Or unspaced.CharAt(j)="ı" Or unspaced.CharAt(j)="u" Then
				If cnt=unspaced.Length Then
					kodlular(i)=kodlular(i)&10
				Else
					kodlular(i)=kodlular(i)&1
				End If
				hecalar(i)=hecalar(i)+1
			Else
				kodlular(i)=kodlular(i)&0
			End If
		Next
		If tapilmadi=True Then
			If hecalar(i)>=5 Then
				tapilmadi=False
			Else
				tapilmadi=True
			End If
		End If
		Log("kodlular "&i&" "& kodlular(i))
	Next
	
	If tapilmadi=False Then

		'generating digital qelibs
		For i=0 To 2
			misraQelib(i)=""
			unspaced=kodlar(i)
			unspaced=Utils.formatMisra(unspaced)

			Dim chra() As Char = Utils.toChar(unspaced)
		
			For j=0 To chra.Length-1
				If j+2<chra.Length-1 Then
			
					If Utils.isSait(chra(j)) And Utils.isSait(chra(j+1))=False And Utils.isSait(chra(j+2))=False Then
						misraQelib(i)=misraQelib(i)&0
					Else If (Utils.isSait(chra(j)) And Utils.isSait(chra(j+1))=False And Utils.isSait(chra(j+2))) Or (Utils.isSait(chra(j)) And Utils.isSait(chra(j+1)))  Then
						misraQelib(i)=misraQelib(i)&1
					End If
			
				Else
					If Utils.isSait(chra(j)) Then
						misraQelib(i)=misraQelib(i)&0
					End If
				End If
		
		
			Next
			Log("misraqelib  "& misraQelib(i))
	
		Next
		Return qelibTap(misraQelib, hecalar)
	
	Else
		
		If dil="Azərbaycanca" Then
			behrName.Text="Tapılmadı."
			qelibName.Text="Tapılmadı."
			Return "Tapılmadı."
		Else if dil="Türkçe" Then
			behrName.Text="Bulunamadı."
			qelibName.Text="Bulunamadı."
			Return "Bulunamadı."
		Else
			behrName.Text="Nothing found."
			qelibName.Text="Nothing found."
			Return "Nothing found."
		End If
		
	End If
	
	
	
End Sub

private Sub qelibTap(misrqelib () As String, hga() As Int) As String

	qelibler.Initialize
	selected23.Initialize
	
	For i=0 To 2
		Try
			ConnectDB.resul=ConnectDB.varSQL.ExecQuery("SELECT * FROM qelibs WHERE hga =" & hga(i))
			Do While ConnectDB.resul.NextRow
				qelibler.Add(ConnectDB.resul.GetString("digqel"))
			Loop
			ConnectDB.resul.Close
		Catch
			Log(LastException)
		End Try
	Next
	
	For Each a As String In qelibler
		
		For Each b As String In misrqelib
			qelibSimilarity=0
'		
			For i=0 To b.Length-1
				If b.Length=a.Length Then
					If b.CharAt(i)==a.CharAt(i) Then
						qelibSimilarity=qelibSimilarity+1
					End If
				End If
			Next
			'Log(a.Length*0.75)
			If qelibSimilarity>= a.Length*0.75 Then
				qelibTapildi=True
				selected23.Add(a)
			End If
	
		Next
			
	Next
	
	If selected23.Size>0 Then
		Return axtar(selected23)
	Else
		Return checkSimilarity(kodlular, hecalar)
	End If
	'Else
	'Return sesQ
	'End If
	
	
End Sub


private Sub checkSimilarity(kodlanmish() As String, hga() As Int) As String
	selected.Initialize
	selected2.Initialize
	For i =0 To 2
		Dim xarg() As Char=Utils.toChar(kodlanmish(i))
		Try
			ConnectDB.resul=ConnectDB.varSQL.ExecQuery("SELECT * FROM bahrs WHERE HECA =" & hga(i)  )
			Do While ConnectDB.resul.NextRow
				selected.Add(ConnectDB.resul.GetString("KOD"))
			Loop
			ConnectDB.resul.Close
		Catch
			Log(LastException)
		End Try
		
		For Each kod As String In selected
			Dim ty() As Char = Utils.toChar(kod)
			Do While lengthIdentifieer<kod.Length
				If lengthIdentifieer<xarg.Length Then
'				
					If ty(lengthIdentifieer)=xarg(lengthIdentifieer) Then
						similiar=similiar+1
						counter=counter+1
						If counter>(xarg.Length*0.5) Then
							selected2.Add(kod)
						End If
								
					Else
						differ=differ+1
						counter=0
					End If
					lengthIdentifieer=lengthIdentifieer+1
			
					
				Else
					Exit
				End If
			Loop
			If similiar >=0.85*kod.Length Then
				Log(kod.Length*0.85)
				selected2.Add(kod)
			End If
			similiar=0
			differ=0
			lengthIdentifieer=0
			
		Next
	Next
	If(selected2.Size>0) Then
		Return axtar(selected2)
		selected.Clear
		
	Else
		tapilmadi=True
		
		
		If dil="Azərbaycanca" Then
			behrName.Text="Tapılmadı."
			qelibName.Text="Tapılmadı."
			Return "Tapılmadı."
		Else if dil="Türkçe" Then
			behrName.Text="Bulunamadı."
			qelibName.Text="Bulunamadı."
			Return "Bulunamadı."
		Else
			behrName.Text="Nothing found."
			qelibName.Text="Nothing found."
			Return "Nothing found."
		End If
		
		
	End If
	
End Sub
Private Sub axtar (kods As List) As String
	Dim element As String = Utils.axtar(kods)

	If qelibTapildi Then
		qalib=element
		For Each fd In misraQelib
			If element.EqualsIgnoreCase(fd) Then
				chort=True
				selected23.Clear
			End If
		Next
	Else
		For Each sd In kodlular
			If element.EqualsIgnoreCase(sd) Then
				chort=True
				selected2.Clear
			End If
		Next
		Log(element)
	End If
	Try
		
		Return qelibi(element)
	Catch
		Log(LastException)
		Return "xəta"
	End Try
	
End Sub
Private Sub qelibi (kod As String) As String
	
	Dim a As String
	Dim lgn As Char
	Dim b As String
	
	If qelibTapildi Then
		Try
			ConnectDB.resul=ConnectDB.varSQL.ExecQuery("SELECT * FROM qelibs WHERE digqel =" & $"""$& kod & $"""$ )
			If ConnectDB.resul.NextRow Then
				If dil="Azərbaycanca" Then
					a =ConnectDB.resul.GetString("qelib")
				Else
					a =ConnectDB.resul.GetString("trqelib")
				End If
				b=ConnectDB.resul.GetString("behr")
				ConnectDB.resul.Close
		
			Else
				Log (ConnectDB.resul.NextRow)
				
			End If
		Catch
			Log(LastException)
		
		End Try
		
	Else
		Try
			ConnectDB.resul=ConnectDB.varSQL.ExecQuery("SELECT * FROM bahrs WHERE KOD =" & $"""$& kod & $"""$ )
			If ConnectDB.resul.NextRow Then
				If dil="Azərbaycanca" Then
					a =ConnectDB.resul.GetString("QALIB")
				Else
					a =ConnectDB.resul.GetString("trqalib")
				End If
				b=ConnectDB.resul.GetString("BEHR")
				ConnectDB.resul.Close
		
			Else
				Log (ConnectDB.resul.NextRow)
			
			End If
		Catch
			Log(LastException)
		End Try
	End If
	
	If dil="Azərbaycanca" Then
		lgn="a"
		behrName.Text="Bəhr:"& Utils.bhrName(b,lgn)
		tefile=a
		qelibName.Text="Qəlib:"& tefile
		Return a
	Else if dil="Türkçe" Then
		lgn="t"
		behrName.Text="Vezn Türü:"& Utils.bhrName(b,lgn)
		tefile=a
		qelibName.Text="Kalıb:"& tefile
		Return a
	Else
		lgn="e"
		behrName.Text="Meter name:"& Utils.bhrName(b,lgn)
		tefile=a
		qelibName.Text="Meter:"& tefile
		Return a
	End If
	
End Sub
Private Sub okBtn_Click
	
	If frstMsra.Text<>"" And scndMsra.Text<>"" And thrdMsra.Text<>"" Then
		tapilmadi=False
		clrBtn.Visible=True
		Dim alfi(3) As String
		alfi(0)=frstMsra.Text
		alfi(1)=scndMsra.Text
		alfi(2)=thrdMsra.Text
		kodla(alfi)
		If chort Then
			If dil="Azərbaycanca" Then
				chortl.Text="Dəqiq bəhr tapıldı"
			Else if dil="Türkçe" Then
				chortl.Text="Kesin vezn bulundu"
			Else
				chortl.Text="Precise meter has been found"
			End If
		Else
			If tapilmadi=False Then
				If dil="Azərbaycanca" Then
					chortl.Text="Uyğun bəhr tapıldı"
				Else if dil="Türkçe" Then
					chortl.Text="Uygun vezn bulundu"
				Else
					chortl.Text="Probable meter has been found"
				End If
			End If
		End If
	Else
		dialog.BorderWidth=0
		dialog.BorderCornersRadius=5dip
		dialog.BodyTextColor=Colors.Black
		dialog.ButtonsColor=Colors.RGB(0,89,117)
		dialog.BorderWidth=0
		dialog.ButtonsTextColor=Colors.White
		dialog.TitleBarColor=Colors.RGB(0,89,117)
		dialog.BackgroundColor=Colors.White
		
		If dil="Azərbaycanca" Then
			dialog.Title="Məlumat"
			dialog.Show("Bütün misraları daxil edin.", "Bağla","","")
		Else if dil="Türkçe" Then
			dialog.Title="Uyarı"
			dialog.Show("Tüm mısraları giriniz.", "Tamam","","")
		Else
			dialog.Title="Info"
			dialog.Show("Please enter all three verses.", "Ok","","")
		End If
	End If
End Sub
Private Sub clrBtn_Click
	frstMsra.Text=""
	scndMsra.Text=""
	thrdMsra.Text=""
	tercume(dil)
	chortl.Text=""
	tapilmadi=False
	clrBtn.Visible=False
End Sub