---
name: parse-xcode-logs
description: 'Analyzes xcodebuild terminal output to identify build errors, warnings, and dependency resolutions.'
---

# Parse Xcode Build Logs

When asked to analyze a failing build or terminal output from Xcode, follow these steps:

1. **Identify the core failure:** Ignore generic `Command PhaseScriptExecution failed` messages and search upwards in the log for the actual compiler error (`error: ...`) or missing dependency warning.
2. **Filter noise:** Disregard standard output regarding module maps or indexing unless it is directly tied to a missing header.
3. **Actionable resolution:** Provide the exact Swift file path, line number, and a suggested code fix. If it's a project file issue (`.pbxproj`), explain which Xcode build phase needs adjustment.

