# VS Code neon preset (Windows)

Copy this entire folder to another Windows machine with VS Code installed.
Double-click `install.cmd` to install Tokyo Night and merge the appearance preset
into `%APPDATA%\Code\User\settings.json` for all workspaces in the default profile.
Internet is required to install the theme. Administrator rights are not required.

Alternatively, run in PowerShell:

```powershell
.\install.cmd
# Apply settings without installing the theme (offline):
.\install.cmd -SkipExtensions
# Apply to a specific profile or VS Code Insiders user directory:
.\install.cmd -UserDirectory 'C:\path\to\profile'
```

Existing settings are preserved except keys supplied by this preset. Objects
such as color customizations are merged recursively. JSONC comments and trailing
commas are accepted; comments and formatting are removed when saving. A timestamped
`settings.json.backup-*` is created before an existing settings file is changed.
To undo, close VS Code and copy that backup over `settings.json`.

Install JetBrains Mono separately if desired; Consolas is the fallback font.
No font binaries, account settings, or API keys are bundled. The only installed
extension is `enkia.tokyo-night`. Workspace settings may override these user settings.
For non-default VS Code profiles, pass the profile's settings directory explicitly.
Run **Developer: Reload Window** if the appearance does not update immediately.

## Optional visual effects (included)

The installer now installs Tokyo Night, Power Mode, Background, VS Code Pets,
and Code Screensaver. The preset enables a static neon appearance (Power Mode particles and shake are disabled),
a subtle offline neon skyline embedded in settings.json, and a black cat in
the Explorer Pets view. No extra background image download is required.

After installation, run Developer: Reload Window. If the background is not
visible, run Background: Enable and apply the background and follow the
extension's reload prompt. Background modifies VS Code's internal HTML;
VS Code may display an installation integrity warning and updates can require
reapplying it. Use Background: Uninstall the extension before removing it
to remove its patch. Do not remove VS Code integrity checks.

Expand VS CODE PETS in Explorer; if needed run Pet Coding: Start pet coding
session. Run Matrix Overlay: Toggle to show Matrix rain; Escape exits it.
Matrix is started manually and does not cover the code while you work.

To reduce effects: set powermode.enabled or background.enabled to false,
or disable the corresponding extension. Each settings update has a backup.
