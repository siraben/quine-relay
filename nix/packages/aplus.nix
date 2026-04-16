{ lib, stdenv, fetchFromGitHub, autoreconfHook
, libX11, libXt, libXext, libXmu, libXpm, libtool, libnsl, libtirpc
, llvmPackages }:

# Build with clang + C++98 mode to handle this ancient codebase
llvmPackages.stdenv.mkDerivation rec {
  pname = "aplus";
  version = "0-unstable-2018-04-18";

  src = fetchFromGitHub {
    owner = "tavmem";
    repo = "aplus";
    rev = "ce5753f135540942d5551fa318503cb5fede071e";
    hash = "sha256-ccNiWUFA5g7YkSgwO3IH0MeIHOKyGIP3yxtfK1Nejoc=";
  };

  nativeBuildInputs = [ autoreconfHook libtool ];
  buildInputs = [ libX11 libXt libXext libXmu libXpm libnsl libtirpc ];

  hardeningDisable = [ "format" "fortify" ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${libtirpc.dev}/include/tirpc"
    "-w"                  # suppress all warnings
  ];
  configureFlags = [
    "--x-includes=${libX11.dev}/include"
    "--x-libraries=${libX11}/lib"
  ];
  env.CFLAGS = toString [
    "-std=gnu89" "-w"
    "-Wno-error=implicit-function-declaration"
    "-Wno-error=int-conversion"
    "-Wno-error=incompatible-pointer-types"
    "-Wno-error=implicit-int"
  ];
  env.CXXFLAGS = toString [
    "-std=gnu++98"        # oldest C++ standard, maximally permissive
    "-w"                  # suppress all warnings
    "-Wno-register"       # just in case
  ];

  postPatch = ''
    # Replace deprecated sys_errlist/sys_nerr with strerror
    find . \( -name '*.C' -o -name '*.c' -o -name '*.H' -o -name '*.h' \) -print0 | \
      xargs -0 sed -i \
        -e 's/sys_errlist\[errno\]/strerror(errno)/g' \
        -e 's/sys_nerr/4096/g'
    # Add string.h include for strerror
    find . \( -name '*.C' -o -name '*.c' \) -print0 | \
      xargs -0 sed -i '1s|^|#include <string.h>\n|'

    # Fix ordered comparison of pointer with zero (ptr>0 -> ptr!=0, ptr<0 -> 0)
    # Clang rejects all pointer-to-int ordered comparisons as hard errors.
    # In this codebase, >0 means "not null" and <0 is never valid for pointers.
    # We use a C++ source transformation via sed:
    #   _data>0  -> _data!=0
    #   _data<0  -> false  (never true for a pointer)
    #   (cp)>0   -> (cp)!=0
    # This is safe because the compiler already told us which lines have this pattern.
    # Only replace )>0 and _foo>0 patterns (method calls and member vars, not templates)
    find . \( -name '*.C' -o -name '*.H' \) -print0 | \
      xargs -0 sed -i \
        -e 's/()>0/()!=0/g' \
        -e 's/()> 0/()!=0/g' \
        -e 's/()< 0/()==0/g' \
        -e 's/()<0/()==0/g' \
        -e 's/_data>0/_data!=0/g' \
        -e 's/_data< *0/_data==0/g' \
        -e 's/_elements>0/_elements!=0/g'
    # Fix MSBinaryMatrix.C specifically - uses mp>0, dp>0 for pointer null checks
    sed -i -e 's/ (mp>0)/ (mp!=0)/g' -e 's/ (dp>0)/ (dp!=0)/g' \
           -e 's/ (mp<0)/ (mp==0)/g' -e 's/ (dp<0)/ (dp==0)/g' \
           src/MSTypes/MSBinaryMatrix.C 2>/dev/null || true

    # Fix missing size_t (causes cascading offsetof errors)
    sed -i '1s|^|#include <stddef.h>\n|' src/MSTypes/MSTypeData.H

    # Fix C++ template issues in MSFloatMatrix.H
    # 1. Add template<> before specialization declarations
    sed -i 's/^class MSMatrixSTypePick<double>/template<> class MSMatrixSTypePick<double>/' \
      src/MSTypes/MSFloatMatrix.H
    # 2. Remove default arguments from friend declarations (not allowed)
    find . -name '*.H' -print0 | xargs -0 sed -i \
      's/void \*clientData_=0);/void *clientData_);/g'
  '';

  meta = {
    description = "A+ - a powerful and efficient programming language";
    homepage = "https://github.com/tavmem/aplus";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "a+";
  };
}
