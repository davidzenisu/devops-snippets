# List

## VS Code Extension that list all currently running apps/ports

``` batch
netstat -ano | find "LISTEN"
::Run this in loop until "Window Title" property is found
wmic process get processid,parentprocessid,executablepath|find "4744"
tasklist /fi "PID eq 4744" /v
::Print PID, window title, memory usage etc.
```
