# Hyprland Plugin

The plugin will provide only behavior that cannot be implemented safely in the
shell:

- Server-side decorations for clients that negotiate them.
- Caption input for move, double-click maximize, minimize, maximize, and close.
- Snap-zone previews and final geometry.
- Fullscreen/game bypass.

Do not draw a second title bar over applications using client-side
decorations. Do not store desktop state in the plugin.

Implementation begins after the supported Hyprland commit is pinned in
`version.toml`. Every plugin release must be built and promoted with that exact
Hyprland package. Loading an unmatched binary must fail closed.
