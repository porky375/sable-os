# Shell

This is the first visual shell surface. It establishes the bottom taskbar,
start menu, desktop selector, hidden-window entry point, and monochrome tokens.

The placeholder workspace model must be replaced with a D-Bus client for
`org.os_name.Desktop1` before M2 is complete. The final shell subscribes to
signals; it does not poll `hyprctl`.

Fullscreen/game mode must set every shell `PanelWindow` input region empty and
hide all nonessential layers before the compositor focuses the game.
