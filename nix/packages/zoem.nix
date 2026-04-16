{ lib, stdenv, fetchFromGitHub, autoreconfHook, cimfomfa }:

stdenv.mkDerivation rec {
  pname = "zoem";
  version = "21-341";

  src = fetchFromGitHub {
    owner = "micans";
    repo = "zoem";
    rev = version;
    hash = "sha256-mZGBnUXCOLytaHzt6hWTUzdpMNcQNni0ezCXC2U8djM=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ cimfomfa ];

  postPatch = ''
    # Fix: zoem uses 'bool' as a variable name, which clashes with C23 bool keyword
    find . -name '*.c' -exec sed -i 's/\bbool\b/zbool/g' {} +
    find . -name '*.h' -exec sed -i 's/\bbool\b/zbool/g' {} +
    # Fix: multiple definition of zoemDateTag (non-extern in header)
    sed -i 's/^char \*zoemDateTag/extern char *zoemDateTag/' src/version.h
    # Skip doc build (circular: uses zoem to build its own docs)
    rm -rf doc
    mkdir doc
    echo "" > doc/Makefile.am
    sed -i '/^man/d' doc/Makefile.am 2>/dev/null || true
    # Generate configure.ac from template
    sed "s/setversion_VERSION/${version}/" configure.ac.in > configure.ac
  '';

  meta = {
    description = "Zoem - a macro/markup language processor";
    homepage = "https://github.com/micans/zoem";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    mainProgram = "zoem";
  };
}
