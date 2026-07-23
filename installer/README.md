# Installer

This directory is a safety-first Calamares configuration blueprint. It is not
ready for physical disks.

Before enabling an install mode:

1. Implement the storage-layout helper.
2. Test it against disposable regular image files.
3. Verify byte-for-byte preservation of simulated Windows partitions.
4. Add a Calamares integration test for cancellation and failure.
5. Review every command that runs inside the target root.

Automatic shrinking is deliberately disabled. The alpha may use an entire
disk, existing unallocated space, or expert manual partitioning.
