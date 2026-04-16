{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, pcre, pcre2, antlr2, libtool }:

stdenv.mkDerivation rec {
  pname = "gpt-portugol";
  version = "0-unstable-2026-01-08";

  src = fetchgit {
    url = "https://salsa.debian.org/debian/gpt.git";
    rev = "5453a0c897f35fdf041b6158af7268a3e0b93146";
    hash = "sha256-JU/N+/kHsaAMKU/FmFy7n2d/JzE9ajin6OSGaa5iyZY=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config libtool ];
  buildInputs = [ pcre pcre2 antlr2 ];

  postPatch = ''
    # Create runantlr wrapper that gpt expects
    mkdir -p $TMPDIR/bin
    ln -s ${antlr2}/bin/antlr $TMPDIR/bin/runantlr
    export PATH="$TMPDIR/bin:$PATH"
  '';

  meta = {
    description = "G-Portugol - Portuguese structured programming language";
    homepage = "https://gpt.berlios.de/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gpt";
  };
}
