{ lib, stdenv, fetchFromGitHub, autoreconfHook, pkg-config
, pcre2, boehmgc, bison, libtool, automake, autoconf }:

stdenv.mkDerivation rec {
  pname = "parser3";
  version = "0-unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "artlebedev";
    repo = "parser3";
    rev = "31760c16b2250a5717d5411096f6603f73a0cbcc";
    hash = "sha256-Qu+1V4GOC6RSNtpHRVwRzeQhtMoE/z/8incTLDKpB+8=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config bison libtool automake autoconf ];
  buildInputs = [ pcre2 boehmgc libtool.lib ];

  preAutoreconf = ''
    # Fix nested ltdl autotools - run autoreconf in ltdl subdir first
    pushd src/lib/ltdl
    autoreconf -fvi || true
    popd
  '';

  # After configure, prevent make from trying to re-run automake in ltdl
  postConfigure = ''
    # Override ACLOCAL/AUTOMAKE in all generated Makefiles to use current versions
    find . -name Makefile -exec sed -i \
      -e 's|ACLOCAL = .*|ACLOCAL = aclocal|' \
      -e 's|AUTOMAKE = .*|AUTOMAKE = automake|' \
      -e 's|AUTOCONF = .*|AUTOCONF = autoconf|' \
      -e 's|AUTOHEADER = .*|AUTOHEADER = autoheader|' \
      {} +
    # Touch all autotools-generated files
    find . -name Makefile.in -exec touch {} +
    find . -name aclocal.m4 -exec touch {} +
    find . -name configure -exec touch {} +
    find . -name config.h.in -exec touch {} +
  '';

  meta = {
    description = "Parser 3 - a web scripting language";
    homepage = "https://www.parser.ru/en/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "parser3";
  };
}
