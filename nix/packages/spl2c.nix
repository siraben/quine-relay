{ lib, stdenv, fetchurl, bison, flex }:

stdenv.mkDerivation rec {
  pname = "spl2c";
  version = "1.2.1";

  src = fetchurl {
    url = "https://web.archive.org/web/20210506141732/http://shakespearelang.sourceforge.net/download/spl-${version}.tar.gz";
    hash = "sha256-EgbvCiyFO4tAygxoK8nZ4KFXzJGnv04o8ZzNADZ0t9M=";
  };

  nativeBuildInputs = [ bison flex ];

  hardeningDisable = [ "fortify" ];

  # Don't try to build examples (they depend on install)
  buildPhase = ''
    runHook preBuild
    make spl2c libspl.a
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib $out/include
    cp spl2c $out/bin/
    cp libspl.a $out/lib/
    cp spl.h $out/include/
    runHook postInstall
  '';

  meta = {
    description = "Shakespeare Programming Language compiler (SPL to C transpiler)";
    homepage = "https://shakespearelang.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "spl2c";
  };
}
