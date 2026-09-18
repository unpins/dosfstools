# dosfstools

[dosfstools](https://github.com/dosfstools/dosfstools) — create and check FAT12/16/32 filesystems: `mkfs.fat`, `fsck.fat` and `fatlabel`. A single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/dosfstools/actions/workflows/dosfstools.yml/badge.svg)](https://github.com/unpins/dosfstools/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install dosfstools`.

All three platforms create and check FAT filesystems in image files. Linux also operates on block devices (`/dev/sd*`); on macOS and Windows it is image-only.

## Usage

Run a program with [unpin](https://github.com/unpins/unpin):

```bash
unpin dosfstools --unpin-program=mkfs.fat -F 32 disk.img
unpin dosfstools --unpin-program=fatlabel disk.img MYVOLUME
unpin dosfstools --unpin-program=fsck.fat -v disk.img
```

To install the programs onto your PATH:

```bash
unpin install dosfstools
```

`unpin install dosfstools` creates `mkfs.fat`, `fsck.fat` and `fatlabel`, plus the traditional aliases `mkdosfs`, `mkfs.msdos`, `mkfs.vfat`, `dosfsck`, `fsck.msdos`, `fsck.vfat` and `dosfslabel`. `unpin info dosfstools` lists every command.

## Man pages

One page per program is embedded, compat names included — read any with
`unpin man dosfstools <program>`, e.g. `unpin man dosfstools mkfs.fat`.

## Build locally

```bash
nix build github:unpins/dosfstools
./result/bin/dosfstools --unpin-program=mkfs.fat -F 32 disk.img
```

Or run directly:

```bash
nix run github:unpins/dosfstools -- --unpin-program=mkfs.fat --help
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/dosfstools/releases) page has standalone binaries for manual download.

## Build notes

- **Windows:** built via [Cosmopolitan](https://github.com/jart/cosmopolitan), not mingw — dosfstools is a POSIX program (termios/langinfo/endian/SIGALRM/sys-ioctl), and mingw lacks that POSIX layer.
- **Tests:** dosfstools' testsuite runs on native builds (0 failures under static-musl) and auto-skips on cross targets the build host can't execute.
