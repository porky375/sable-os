if [[ -z "${WAYLAND_DISPLAY:-}" && "${XDG_VTNR:-0}" == 1 ]]; then
    export XDG_CURRENT_DESKTOP=Hyprland
    export XDG_SESSION_DESKTOP=Hyprland
    export XDG_SESSION_TYPE=wayland
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    exec start-hyprland
fi
