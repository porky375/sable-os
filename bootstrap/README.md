# Bootstrap

The bootstrap is the boundary between using the development host and producing
an independent runtime.

`sources.toml` must contain immutable revisions and hashes for every stage-0
input before the builder is implemented. The stage-0 output is not releasable.
The first releasable package set is rebuilt inside a root created exclusively
from stage-0 `os_name` packages.

Do not add the host's mirror list or package databases to a generated root.
