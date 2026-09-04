# Changelog

## [Unreleased]

Initial release — `dosfstools` 4.2 as a single self-contained binary, built
natively for Linux, macOS, and Windows.

### Added

- Builds for Linux (x86_64, aarch64, armv7l, i686, ppc64le, riscv64), macOS
  (x86_64, aarch64), and Windows.
- `mkfs.fat`, `fsck.fat` and `fatlabel` in the one binary, plus the traditional
  names `mkdosfs`, `mkfs.msdos`, `mkfs.vfat`, `dosfsck`, `fsck.msdos`,
  `fsck.vfat` and `dosfslabel` — `unpin install dosfstools` creates all ten.
- One man page per program embedded in the binary, compat names included — read
  any with `unpin man dosfstools <program>`.
- On Linux the tools also work on block devices (`/dev/sd*`); on macOS and
  Windows they work on image files, which is what those systems expose.
