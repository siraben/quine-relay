{ lib, stdenv, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "cimfomfa";
  version = "21-341";

  src = fetchFromGitHub {
    owner = "micans";
    repo = "cimfomfa";
    rev = version;
    hash = "sha256-bqBmSw91uTNTIVNJPrVxrN+9FWEM1GpL45Rem0Kz69M=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  postPatch = ''
    sed "s/setversion_VERSION/${version}/" configure.ac.in > configure.ac
  '';

  meta = {
    description = "C utility library used by zoem and other micans projects";
    homepage = "https://github.com/micans/cimfomfa";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
  };
}
