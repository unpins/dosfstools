# dosfstools (mkfs.fat + fsck.fat + fatlabel) via cosmoStaticCross for
# Windows-x86_64, folded into one Windows PE (.exe) with the cpp-rename recipe
# (lib.cppRenameMulticall, isCosmo path).
#
# dosfstools is a POSIX program (termios/langinfo/endian/off_t/SIGALRM/
# sys-ioctl, plus Linux block-device probing). A pure-mingw cross dead-ends in
# an 8+-header shim slog that ends up fighting mingw's own dirent.h; nixpkgs
# only ships it for Windows via cygwin's POSIX layer. cosmocc provides that
# POSIX layer for a single binary — the same route e2fsprogs takes.
# One source fix vs the Linux/macOS build: patches/cosmo-mkfs-o-excl.patch.
{ unpins-lib, spec }:
pkgs:
let
  cosmoPkgs = unpins-lib.lib.cosmoStaticCross pkgs;
  lib = cosmoPkgs.lib // unpins-lib.lib;
  basePkg = cosmoPkgs.dosfstools.overrideAttrs (oa: {
    patches = (oa.patches or [ ]) ++ [ ./patches/cosmo-mkfs-o-excl.patch ];
  });
in
lib.cppRenameMulticall (spec // {
  pkgs = cosmoPkgs;
  inherit basePkg;
  isCosmo = true;
})
