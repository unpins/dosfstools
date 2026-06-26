{
  description = "dosfstools (mkfs.fat + fsck.fat + fatlabel) as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # dosfstools ships three sbin programs (fsck.fat, mkfs.fat, fatlabel) plus
  # seven compat symlinks (dosfsck, fsck.msdos, fsck.vfat, mkdosfs, mkfs.msdos,
  # mkfs.vfat, dosfslabel). They share boot/common/fat/io/charconv with no
  # callbacks into the programs. linux + darwin self-fold through the unpin-llvm
  # engine (one bitcode module, three `unpin__dosfstools__*_main` entries), like
  # coreutils/unzip. The hand-rolled cpp-rename fold (./spec → cosmo.nix) is
  # ELF-only and reserved for the Windows path. The real binary is
  # bin/dosfstools(.exe); every program/compat name is an argv[0] alias.
  # nixpkgs ships dosfstools on linux/darwin/cygwin; Windows goes through cosmo
  # (the same POSIX-layer route e2fsprogs takes), so no mingw cross.
  outputs = { self, unpins-lib }:
    let
      lib = unpins-lib.lib;
      # Hand-rolled cpp-rename fold spec — WINDOWS (cosmo) only. mkfs.fat compiles
      # its sources under per-target names (mkfs_fat-*.o). per-target bits
      # (basePkg, isWindows) are merged in by `windowsBuild`/cosmo.nix.
      spec = {
        primary = "dosfstools";
        makeSubdir = "src";
        linkExtra = "$(LIBINTL) $(LIBICONV)";
        programs = [
          {
            name = "fsck.fat";
            objs = [
              "src/check.o" "src/file.o" "src/fsck.fat.o" "src/lfn.o"
              "src/boot.o" "src/common.o" "src/fat.o" "src/io.o" "src/charconv.o"
            ];
          }
          {
            name = "mkfs.fat";
            objs = [
              "src/mkfs_fat-mkfs.fat.o" "src/mkfs_fat-common.o" "src/mkfs_fat-charconv.o"
              "src/mkfs_fat-device_info.o"
              "src/blkdev/mkfs_fat-blkdev.o" "src/blkdev/mkfs_fat-linux_version.o"
            ];
          }
          {
            name = "fatlabel";
            objs = [
              "src/fatlabel.o" "src/boot.o" "src/common.o"
              "src/fat.o" "src/io.o" "src/charconv.o"
            ];
          }
        ];
        aliases = [
          { name = "dosfsck"; target = "fsck.fat"; }
          { name = "fsck.msdos"; target = "fsck.fat"; }
          { name = "fsck.vfat"; target = "fsck.fat"; }
          { name = "mkdosfs"; target = "mkfs.fat"; }
          { name = "mkfs.msdos"; target = "mkfs.fat"; }
          { name = "mkfs.vfat"; target = "mkfs.fat"; }
          { name = "dosfslabel"; target = "fatlabel"; }
        ];
        extraInstall = ''
          mkdir -p "$out/share/man/man8"
          for m in fsck.fat mkfs.fat fatlabel; do
            if [ -f "manpages/$m.8" ]; then install -m644 "manpages/$m.8" "$out/share/man/man8/$m.8"; fi
          done
        '';
      };
    in
    lib.mkStandaloneFlake {
      inherit self;
      name = "dosfstools";
      binName = "dosfstools";
      smoke = [ "--unpin-program=mkfs.fat" "--help" ];
      smokePattern = "[Uu]sage";

      # Build via the unpin-llvm engine + emit a bitcode multicall module. linux
      # + darwin both self-fold through the engine; each of the three programs'
      # `main` becomes an `unpin__dosfstools__<prog>_main` entry, and the compat
      # names are argv[0] aliases.
      engine = "unpin-llvm";
      multicall = {
        programs = [
          { name = "fatlabel"; aliases = [ "dosfslabel" ]; }
          { name = "fsck.fat"; aliases = [ "dosfsck" "fsck.msdos" "fsck.vfat" ]; }
          { name = "mkfs.fat"; aliases = [ "mkdosfs" "mkfs.msdos" "mkfs.vfat" ]; }
        ];
      };
      build = pkgs: pkgs.pkgsStatic.dosfstools;
      # Windows: dosfstools is a POSIX program (termios/langinfo/endian/off_t/
      # SIGALRM/sys-ioctl/…). nixpkgs ships it for Windows only via cygwin's
      # POSIX layer; a pure-mingw cross is an 8+-header shim slog that ends up
      # fighting mingw's own dirent.h. cosmo provides that POSIX layer cleanly,
      # the same route e2fsprogs takes.
      windowsBuild = import ./cosmo.nix { inherit unpins-lib spec; };
    };
}
