@echo off
setlocal enabledelayedexpansion

rem Create the known_hosts file if it doesn't exist
if not exist "%USERPROFILE%\.ssh\known_hosts" type nul > "%USERPROFILE%\.ssh\known_hosts"

for %%a in ("add_your_url_to_known_host") do (
    set "domain=%%a"
    for /f "tokens=2 delims=: " %%b in ('nslookup !domain! ^| findstr /C:"Address"') do set "ip=%%b"
    echo.|set /p="!domain! "
    ssh-keygen -R !domain! >nul 2>&1
    ssh-keyscan !ip! !domain! >> "%USERPROFILE%\.ssh\known_hosts"
)

endlocal
