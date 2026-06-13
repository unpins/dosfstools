# dosfstools

[dosfstools](https://github.com/dosfstools/dosfstools) — create and check FAT12/16/32 filesystems: `mkfs.fat`, `fsck.fat` and `fatlabel`. A single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/dosfstools/actions/workflows/dosfstools.yml/badge.svg)](https://github.com/unpins/dosfstools/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install dosfstools`.

All three platforms create and check FAT filesystems in image files. Linux also operates on block devices (`/dev/sd*`); on macOS and Windows it is image-only. The Windows build is a [Cosmopolitan](https://github.com/jart/cosmopolitan) `.exe` (see Build notes).

## Usage

Run a program with [unpin](https://github.com/unpins/unpin):

```bash
unpin dosfstools mkfs.fat -F 32 disk.img
unpin dosfstools fatlabel disk.img MYVOLUME
unpin dosfstools fsck.fat -v disk.img
```

To install the programs onto your PATH:

```bash
unpin install dosfstools
```

`unpin install dosfstools` creates `mkfs.fat`, `fsck.fat` and `fatlabel`, plus the traditional aliases `mkdosfs`, `mkfs.msdos`, `mkfs.vfat`, `dosfsck`, `fsck.msdos`, `fsck.vfat` and `dosfslabel`. `unpin info dosfstools` lists every command.

## Build locally

```bash
nix build github:unpins/dosfstools
./result/bin/dosfstools mkfs.fat -F 32 disk.img
```

Or run directly:

```bash
nix run github:unpins/dosfstools -- mkfs.fat --help
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/dosfstools/releases) page has standalone binaries for manual download.

## Build notes

- **Platforms:** Linux, macOS, Windows. macOS/Windows have no FAT block-device layer, so the tools work on image files but not live block devices.
- **Windows:** built via [Cosmopolitan](https://github.com/jart/cosmopolitan) (`cosmocc` → APE `.exe`), not mingw — see [`cosmo.nix`](cosmo.nix). dosfstools is a POSIX program (termios/langinfo/endian/SIGALRM/sys-ioctl); a pure-mingw cross dead-ends fighting mingw's own `dirent.h`, and nixpkgs only ships it for Windows via cygwin's POSIX layer, which is what cosmo provides for a single binary. One source fix: `O_EXCL` is neutralized on the image fd (cosmo's NT `open()` EINVALs on `O_RDWR|O_EXCL` for a regular file; on Linux it is a no-op there). NB: wine tolerates that `O_EXCL`, so it only surfaced on a real Windows host.
- **Multicall:** the three programs are folded into one ELF/Mach-O/APE via a source-level `main` → `<prog>_main` rename (`lib.cppRenameMulticall`), keeping a single copy of the shared FAT/IO objects.
- **Man pages:** the section-8 pages are embedded; read with `unpin man dosfstools mkfs.fat`.
