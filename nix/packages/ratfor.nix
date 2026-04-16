{ lib, stdenv, fetchurl, gfortran }:

stdenv.mkDerivation rec {
  pname = "ratfor";
  version = "1.07";

  src = fetchurl {
    url = "http://www.dgate.org/ratfor/tars/ratfor-${version}.tar.gz";
    hash = "sha256-lDtd4yjXuJDLREsX+32rZW/6oNOIx9QLZJ00tzaxN/8=";
  };

  nativeBuildInputs = [ gfortran ];

  meta = {
    description = "Ratfor - Rational Fortran preprocessor";
    homepage = "http://www.dgate.org/ratfor/";
    license = lib.licenses.free;
    platforms = lib.platforms.unix;
    mainProgram = "ratfor";
  };
}
