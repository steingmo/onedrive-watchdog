set installer to quoted form of POSIX path of (path to resource "install-onedrive-watchdog.sh")
set choice to button returned of (display dialog "OneDrive Watchdog checks every minute that OneDrive is running and restarts it if it has stopped." buttons {"Uninstall", "Cancel", "Install"} default button "Install" cancel button "Cancel" with title "OneDrive Watchdog" with icon note)
if choice is "Install" then
	do shell script "sh " & installer
	moveToApplications(POSIX path of (path to me))
	display dialog "Installed. OneDrive will now be restarted automatically if it stops." buttons {"OK"} default button "OK" with title "OneDrive Watchdog" with icon note
else
	do shell script "sh " & installer & " uninstall"
	display dialog "OneDrive Watchdog has been removed." buttons {"OK"} default button "OK" with title "OneDrive Watchdog" with icon note
end if

-- Copy this app to /Applications (replacing any older copy) and remove the original.
on moveToApplications(src)
	if src ends with "/" then set src to text 1 thru -2 of src
	set dest to "/Applications/OneDrive Watchdog.app"
	if src is dest then return
	set cmd to "rm -rf " & quoted form of dest & " && ditto " & quoted form of src & " " & quoted form of dest
	try
		do shell script cmd
	on error
		-- Standard (non-admin) users can't write to /Applications: ask for an admin password.
		try
			do shell script cmd with administrator privileges
		on error
			return -- cancelled: the watchdog is installed anyway, the app just stays where it is
		end try
	end try
	-- Opened straight from Downloads, macOS runs the app from a hidden read-only copy
	-- ("App Translocation") and its real location is unknown; then remove the usual
	-- download spots instead, but only if the bundle there really is this app.
	if src contains "/AppTranslocation/" then
		set originals to {(POSIX path of (path to downloads folder)) & "OneDrive Watchdog.app", (POSIX path of (path to desktop folder)) & "OneDrive Watchdog.app"}
	else
		set originals to {src}
	end if
	repeat with p in originals
		set p to contents of p
		try
			if (do shell script "defaults read " & quoted form of (p & "/Contents/Info") & " CFBundleIdentifier") is "fo.nema.onedrive-watchdog" then do shell script "rm -rf " & quoted form of p
		end try
	end repeat
end moveToApplications
