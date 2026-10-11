B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.2
@EndOfDesignText@
Sub Class_Globals
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	InitializeDB
End Sub

'SELF EXPLANATORY
Sub InitializeDB

	'File.Delete(File.DirInternal, "behrdat.db")
	If Not(File.Exists(File.DirInternal, "behrdat.db")) Then 'Does the database exists
		Wait For (File.CopyAsync(File.DirAssets, "behrdat.db", File.DirInternal, "behrdat.db")) Complete (Success As Boolean) 'Copy the database to another folder
		'Log($"Database copied = ${Success}"$)
	End If

	'Log($"Database size = ${File.Size(File.DirInternal, "behrdat.db")}"$) 'View the size of the file in the logs.
	B4XPages.MainPage.SQL.Initialize(File.DirInternal, "behrdat.db", True) 'Connect to the database


	

End Sub
