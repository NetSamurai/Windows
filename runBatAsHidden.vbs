''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Author: Netrunner
'' License: GNU General Public License v3.0
'' Description: Pass the bat file to the argument to run without spawning a window.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Launcher.vbs
If WScript.Arguments.Count = 0 Then
  WScript.Quit 1
End If

Dim WSH
Set WSH = CreateObject("WScript.Shell")
WSH.Run "cmd /c " & WScript.Arguments(0), 0, False
