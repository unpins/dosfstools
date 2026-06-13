# dosfstools (mkfs.fat + fsck.fat + fatlabel) via cosmoStaticCross for
# Windows-x86_64, folded into one APE with the cpp-rename recipe (lib.cppRenameMulticall,
# isCosmo path).
#
# dosfstools is a POSIX program (termios/langinfo/endian/off_t/SIGALRM/
# sys-ioctl, plus Linux block-device probing). A pure-mingw cross dead-ends in
# an 8+-header shim slog that ends up fighting mingw's own dirent.h; nixpkgs
# only ships it for Windows via cygwin's POSIX layer. cosmocc provides that
# POSIX layer for a single binary — the same route e2fsprogs takes.
# One source fix vs the Linux/macOS build:
#
#  * **O_EXCL on a regular file** — mkfs.fat opens its target with `O_EXCL |
#    O_RDWR` to reject building a filesystem on a mounted/busy *block device*.
#    On a regular file (no O_CREAT) O_EXCL is a Linux no-op, but cosmocc's NT
#    open() rejects it with EINVAL ("unable to open …: Invalid argument").
#    Windows images are regular files, so neutralize O_EXCL in mkfs.fat.c only
#    (same fix e2fsprogs's unix_io.c needs). NB: wine tolerates O_EXCL here, so
#    this only surfaces on a real Windows host — verify on the VM, not wine.
{ unpins-lib, spec }:
pkgs:
let
  cosmoPkgs = unpins-lib.lib.cosmoStaticCross pkgs;
  lib = cosmoPkgs.lib // unpins-lib.lib;
  basePkg = cosmoPkgs.dosfstools.overrideAttrs (oa: {
    postPatch = (oa.postPatch or "") + ''
      awk '/#include <fcntl.h>/ && !done {print; print "#ifdef __COSMOPOLITAN__"; print "#undef O_EXCL"; print "#define O_EXCL 0"; print "#endif"; done=1; next} {print}' \
        src/mkfs.fat.c > src/mkfs.fat.c.tmp && mv src/mkfs.fat.c.tmp src/mkfs.fat.c
    '';
  });
in
lib.cppRenameMulticall (spec // {
  pkgs = cosmoPkgs;
  inherit basePkg;
  isCosmo = true;
})
