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
	Dim varSQL As SQLCipher
	Dim resul As ResultSet
	Private psw As String = "masmililer123!5"
End Sub

Sub ConnectionToDB
	Dim conDB As String
	
	Try
		conDB=DBUtils.CopyDBFromAssets("behrdat.db")
		varSQL.Initialize(conDB,"behrdat.db", True,psw,Null )
	Catch
		Log(LastException)
	End Try

End Sub