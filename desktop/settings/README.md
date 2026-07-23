# Settings

The initial Qt/QML surface establishes navigation and controls. Production
settings are loaded and committed through `org.os_name.Desktop1`, with preview,
validation, atomic persistence, and schema migration.

System-level changes use small polkit-authorized helpers with one purpose each.
The settings process itself never runs as root.
