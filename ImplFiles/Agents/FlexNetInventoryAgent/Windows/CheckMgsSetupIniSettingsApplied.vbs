'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This script checks that the registry entry
' HKEY_LOCAL_MACHINE\Software\ManageSoft Corp\ManageSoft\Common\MGSSetupIniApplied
' exists. This setting is configured by the mgssetup.ini file that is
' used to configure the installation. If the setting is not found,
' that implies that the installation was done without an mgssetup.ini
' file; in that case an error is reported and the installation is
' failed. If the setting is found, it is deleted (to ensure it doesn't
' get left lying around to cause problems in the future).
'
' Error text reported if this check fails:
'
' Settings that are expected from mgssetup.ini have not been applied,
' suggesting the mgssetup.ini installation configuration file is not
' accessible from the SYSTEM context. If this package has been
' installed from a remote share, this may be because the SYSTEM
' account on this computer does not have read access to that share.
' This error can also be caused by attempting to install this package
' from a mapped drive. Check installation log for more details.
'
' Copyright (C) 2012 Flexera Software
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function CheckMGSSetupIniSettingsApplied
	' MSI package error # to report in case of failure
	ErrorNo = 30000

	Set WshShell = CreateObject("Wscript.Shell")

	RegPath = "HKEY_LOCAL_MACHINE\Software\ManageSoft Corp\ManageSoft\Common\MGSSetupIniApplied"

	On Error Resume Next

	WshShell.RegRead(RegPath)
	Result = Err.Number
	On Error GoTo 0

	If Result <> 0 Then
		CheckMGSSetupIniSettingsApplied = 3	' IDABORT

'		WScript.Echo "Setting not found"

		Set rec = Installer.CreateRecord(1)
		rec.IntegerData(1) = CInt(ErrorNo)
		Session.Message &H01000000, rec
	Else
		CheckMGSSetupIniSettingsApplied = 1	' IDOK

		' Delete registry entry
		WshShell.RegDelete(RegPath)
	End If
End Function

'CheckMGSSetupIniSettingsApplied
