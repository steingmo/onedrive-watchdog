set installer to quoted form of POSIX path of (path to resource "install-onedrive-watchdog.sh")
set choice to button returned of (display dialog "OneDrive Watchdog checks every minute that OneDrive is running and restarts it if it has stopped." buttons {"Uninstall", "Cancel", "Install"} default button "Install" cancel button "Cancel" with title "OneDrive Watchdog" with icon note)
if choice is "Install" then
	do shell script "sh " & installer
	display dialog "Installed. OneDrive will now be restarted automatically if it stops." buttons {"OK"} default button "OK" with title "OneDrive Watchdog" with icon note
else
	do shell script "sh " & installer & " uninstall"
	display dialog "OneDrive Watchdog has been removed." buttons {"OK"} default button "OK" with title "OneDrive Watchdog" with icon note
end if
